import * as path from "path";
const { exec } = require('node:child_process');

const dirnameScripts = path.dirname(__dirname);
const inputBaseDir = dirnameScripts + '/build/input/';
const witnessBaseDir = dirnameScripts + '/build/witness/';
const zkeyFileName = dirnameScripts + '/build/circuits/withdraw_cpp/withdraw_0001.zkey';
const verification_key = dirnameScripts + '/build/circuits/withdraw_cpp/verification_key.json';
const withdraw  = dirnameScripts + '/build/circuits/withdraw_cpp/withdraw'
//./multiplier2 input.json witness.wtns

for (let i = 0; i< 5; i++){
    let command = withdraw + ' ' + inputBaseDir + i.toString() + '.json ' + witnessBaseDir + i.toString() +'.wtns';
    exec(command , (e, stdout, stderr)=> {
        if (e instanceof Error) {
            console.error(e);
            throw e;
        }
        console.log(stdout);
    });
}