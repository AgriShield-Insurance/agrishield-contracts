require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",
  networks: {
    anvil: {
      url: "http://localhost:8545", // RPC URL
      chainId: 99999999999
    }
  }
};
