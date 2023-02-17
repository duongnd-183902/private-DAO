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

const levels: number = 12;
let Tree: utils.MerkleTree = new utils.MerkleTree(levels);

function sampleInput(fee: string, refund: string, recipient: string, relayer: string, deposit: utils.Commit, index: number) {
    Tree.insert(deposit.commitment)
    const { pathElements, pathIndices } = Tree.path(index);

    const input = utils.stringifyBigInts({
        root: Tree.root(),
        nullifierHash: utils.pedersenHash(deposit.nullifier.leInt2Buff(31)),
        nullifier: deposit.nullifier,
        relayer: relayer,
        recipient,
        fee,
        refund,
        secret: deposit.secret,
        pathElements: pathElements,
        pathIndices: pathIndices,
        })
    let absPath = inputBaseDir + index.toString() + '.json';
    fs.promises.writeFile(absPath, JSON.stringify(input), 'utf8');
    
}


async function hihi() {
    let signers = await ethers.getSigners();
    const fee = BigInt(1e17).toString();
    const refund = BigInt(0).toString();
    for(let i = 0; i< 5; i++){
        let deposit = utils.generateDeposit();
        sampleInput(fee,refund,signers[1].address,signers[10].address, deposit, i);
        console.log('sample input ', i, ' done.');
    }
}

hihi()