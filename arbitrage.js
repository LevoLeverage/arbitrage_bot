require("dotenv").config();
const { ethers } = require("hardhat");

const arbitrageBotAddress = "YOUR_DEPLOYED_CONTRACT_ADDRESS"; // Replace with your deployed contract address

async function main() {
    // Get the signer (your wallet connected to Hardhat)
    const [owner] = await ethers.getSigners();

    // Connect to the deployed ArbitrageBot contract
    const arbitrageBot = await ethers.getContractAt("ArbitrageBot", arbitrageBotAddress);

    // Define the DEX routers
    const routerA = "ROUTER_A_ADDRESS"; // Replace with the address of Router A (e.g., Uniswap)
    const routerB = "ROUTER_B_ADDRESS"; // Replace with the address of Router B (e.g., SushiSwap)

    // Define the token addresses
    const tokenA = "TOKEN_A_ADDRESS"; // Replace with the address of Token A (e.g., VIRTUAL)
    const tokenB = "TOKEN_B_ADDRESS"; // Replace with the address of Token B (e.g., WETH)

    // Define the flash loan amount (or trading amount for testing)
    const amountIn = ethers.utils.parseUnits("1.0", 18); // Replace "1.0" with the desired amount in Token A's decimals

    console.log("Executing arbitrage...");
    
    // Call the executeArbitrage function on the contract
    const tx = await arbitrageBot.executeArbitrage(routerA, routerB, tokenA, tokenB, amountIn);
    console.log("Transaction submitted, waiting for confirmation...");
    
    await tx.wait();
    console.log("Arbitrage executed!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
