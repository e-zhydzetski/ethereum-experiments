const hre = require("hardhat");
const ethers = hre.ethers;
const NonfungiblePositionManager = require("./NonfungiblePositionManager.json")
const UniswapV3Factory = require("./UniswapV3Factory.json")
const UniswapV3Pool = require("./UniswapV3Pool.json")
const {BigNumber} = require("ethers");
const {address} = require("hardhat/internal/core/config/config-validation");

const nftPosition = 149989;

const q96 = BigNumber.from(2).pow(96);
const q128 = BigNumber.from(2).pow(128);

function getSqrtPriceX96(tick) {
    const sqrt10001e16 = "10000499987500624";
    const q32 = BigNumber.from(2).pow(32);
    const sqrt10001q128 = BigNumber.from(sqrt10001e16).mul(q128).div("10000000000000000");
    const pow = (y) => {
        if (y.eq(0)) {
            return BigNumber.from(1).mul(q128);
        }
        const t = pow(y.div(2))
        const tt = t.mul(t).div(q128);
        if (y.mod(2).eq(0)) {
            return tt;
        }
        return tt.mul(sqrt10001q128).div(q128);
    }
    return pow(tick).div(q32); //Q128 to Q96
}

async function main() {
    const provider = ethers.provider;
    const managerAddress = "0xC36442b4a4522E871399CD717aBDD847Ab11FE88";
    const manager = new ethers.Contract(managerAddress, NonfungiblePositionManager.abi, provider);
    const factoryAddress = await manager.factory();
    const factory = new ethers.Contract(factoryAddress, UniswapV3Factory.abi, provider);

    const nftPos = await manager.positions(nftPosition)
    console.log(nftPos);

    const l = nftPos.liquidity;
    let sqrtPlX96 = getSqrtPriceX96(BigNumber.from(nftPos.tickLower));
    let sqrtPuX96 = getSqrtPriceX96(BigNumber.from(nftPos.tickUpper));
    if (sqrtPuX96.lt(sqrtPlX96)) [sqrtPlX96, sqrtPuX96] = [sqrtPuX96, sqrtPlX96]; // for negative ticks
    console.log("Price low:", sqrtPlX96.div(q96).pow(2));
    console.log("Price high:", sqrtPuX96.div(q96).pow(2));
    const y0 = l.mul(sqrtPuX96.sub(sqrtPlX96)).div(q96);
    const x0 = l.mul(sqrtPuX96.sub(sqrtPlX96)).div(sqrtPuX96.mul(sqrtPlX96).div(q96));
    console.log("x0:", x0);
    console.log("y0:", y0);

    const poolAddr = await factory.getPool(nftPos.token0, nftPos.token1, nftPos.fee);
    const pool = new ethers.Contract(poolAddr, UniswapV3Pool.abi, provider);

    let curLiquidity = BigNumber.from(0);
    let curPrice = BigNumber.from(0);
    provider.on("block", async (blockNumber) => {
        // const pL = await pool.liquidity();
        // if (!pL.eq(curLiquidity)) {
        //     curLiquidity = pL;
        //     console.log(new Date().toISOString(), blockNumber, "pool liquidity", curLiquidity.toString())
        // }
        const slot0 = await pool.slot0();
        let sqrtPX96 = getSqrtPriceX96(BigNumber.from(slot0.tick));
        const price = sqrtPX96.pow(2).mul("100000000000000000").div(BigNumber.from(2).pow(192));
        if (!price.eq(curPrice)) {
            console.log(new Date().toISOString(), blockNumber, "price", price.toString());
            if (sqrtPX96.lt(sqrtPlX96)) sqrtPX96 = sqrtPlX96; else if (sqrtPX96.gt(sqrtPuX96)) sqrtPX96 = sqrtPuX96;
            curPrice = price;
            const x = l.mul(sqrtPuX96.sub(sqrtPX96)).div(sqrtPuX96.mul(sqrtPX96).div(q96));
            console.log("x:", x);
            const y = l.mul(sqrtPX96.sub(sqrtPlX96)).div(q96);
            console.log("y:", y);

            const positionID = ethers.utils.keccak256(
                ethers.utils.solidityPack(["address", "int24", "int24"],
                    [managerAddress, nftPos.tickLower, nftPos.tickUpper])
            );
            const position = await pool.positions(positionID);
            const tickL = await pool.ticks(nftPos.tickLower);
            const tickU = await pool.ticks(nftPos.tickUpper);
            // f0 and f1 calculated correctly only if current price is within position, TODO make universal func
            const f0 = (await pool.feeGrowthGlobal0X128()).sub(tickL.feeGrowthOutside0X128).sub(tickU.feeGrowthOutside0X128);
            const f1 = (await pool.feeGrowthGlobal1X128()).sub(tickL.feeGrowthOutside1X128).sub(tickU.feeGrowthOutside1X128);
            const xFee = f0.sub(position.feeGrowthInside0LastX128).mul(l).div(q128);
            const yFee = f1.sub(position.feeGrowthInside1LastX128).mul(l).div(q128);
            console.log("x fee:", xFee);
            console.log("y fee:", yFee);
        }
    })
}

main()
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });