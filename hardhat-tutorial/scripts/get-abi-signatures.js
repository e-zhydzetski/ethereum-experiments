const hre = require("hardhat");
const utils = hre.ethers.utils;
const abi = require("./SwapRouter02.json").abi

async function main() {
    for (const method of abi) {
        const name = method.name;
        if (!name) {
            continue;
        }
        const inputs = method.inputs.map(input => {
            if (input.type !== "tuple") {
                return input.type;
            }
            return "("+input.components.map(component => component.type).join(",")+")";
        });
        const signature = name + "(" + inputs.join(",") + ")";
        const digest = utils.keccak256(utils.toUtf8Bytes(signature));
        console.log(signature, digest.slice(0, 10));
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });