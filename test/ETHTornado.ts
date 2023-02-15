
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";
import byte from "../scripts/bytes"

describe("ETH Tornado Cash", function (){
    async function deployETHTornadoFixture() {
        /**
         * owner: own merkle tree 
         * MA: manager A
         * MB: manager B
         * C1: contribute partner 1
         * C2: contribute partner 2
         * C3: contribute partner 3
         */
        const [owner, MA,MB,C1,C2,C3 ] = await ethers.getSigners();
        const signers = await ethers.getSigners();
        const levels = 12;
        const value = '1000000000000000000' // 1 ether
        
        /**
         * deploy MiMCsponge contract
         */
        let result = await owner.sendTransaction({from: owner.address, data: byte})
        let mimcAddr = (await result.wait()).contractAddress; 
        const mimcAbi = ["function MiMCSponge(uint256 , uint256 ) external pure returns (uint256 , uint256 )"];
        let MiMCSponge = await ethers.getContractAt(mimcAbi,mimcAddr);

        /**
         * deploy Verify contract
         */
        const VerifyFactory = await ethers.getContractFactory("Verifier",owner);
        const Verify = await VerifyFactory.deploy()
        await Verify.deployed()
        /**
         * deploy ETHTornado contract
         */
        const ETHTornadoFactory = await ethers.getContractFactory("ETHTornado", owner);
        const ETHTornado = await ETHTornadoFactory.deploy(Verify.address,MiMCSponge.address,value,levels);
        await ETHTornado.deployed()
        /**
         * Log
         */
        console.log("Owner address: ", owner.address);
        console.log("MiMCSpong contract address: ", MiMCSponge.address);
        console.log("Verify contract address: ", Verify.address);
        console.log("ETHTornado contract address: ", ETHTornado.address);
        
        return {ETHTornado, MiMCSponge,Verify, signers, value, levels};
    }
    describe("Deployment", function(){
        it("TODO", async function () {
            const{ETHTornado, Verify, MiMCSponge } = await loadFixture(deployETHTornadoFixture);
            
        })
    })
})




