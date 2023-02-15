import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: {
    compilers: [{
      version: "0.8.0" 
    },
  ],
  overrides: {
    "contracts/Mocks/verifier.sol":{
      version: "0.6.11"
    },
  }
  },
};

export default config;
