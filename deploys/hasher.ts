import { ethers } from "hardhat";
import byte from "../utils/bytecodeMIMC"

async function main() {
    /**
         * owner: own merkle tree 
         * MA: manager A
         * MB: manager B
         * C1: contribute partner 1
         * C2: contribute partner 2
         * C3: contribute partner 3
         */
    const [owner, MA,MB,C1,C2,C3 ] = await ethers.getSigners();
    let result = await owner.sendTransaction({from: owner.address, data: byte})
    let hasherAddr = (await result.wait()).contractAddress; 
    console.log(hasherAddr)
    // console.log(await ethers.provider.getCode(hasherAddr));
    const abi = ["function MiMCSponge(uint256 , uint256 ) external pure returns (uint256 , uint256 )"];

    let hasher = await ethers.getContractAt(abi,hasherAddr);
    console.log('MiMCSpong hash address: ', hasher.address);
    
}

main()








