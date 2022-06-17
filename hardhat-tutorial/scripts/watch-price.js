const hre = require("hardhat");
const ethers = hre.ethers;
const UniswapV3Pool = require("./UniswapV3Pool.json")
const NonfungiblePositionManager = require("./NonfungiblePositionManager.json")
const {BigNumber} = require("ethers");
const {address} = require("hardhat/internal/core/config/config-validation");

async function main() {
    const provider = ethers.provider;
    const poolAddr = "0x50eaEDB835021E4A108B7290636d62E9765cc6d7";
    const pool = new ethers.Contract(poolAddr, UniswapV3Pool.abi, provider);
    const managerAddress = "0xC36442b4a4522E871399CD717aBDD847Ab11FE88";
    const manager = new ethers.Contract(managerAddress, NonfungiblePositionManager.abi, provider);

    const nftPosition = 132929;
    const nftPositionInfo = await manager.positions(nftPosition)
    console.log(nftPositionInfo);

    const packed = ethers.utils.solidityPack(["address", "int24", "int24"],
        [managerAddress, nftPositionInfo.tickLower, nftPositionInfo.tickUpper])
    console.log(packed);
    const position = ethers.utils.keccak256(packed);
    console.log(position);
    console.log(await pool.positions(position));

    provider.on("block", async (blockNumber) => {
        const sqrtPriceX96 = (await pool.slot0()).sqrtPriceX96;
        const price = sqrtPriceX96.pow(2).div(BigNumber.from(2).pow(192));
        console.log(blockNumber, price.toNumber()/(10**10));
    })
}

main()
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });