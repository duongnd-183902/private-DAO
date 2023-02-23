pragma circom 2.1.3;

include "../node_modules/circomlib/circuits/pedersen.circom";
include "../node_modules/circomlib/circuits/escalarmulany.circom";
include "merkleTree.circom";


template CommitmentHasher(){
    signal input nullifierPoint[2];
    signal input totalDeposit;
    
    signal output commitment;
    signal output nullifierHash;

    component commitmentHasher = Pedersen(768);
    component nullifierHasher = Pedersen(512);

    component nullifierPointXBits = Num2Bits(256);
    component nullifierPointYBits = Num2Bits(256);
    component totalDepositBits = Num2Bits(256);
    
    nullifierPointXBits.in <== nullifierPoint[0];
    nullifierPointYBits.in <== nullifierPoint[1];
    totalDepositBits.in <== totalDeposit;

    for (var i = 0; i < 256; i++){
        commitmentHasher.in[i ] <== nullifierPointXBits.out[i];
        commitmentHasher.in[i + 256] <== nullifierPointYBits.out[i];
        commitmentHasher.in[i + 512] <== totalDepositBits.out[i];

        nullifierHasher.in[i] <== nullifierPointXBits.out[i];
        nullifierHasher.in[i+256] <== nullifierPointYBits.out[i];
    }

    commitment <== commitmentHasher.out[0];
    nullifierHash <== nullifierHasher.out[0];
}

template Withdraw(levels) {
    var oneHundredPercent = 10**18;

    // public input
    signal input root;
    signal input nullifierHash;
    signal input oldSpentPointX;

    // private input 
    signal input nullifierPoint[2];
    signal input totalDeposit;
    signal input oldSpentPart;
    signal input newSpentPart;
    signal input pathElements[levels];
    signal input pathIndices[levels];

    // public output
    signal output withdrawAmount;
    signal output newSpentPointX;

    var tmp = (oldSpentPart == 0 && oldSpentPointX == 0) || (oldSpentPart != 0 && oldSpentPointX != 0) ? 1: 0;
    signal isValid <-- tmp;
    isValid === 1;

    component hasher = CommitmentHasher();
    hasher.nullifierPoint[0] <== nullifierPoint[0];
    hasher.nullifierPoint[1] <== nullifierPoint[1];
    hasher.totalDeposit <== totalDeposit;

    hasher.nullifierHash === nullifierHash;

    component tree = MerkleTreeChecker(levels);
    tree.root <== root;
    tree.leaf <== hasher.commitment;
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }

    component oldSpentPartHasher = Pedersen(256);
    component oldSpentPartBits = Num2Bits(256);
    oldSpentPartBits.in <== oldSpentPart;
    for( var i = 0; i < 256; i++){
        oldSpentPartHasher.in[i] <== oldSpentPartBits.out[i];
    }

    component oldSpentEscalarMulAny = EscalarMulAny(256);
    oldSpentEscalarMulAny.p[0] <== nullifierPoint[0];
    oldSpentEscalarMulAny.p[1] <== nullifierPoint[1];
    component oldSpentPartHashBits = Num2Bits(256);
    oldSpentPartHashBits.in <== oldSpentPartHasher.out[0];
    for (var i = 0; i < 256; i++){
        oldSpentEscalarMulAny.e[i] <== oldSpentPartHashBits.out[i];
    }
    oldSpentPointX === oldSpentEscalarMulAny.out[0];
    
    tmp = newSpentPart <= oneHundredPercent ? 1: 0;
    signal isWithdrawable <-- tmp;
    isWithdrawable === 1;
    withdrawAmount <== (newSpentPart - oldSpentPart) * totalDeposit / oneHundredPercent;

    
    component newSpentPartHasher = Pedersen(256);
    component newSpentPartBits = Num2Bits(256);
    newSpentPartBits.in <== newSpentPart;
    for( var i = 0; i < 256; i++){
        newSpentPartHasher.in[i] <== newSpentPartBits.out[i];
    }

    component newSpentEscalarMulAny = EscalarMulAny(256);
    newSpentEscalarMulAny.p[0] <== nullifierPoint[0];
    newSpentEscalarMulAny.p[1] <== nullifierPoint[1];
    component newSpentPartHashBits = Num2Bits(256);
    newSpentPartHashBits.in <== newSpentPartHasher.out[0];
    for (var i = 0; i < 256; i++){
        newSpentEscalarMulAny.e[i] <== newSpentPartHashBits.out[i];
    }
    newSpentPointX <== newSpentEscalarMulAny.out[0];
}

component main {public [root, nullifierHash, oldSpentPointX]} = Withdraw(32);