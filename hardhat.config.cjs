require("@nomicfoundation/hardhat-toolbox");
require("dotenv/config");

const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

module.exports = {
  solidity: "0.8.20",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      chainId: 5312, // Match Intuition Testnet
      accounts: PRIVATE_KEY !== "" ? [PRIVATE_KEY] : []
    },
    intuition: {
      url: "https://testnet.rpc.intuition.systems/http",
      chainId: 5312,
      accounts: PRIVATE_KEY !== "" ? [PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: {
      intuition: process.env.INTUITION_API_KEY || ""
    },
    customChains: [
      {
        network: "intuition",
        chainId: 5312,
        urls: {
          apiURL: "https://testnet.explorer.intuition.systems/api",
          browserURL: "https://testnet.explorer.intuition.systems"
        }
      }
    ]
  }
};
