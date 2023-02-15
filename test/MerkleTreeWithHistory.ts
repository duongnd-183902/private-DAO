import { expect } from "chai";
import { ethers } from "hardhat";

describe("Merkle tree with history", function (){
    async function deployMerkleTreeWithHistoryFiixture() {
        /**
         * owner: own merkle tree 
         * MA: manager A
         * MB: manager B
         * C1: contribute partner 1
         * C2: contribute partner 2
         * C3: contribute partner 3
         */
        const [owner, MA,MB,C1,C2,C3 ] = await ethers.getSigners();
        const MerkleTreeWithHistory = await ethers.getContractFactory("MerkleTreeWithHistoryMock", owner);
        // const merkleTreeWithHistory = await MerkleTreeWithHistory.deploy()
    }
})