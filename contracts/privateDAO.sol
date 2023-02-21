// https://tornado.cash
/*
 * d888888P                                           dP              a88888b.                   dP
 *    88                                              88             d8'   `88                   88
 *    88    .d8888b. 88d888b. 88d888b. .d8888b. .d888b88 .d8888b.    88        .d8888b. .d8888b. 88d888b.
 *    88    88'  `88 88'  `88 88'  `88 88'  `88 88'  `88 88'  `88    88        88'  `88 Y8ooooo. 88'  `88
 *    88    88.  .88 88       88    88 88.  .88 88.  .88 88.  .88 dP Y8.   .88 88.  .88       88 88    88
 *    dP    `88888P' dP       dP    dP `88888P8 `88888P8 `88888P' 88  Y88888P' `88888P8 `88888P' dP    dP
 * ooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MerkleTreeWithHistory.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
interface typesPublicInput{
    struct pubInput{
    uint256 _root;
    uint256[10] _nullifierHashs;
    uint256 _recipient;
    uint256 _value;
    }
}
interface IVerifier is typesPublicInput {
    function verifyProof(
        bytes memory _proof,
        pubInput memory _input
    ) external returns (bool);
}

abstract contract Tornado is MerkleTreeWithHistory, ReentrancyGuard, typesPublicInput {
    IVerifier public immutable verifier;
    uint256 public denomination;

    mapping(bytes32 => bool) public nullifierHashes;
    // we store all commitments just to prevent accidental deposits with the same commitment
    mapping(bytes32 => bool) public commitments;
    uint256 constant BATCH = 10;
    event Deposit(
        bytes32 indexed commitment,
        uint32 leafIndex,
        bytes32 pointP,
        bytes32 pointQ,
        bytes32 pointNullifier,
        uint256 timestamp
    );
    event Withdrawal(address to, uint256 value);

    /**
    @dev The constructor
    @param _verifier the address of SNARK verifier for this contract
    @param _hasher the address of MiMC hash contract
    @param _batch amount of node
    @param _merkleTreeHeight the height of deposits' Merkle Tree
  */
    constructor(
        IVerifier _verifier,
        IHasher _hasher,
        uint256 _batch,
        uint32 _merkleTreeHeight
    ) MerkleTreeWithHistory(_merkleTreeHeight, _hasher) {
        require(_batch > 0, "BATCH should be greater than 0");
        verifier = _verifier;
    }

    /**
    @dev Deposit funds into the contract. The caller must send (for ETH) or approve (for ERC20) value equal to or `denomination` of this instance.
    @param _commitment the note commitment, which is PedersenHash(nullifier + secret)
  */
    function deposit(
        bytes32 _commitment,
        bytes32 _pointP,
        bytes32 _pointQ,
        bytes32 _pointNullifider
    ) external payable nonReentrant {
        require(!commitments[_commitment], "The commitment has been submitted");

        uint32 insertedIndex = _insert(_commitment);
        commitments[_commitment] = true;
        _processDeposit();

        emit Deposit(
            _commitment,
            insertedIndex,
            _pointP,
            _pointQ,
            _pointNullifider,
            block.timestamp
        );
    }

    /** @dev this function is defined in a child contract */
    function _processDeposit() internal virtual;

    /**
    @dev Withdraw a deposit from the contract. `proof` is a zkSNARK proof data, and input is an array of circuit public inputs
    `input` array consists of:
      - merkle root of all deposits in the contract
      - hash of unique deposit nullifier to prevent double spends
      - the recipient of funds
      - optional fee that goes to the transaction sender (usually a relay)
  */
    function withdraw(
        bytes calldata _proof,
        bytes32 _root,
        bytes32[10] calldata _nullifierHashs,
        address payable _recipient,
        uint256 _value
    ) external payable nonReentrant {
        for (uint256 i = 0; i < BATCH; i++) {
            require(
                !nullifierHashes[_nullifierHashs[i]],
                "The note has been already spent"
            );
        }
        require(isKnownRoot(_root), "Cannot find your merkle root"); // Make sure to use a recent one
        pubInput memory publicInput  = pubInput(uint256(_root), bytesArray2uintArray(_nullifierHashs), uint256(uint160(address(_recipient))),_value);
        require(
            verifier.verifyProof(
                _proof,
                publicInput
            ),
            "Invalid withdraw proof"
        );
        for(uint256 i = 0; i< BATCH ; i++){
        nullifierHashes[_nullifierHashs[i]] = true;
        }
        _processWithdraw(_recipient, _value);
        emit Withdrawal(_recipient, _value);
    }

    /** @dev this function is defined in a child contract */
    function _processWithdraw(
        address payable _recipient,
        uint256 _value
    ) internal virtual;

    /** @dev whether a note is already spent */
    function isSpent(bytes32 _nullifierHash) public view returns (bool) {
        return nullifierHashes[_nullifierHash];
    }

    /** @dev whether an array of notes is already spent */
    function isSpentArray(
        bytes32[] calldata _nullifierHashes
    ) external view returns (bool[] memory spent) {
        spent = new bool[](_nullifierHashes.length);
        for (uint256 i = 0; i < _nullifierHashes.length; i++) {
            if (isSpent(_nullifierHashes[i])) {
                spent[i] = true;
            }
        }
    }
    function bytesArray2uintArray(bytes32[10] calldata _arr) public pure returns (uint256[10] memory arr){
      for(uint256 i = 0 ; i< _arr.length; i++){
        arr[i] = uint256(_arr[i]);
      }
    }
}
