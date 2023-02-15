import * as snarkjs from "snarkjs";
import * as input from "./input.json"
const fs = require("fs");


async function main() {
    console.log(snarkjs.groth16.fullProve())
}
main();



async function run() {
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(input, "circuit.wasm", "withdraw_0001.zkey");

    console.log("Proof: ");
    console.log(JSON.stringify(proof, null, 1));

    const vKey = JSON.parse(fs.readFileSync("verification_key.json"));

    const res = await snarkjs.groth16.verify(vKey, publicSignals, proof);

    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }

}

run().then(() => {
    process.exit(0);
});