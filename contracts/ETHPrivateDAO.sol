
/**
 * |  _ \  |  _ \  |_ _| \ \   / /    / \    |_   _| | ____|   |  _ \     / \     / _ \ 
 * | |_) | | |_) |  | |   \ \ / /    / _ \     | |   |  _|     | | | |   / _ \   | | | |
 * |  __/  |  _ <   | |    \ V /    / ___ \    | |   | |___    | |_| |  / ___ \  | |_| |
 * |_|     |_| \_\ |___|    \_/    /_/   \_\   |_|   |_____|   |____/  /_/   \_\  \___/ 
 * *************************************************************************************
 */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import './PrivateDAO.sol';

contract ETHPrivateDAO is PrivateDAO  {
  constructor(
    IVerifier _verifier,
    IHasher _hasher,
    uint32 _merkleTreeHeight
  ) PrivateDAO(_verifier, _hasher, _merkleTreeHeight) {}

  function _processDeposit() internal override {
  }

  function _processWithdraw(
    address payable _recipient,
    uint256 _value
  ) internal override {
    // sanity checks
    require(msg.value == 0, "Message value is supposed to be zero for ETH instance");

    (bool success, ) = _recipient.call{ value: _value }("");
    require(success, "payment to _recipient did not go thru");
  }
}
