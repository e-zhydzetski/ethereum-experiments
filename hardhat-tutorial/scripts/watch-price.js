const hre = require("hardhat");
const ethers = hre.ethers;
const NonfungiblePositionManager = require("./NonfungiblePositionManager.json")
const UniswapV3Factory = require("./UniswapV3Factory.json")
const UniswapV3Pool = require("./UniswapV3Pool.json")
const {BigNumber} = require("ethers");
const {address} = require("hardhat/internal/core/config/config-validation");

const nftPosition = 142242;

async function main() {
    const provider = ethers.provider;
    const managerAddress = "0xC36442b4a4522E871399CD717aBDD847Ab11FE88";
    const manager = new ethers.Contract(managerAddress, NonfungiblePositionManager.abi, provider);
    const factoryAddress = await manager.factory();
    const factory = new ethers.Contract(factoryAddress, UniswapV3Factory.abi, provider);

    const nftPos = await manager.positions(nftPosition)
    console.log(nftPos);

    const poolAddr = await factory.getPool(nftPos.token0, nftPos.token1, nftPos.fee);
    const pool = new ethers.Contract(poolAddr, UniswapV3Pool.abi, provider);

    // const packed = ethers.utils.solidityPack(["address", "int24", "int24"],
    //     [managerAddress, nftPos.tickLower, nftPos.tickUpper])
    // const position = ethers.utils.keccak256(packed);
    // console.log(position);
    // console.log(await pool.positions(position));

    provider.on("block", async (blockNumber) => {
        const slot0 = await pool.slot0();
        const sqrtPriceX96 = slot0.sqrtPriceX96;
        const price = sqrtPriceX96.pow(2).div(BigNumber.from(2).pow(192));
        console.log(blockNumber, price.toNumber()/(10**10), slot0.tick);
    })
}

main()
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });