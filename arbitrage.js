require("dotenv").config();
const { ethers } = require("hardhat");

const arbitrageBotAddress = "YOUR_DEPLOYED_CONTRACT_ADDRESS";

async function main() {
    const [owner] = await ethers.getSigners();
    const arbitrageBot = await ethers.getContractAt("ArbitrageBot", arbitrageBotAddress);

    const routerA = "ROUTER_A_ADDRESS";
    const routerB = "ROUTER_B_ADDRESS";
    const tokenA = "TOKEN_A_ADDRESS"; // VIRTUAL
    const tokenB = "TOKEN_B_ADDRESS"; // WETH
    const amountIn = ethers.utils.parseUnits("1.0", 18);

    console.log("Executing arbitrage...");
    const tx = await arbitrageBot.executeArbitrage(routerA, routerB, tokenA, tokenB, amountIn);
    await tx.wait();
    console.log("Arbitrage executed!");
}

main().catch((error) => {
    console.error(error);
    process.exit(1);
});
