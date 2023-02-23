export circuits_name=tornadoUpgrade
mkdir -p ./circuits/$circuits_name
circom ../circuits/$circuits_name.circom --r1cs --c -o ./circuits/$circuits_name