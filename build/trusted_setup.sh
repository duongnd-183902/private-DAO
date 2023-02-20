export resource_path="./circuits/resource"
export r1cs_path="./circuits/privDAO/privDAO.r1cs"
# snarkjs powersoftau new bn128 18 $resource_path/pot18_0000.ptau -v
# snarkjs powersoftau contribute $resource_path/pot18_0000.ptau $resource_path/pot18_0001.ptau --name="First contribution" -v
# snarkjs powersoftau prepare phase2 $resource_path/pot18_0001.ptau $resource_path/pot18_final.ptau -v
# snarkjs groth16 setup $r1cs_path $resource_path/pot18_final.ptau $resource_path/privDAO_0000.zkey
snarkjs groth16 setup $r1cs_path $resource_path/powersOfTau28_hez_final_18.ptau $resource_path/privDAO_0000.zkey
snarkjs zkey contribute $resource_path/privDAO_0000.zkey $resource_path/privDAO_0001.zkey --name="1st Contributor Name" -v
snarkjs zkey export verificationkey $resource_path/privDAO_0001.zkey $resource_path/verification_key.json