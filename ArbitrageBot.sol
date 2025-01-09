// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@aave/core-v3/contracts/interfaces/IPool.sol";
import "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import "@aave/core-v3/contracts/flashloan/IFlashLoanReceiver.sol";

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract ArbitrageBot is IFlashLoanReceiver {
    address public owner;
    IPoolAddressesProvider public immutable addressesProvider;

    constructor(address _addressesProvider) {
        owner = msg.sender;
        addressesProvider = IPoolAddressesProvider(_addressesProvider);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    // Flash loan entry point
    function executeArbitrage(
        address routerA,
        address routerB,
        address tokenA,
        address tokenB,
        uint256 flashLoanAmount
    ) external onlyOwner {
        address;
        assets[0] = tokenA;

        uint256;
        amounts[0] = flashLoanAmount;

        uint256;
        modes[0] = 0; // 0 = no debt (full repayment required in the same transaction)

        // Request a flash loan
        IPool(addressesProvider.getPool()).flashLoan(
            address(this), // Receiver address
            assets,        // Assets to borrow
            amounts,       // Amounts to borrow
            modes,         // Modes for debt repayment
            address(0),    // OnBehalfOf
            "",            // Params (unused)
            0              // Referral code
        );
    }

    // Aave flash loan callback
    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initiator,
        bytes calldata params
    ) external override returns (bool) {
        require(msg.sender == addressesProvider.getPool(), "Caller is not the lending pool");
        require(initiator == address(this), "Unauthorized initiator");

        address tokenA = assets[0];
        uint256 flashLoanAmount = amounts[0];
        uint256 fee = premiums[0];

        // Perform arbitrage trades
        address routerA = abi.decode(params, (address)); // Router A
        address routerB = abi.decode(params[32:], (address)); // Router B
        address tokenB = abi.decode(params[64:], (address)); // Token B

        // Approve tokenA for RouterA
        IERC20(tokenA).approve(routerA, flashLoanAmount);

        // Swap tokenA -> tokenB on RouterA
        address;
        path[0] = tokenA;
        path[1] = tokenB;

        uint[] memory amountsOutA = IUniswapV2Router(routerA).swapExactTokensForTokens(
            flashLoanAmount,
            1, // Minimum output
            path,
            address(this),
            block.timestamp + 60
        );

        uint amountReceived = amountsOutA[1];

        // Approve tokenB for RouterB
        IERC20(tokenB).approve(routerB, amountReceived);

        // Swap tokenB -> tokenA on RouterB
        path[0] = tokenB;
        path[1] = tokenA;

        uint[] memory amountsOutB = IUniswapV2Router(routerB).swapExactTokensForTokens(
            amountReceived,
            1, // Minimum output
            path,
            address(this),
            block.timestamp + 60
        );

        uint amountAfterArbitrage = amountsOutB[1];

        // Ensure enough profit to cover fees
        uint amountOwing = flashLoanAmount + fee;
        require(amountAfterArbitrage > amountOwing, "No profit from arbitrage");

        // Approve and repay the flash loan
        IERC20(tokenA).approve(msg.sender, amountOwing);

        return true;
    }

    // Withdraw tokens to owner
    function withdrawTokens(address token) external onlyOwner {
        uint balance = IERC20(token).balanceOf(address(this));
        require(balance > 0, "No tokens to withdraw");
        IERC20(token).transfer(owner, balance);
    }
}

