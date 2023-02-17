import * as snarkjs from "snarkjs";
import * as utils from "../utils/index"
import { ethers } from "hardhat";
import * as fs from "fs";
import * as path from "path"

const dirnameScripts = path.dirname(__dirname);
const inputBaseDir = dirnameScripts + '/build/input/';
const witnessBaseDir = dirnameScripts + '/build/witness/';
const zkeyFileName = dirnameScripts + '/build/circuits/withdraw_cpp/withdraw_0001.zkey';
const verification_key = dirnameScripts + '/build/circuits/withdraw_cpp/verification_key.json';

const witnessFileName = witnessBaseDir + '2.wtns';
async function main() {
    const { proof, publicSignals } = await snarkjs.groth16.prove(zkeyFileName, witnessFileName);
    
    console.log("Proof: ");
    console.log(JSON.stringify(proof, null, 1));
    
    const vKey = JSON.parse((fs.readFileSync(verification_key)).toString());
    
    const res = await snarkjs.groth16.verify(vKey, publicSignals, proof);
    
    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }

    const s = await snarkjs.groth16.exportSolidityCallData(proof,publicSignals);
    console.log('Solidity params: ',s);
    process.exit(0);
}
main()