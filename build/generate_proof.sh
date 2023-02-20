export resource_path="./circuits/resource"
export output_path="./circuits/resource/output"
export witness_path="./witness/witness.wtns"
snarkjs groth16 prove $resource_path/privDAO_0001.zkey $witness_path $output_path/proof.json $output_path/public.json