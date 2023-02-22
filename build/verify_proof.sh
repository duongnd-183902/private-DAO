export verification_key="./circuits/resource/verification_key.json"
export public="./circuits/resource/output/public.json"
export proof="./circuits/resource/output/proof.json"
snarkjs groth16 verify $verification_key $public $proof
