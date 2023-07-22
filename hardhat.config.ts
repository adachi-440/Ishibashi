import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from 'dotenv';
import "./tasks/index";

dotenv.config();
const accounts =
  process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [];
const apiKey = process.env.INFURA_API_KEY || "";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  networks: {
    hardhat: {
    },
    mumbai: {
      chainId: 80001,
      url: `https://polygon-mumbai.infura.io/v3/${apiKey}`,
      accounts
    },
    goerli: {
      chainId: 5,
      url: `https://goerli.infura.io/v3/${apiKey}`,
      accounts
    },
    "optimism-goerli": {
      chainId: 420,
      url: `https://optimism-goerli.infura.io/v3/${apiKey}`,
      accounts
    },
    "arbitrum-goerli": {
      chainId: 421613,
      url: `https://arbitrum-goerli.infura.io/v3/${apiKey}`,
      accounts
    },
    sepolia: {
      chainId: 11155111,
      url: `https://sepolia.infura.io/v3/${apiKey}`,
      accounts
    }
  },
};

export default config;
