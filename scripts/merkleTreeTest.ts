import { ethers } from "hardhat";
import byte from "./bytes"

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
    /**
     * deploy mimcsponge contract
     */
    let result = await owner.sendTransaction({from: owner.address, data: byte})
    let hasherAddr = (await result.wait()).contractAddress; 
    console.log("Hasher address: ",hasherAddr)
    const abi = ["function MiMCSponge(uint256 , uint256 ) external pure returns (uint256 , uint256 )"];
    let hasher = await ethers.getContractAt(abi,hasherAddr);

    
    // console.log(hasher)
    const MerkleTreeWithHistory = await ethers.getContractFactory("MerkleTreeWithHistoryMock", owner);

    const merkleTree = await MerkleTreeWithHistory.deploy(8,hasherAddr);
    
    await merkleTree.deployed();

    console.log("MerkleTree address:", merkleTree.address)

    const zeroValue = await merkleTree.ZERO_VALUE()
    const firstSubtree = await merkleTree.filledSubtrees(0)
    console.log(zeroValue,ethers.BigNumber.from(firstSubtree))
}

main()








