require("@nomiclabs/hardhat-waffle");
require('dotenv').config()
require("@nomiclabs/hardhat-etherscan");


module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.17",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
      {
        version: "0.8.9",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      }
    ],
  },

  networks: {
    
    hardhat: {
      chainId: 1337
    },

    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      // gas: 300000000,
      // gasPrice: 100000000000,
      saveDeployments: true,
    },
    polygon: {
      url: process.env.POLYGON_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      saveDeployments: true,
    },
    xdai: {
      url: process.env.XDAI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      // gas: 20000000,
      // gasPrice: 100000000000,
      saveDeployments: true,
    },
    mumbai: {
      url: process.env.MUMBAI_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      gas: 200000000,
      gasPrice: 100000000000,
      saveDeployments: true,
    }

 },
 etherscan: {
  // Your API key for Etherscan
  // Obtain one at https://etherscan.io/
  apiKey: process.env.ETHERSCAN_API_KEY
}
};
