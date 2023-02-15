import { ethers } from "hardhat";
import * as snarkjs from "snarkjs";
import * as circomlib from "circomlib"
const MerkleTree = require('fixed-merkle-tree')
const bigInt = snarkjs.bigInt
const unstringifyBigInts2 = require('snarkjs/src/stringifybigint').unstringifyBigInts
const rbigint = (nbytes) => snarkjs.bigInt.leBuff2int(ethers.utils.randomBytes(nbytes))
const pedersenHash = (data) => circomlib.babyJub.unpackPoint(circomlib.pedersenHash.hash(data))[0]
const toFixedHex = (number, length = 32) =>
  '0x' +
  bigInt(number)
    .toString(16)
    .padStart(length * 2, '0')
const websnarkUtils = require('websnark/src/utils')
const buildGroth16 = require('websnark/src/groth16')
const stringifyBigInts = require('websnark/tools/stringifybigint').stringifyBigInts
const getRandomRecipient = () => rbigint(20)
let tree;


function generateDeposit() {
  let deposit: any = {
    secret: rbigint(31),
    nullifier: rbigint(31),
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

function snarkVerify(proof) {
  proof = unstringifyBigInts2(proof)
  const verification_key = unstringifyBigInts2(require('../build/circuits/withdraw_verification_key.json'))
  return snarkjs['groth'].isValid(verification_key, proof, proof.publicSignals)
}
