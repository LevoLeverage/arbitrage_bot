// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV2Router {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract ArbitrageBot {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function executeArbitrage(
        address routerA,
        address routerB,
        address tokenA,
        address tokenB,
        uint amountIn
    ) external onlyOwner {
        // Approve tokens for the first router
        IERC20(tokenA).approve(routerA, amountIn);

        // Perform swap on Router A
        address;
        path[0] = tokenA;
        path[1] = tokenB;

        uint[] memory amountsOutA = IUniswapV2Router(routerA).swapExactTokensForTokens(
            amountIn,
            1, // Accept any amount
            path,
            address(this),
            block.timestamp + 60
        );

        uint amountOutA = amountsOutA[1];

        // Approve tokens for the second router
        IERC20(tokenB).approve(routerB, amountOutA);

        // Perform swap on Router B
        path[0] = tokenB;
        path[1] = tokenA;

        uint[] memory amountsOutB = IUniswapV2Router(routerB).swapExactTokensForTokens(
            amountOutA,
            1, // Accept any amount
            path,
            address(this),
            block.timestamp + 60
        );

        // Profit is now the difference between the two swaps
    }

    function withdrawTokens(address token) external onlyOwner {
        IERC20(token).transfer(owner, IERC20(token).balanceOf(address(this)));
    }
}
