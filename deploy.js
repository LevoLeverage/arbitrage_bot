const hre = require("hardhat");

async function main() {
    const ArbitrageBot = await hre.ethers.getContractFactory("ArbitrageBot");
    const arbitrageBot = await ArbitrageBot.deploy();

    await arbitrageBot.deployed();

    console.log("ArbitrageBot deployed to:", arbitrageBot.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
