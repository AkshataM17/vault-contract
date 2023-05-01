require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({path: ".env"});

const ALCHEMY_HTTP_URL = process.env.ALCHEMY_HTTP_URL;
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ETHERCSCAN_API_KEY = process.env.ETHERCSCAN_API_KEY;
const ALCHEMY_MUMBAI_URL = process.env.ALCHEMY_MUMBAI_URL;
const POLYGON_API_KEY = process.env.POLYGON_API_KEY;

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.13",
  networks : {
    goerli : {
      url: ALCHEMY_HTTP_URL,
      accounts: [PRIVATE_KEY],
    },
    mumbai: {
      url: ALCHEMY_MUMBAI_URL,
      accounts: [PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: ETHERCSCAN_API_KEY,
  },
  
};

