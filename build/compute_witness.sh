export circuit_name="tornadoUpgrade"
export circuit_name_cpp="tornadoUpgrade_cpp"
cd circuits/$circuit_name/$circuit_name_cpp
make
cd -
./circuits/$circuit_name/$circuit_name_cpp/$circuit_name ./input/input.json ./witness/witness.wtns