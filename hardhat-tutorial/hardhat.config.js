require("@nomiclabs/hardhat-waffle");
require("solidity-coverage");
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.8.9",
  networks: {
    hardhat: {
    },
    polygon: {
      url: "https://polygon-rpc.com",
      chainId: 137,
    }
  },
};
