export file_path=privDAO
mkdir -p ./circuits/$file_path
circom ../circuits/privDAO.circom --r1cs --c -o ./circuits/$file_path