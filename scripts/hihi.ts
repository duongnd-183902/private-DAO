import { ethers } from "hardhat";
import * as circomlib from "circomlib"
import { type } from "os";
import * as utils from "../utils/index"
import * as fs from "fs";
import path from "path";
import { buffer } from "stream/consumers";

const rbigint = (nbytes: number) => {
  let r = BigInt('21888242871839275222246405745257275088548364400416034343698204186575808495617');
  return BigInt((ethers.BigNumber.from(ethers.utils.randomBytes(nbytes)).toString())) % r;
}
const pedersenHash = (data) => circomlib.babyJub.unpackPoint(circomlib.pedersenHash.hash(data))[0];
const levels: number = 12;
let Tree: utils.MerkleTree = new utils.MerkleTree(levels);

const rDeposit = (pk: [BigInt,BigInt], [_qx,_qy]) => {
  let base = circomlib.babyJub.Base8;
  let sk = rbigint(32);
  let p: any = circomlib.babyJub.mulPointEscalar(base,sk);
  let q: any = circomlib.babyJub.mulPointEscalar(pk,sk);
  let v: any = rbigint(1);
  const preimage = Buffer.concat([q[0].leInt2Buff(32), q[1].leInt2Buff(32),_qx.leInt2Buff(32),_qy.leInt2Buff(32), v.leInt2Buff(32)]);
  let commitment = pedersenHash(preimage);
  return {p,q,v,commitment}
}
const rNullifier = (pk: [BigInt, BigInt]) =>{
  let base = circomlib.babyJub.Base8;
  let sk = rbigint(32);
  let p: any = circomlib.babyJub.mulPointEscalar(base,sk);
  let q: any = circomlib.babyJub.mulPointEscalar(pk,sk);
  const preimage = Buffer.concat([q[0].leInt2Buff(32), q[1].leInt2Buff(32)]);
  let nullifierHash = pedersenHash(preimage);
  return {p,q, nullifierHash};

}
function rKeyPair(){
  let base = circomlib.babyJub.Base8;
  let sk = rbigint(32);
  let pk = circomlib.babyJub.mulPointEscalar(base,sk);
  return [sk,pk]
}
function rInput(deposit){
  
}
async function hihi(){
  let [alpha, pk] = rKeyPair();
  let input: any = {} ;
  let nullifierHashs = [];
  let recipient = (await ethers.getSigners())[10].address;
  let w =BigInt(0);
  let p = [];
  let q = [];
  let nullifierPoints = [];
  let v = [];
  let inputPathElements = [];
  let inputPathIndices = [];
  let commitment = [];
  for(let i =0 ; i< 10; ++i){
    let y = rNullifier(pk);
    let x = rDeposit(pk,y.q);
    Tree.insert(x.commitment);
    p.push(x.p);
    q.push(x.q);
    v.push(x.v)
    nullifierHashs.push(y.nullifierHash);
    nullifierPoints.push([y.q]);
    console.log(x.commitment);
  }
  for(let i =0; i< 10;++i){
    const { pathElements, pathIndices } = Tree.path(i);
    inputPathElements.push(pathElements);
    inputPathIndices.push(pathIndices);
  }
  for (let i =0; i< 10; i++){
    w = w + v[i];
  }
  input.root = Tree.root();
  input.nullifierHash = nullifierHashs;
  input.recipient = recipient;
  input.w = w;

  input.alpha = alpha;
  input.p = p;
  input.q  = q;
  input.nullifierPoint = nullifierPoints;
  input.v = v;
  input.pathElements = inputPathElements;
  input.pathIndices = inputPathIndices;
  input = utils.stringifyBigInts(input);
  let absPath = '/home/duongnd/Desktop/privDAO/scripts/input.json'
  fs.promises.writeFile(absPath, JSON.stringify(input), 'utf8');
}
// console.log(rInput(rKeyPair().pk));
hihi();
// console.log(Tree.serialize());

// function hehe(){
//   let [sk, P] = rKeyPair();
//   let packP = circomlib.babyJub.packPoint(P);
//   console.log(P);
//   console.log(packP);
//   console.log(packP.toString('hex'));
//   console.log(Buffer.from((packP.toString('hex')), 'hex'));
//   console.log(circomlib.babyJub.unpackPoint(packP));
// }
// hehe()