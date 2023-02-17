import { ethers } from "hardhat";
import * as snarkjs from "snarkjs";
import * as circomlib from "circomlib"
import MerkleTree from 'fixed-merkle-tree';
import * as path from "path";
import { dirname } from "path";
type Commit = {
  secret
  nullifier
  commitment
}
const rbigint = (nbytes: number) => BigInt((ethers.BigNumber.from(ethers.utils.randomBytes(nbytes)).toString()));
const pedersenHash = (data) => circomlib.babyJub.unpackPoint(circomlib.pedersenHash.hash(data))[0];
const toFixedHex = (number, length = 32) =>
  '0x' +
  BigInt(number)
    .toString(16)
    .padStart(length * 2, '0');


function stringifyBigInts(o) {
  if ((typeof(o) == "bigint") || (o instanceof BigInt))  {
      return o.toString(10);
  } else if (Array.isArray(o)) {
      return o.map(stringifyBigInts);
  } else if (typeof o == "object") {
      const res = {};
      for (let k in o) {
          res[k] = stringifyBigInts(o[k]);
      }
      return res;
  } else {
      return o;
  }
}


function unstringifyBigInts(o) {
  if ((typeof(o) == "string") && (/^[0-9]+$/.test(o) ))  {
      return BigInt(o);
  } else if (Array.isArray(o)) {
      return o.map(unstringifyBigInts);
  } else if (typeof o == "object" && !(o instanceof BigInt)) {
      const res = {};
      for (let k in o) {
          res[k] = unstringifyBigInts(o[k]);
      }
      return res;
  } else {
      return o;
  }
}

function generateDeposit() {
  let deposit: Commit = {
    secret: rbigint(31),
    nullifier: rbigint(31),
    commitment: undefined
  }
  const preimage = Buffer.concat([deposit.nullifier.leInt2Buff(31), deposit.secret.leInt2Buff(31)])
  deposit.commitment = pedersenHash(preimage)
  return deposit
}

// eslint-disable-next-line no-unused-vars
function BNArrayToStringArray(array) {
  const arrayToPrint = []
  array.forEach((item) => {
    arrayToPrint.push(item.toString())
  })
  return arrayToPrint
}

export {MerkleTree, pedersenHash, toFixedHex, stringifyBigInts, generateDeposit, Commit};