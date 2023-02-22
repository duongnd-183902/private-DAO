pragma circom 2.1.3;

include "../node_modules/circomlib/circuits/pedersen.circom";
include "../node_modules/circomlib/circuits/escalarmulany.circom";
include "merkleTree.circom";

template CommitmentHasher(){
    signal input nullifierPoint[2];
    signal input q[2];
    signal input v;
    
    signal output commitment;
    signal output nullifierHash;

    component commitmentHasher = Pedersen(1280);
    component nullifierHasher = Pedersen(512);
    component qxBits = Num2Bits(256);
    component qyBits = Num2Bits(256);
    component nullifierPointXBits = Num2Bits(256);
    component nullifierPointYBits = Num2Bits(256);
    component vBits = Num2Bits(256);
    
    qxBits.in <== q[0];
    qyBits.in <== q[1];
    nullifierPointXBits.in <== nullifierPoint[0];
    nullifierPointYBits.in <== nullifierPoint[1];
    vBits.in <== v;

    for (var i = 0; i < 256; i++){
        commitmentHasher.in[i] <== qxBits.out[i];
        commitmentHasher.in[i + 256] <== qyBits.out[i];
        commitmentHasher.in[i + 512] <== nullifierPointXBits.out[i];
        commitmentHasher.in[i + 768] <== nullifierPointYBits.out[i];
        commitmentHasher.in[i + 1024] <== vBits.out[i];
        nullifierHasher.in[i] <== nullifierPointXBits.out[i];
        nullifierHasher.in[i+256] <== nullifierPointYBits.out[i];
    }

    commitment <== commitmentHasher.out[0];
    nullifierHash <== nullifierHasher.out[0];
}

template Withdrawi(levels) {
    signal input root;
    signal input alpha;
    signal input p[2];
    signal input q[2];
    signal input nullifierPoint[2];
    signal input nullifierHash;
    signal input v;
    signal input pathElements[levels];
    signal input pathIndices[levels];
    
    component alphaBits = Num2Bits(256);
    alphaBits.in <== alpha;

    component escalarMulAny = EscalarMulAny(256);
    escalarMulAny.p[0] <== p[0];
    escalarMulAny.p[1] <== p[1];

    for (var i = 0; i < 256; i++){
        escalarMulAny.e[i] <== alphaBits.out[i];
    }

    q[0] === escalarMulAny.out[0];
    q[1] === escalarMulAny.out[1];

    component hasher = CommitmentHasher();
    hasher.q[0] <== q[0];
    hasher.q[1] <== q[1];
    hasher.nullifierPoint[0] <== nullifierPoint[0];
    hasher.nullifierPoint[1] <== nullifierPoint[1];
    hasher.v <== v;

    hasher.nullifierHash === nullifierHash;

    component tree = MerkleTreeChecker(levels);
    tree.root <== root;
    tree.leaf <== hasher.commitment;
    for (var i = 0; i < levels; i++) {
        tree.pathElements[i] <== pathElements[i];
        tree.pathIndices[i] <== pathIndices[i];
    }
}

template Withdraw(levels){
    // public input
    signal input root;
    signal input nullifierHash[10];
    signal input recipient; 
    signal input w;

    // private input
    signal input alpha;
    signal input p[10][2];
    signal input q[10][2];
    signal input nullifierPoint[10][2];
    signal input v[10];
    signal input pathElements[10][levels];
    signal input pathIndices[10][levels];
    

    var sumV = 0;
    for (var i = 0; i < 10; i++){
        sumV += v[i];
    }
    
    w === sumV;

    component withdraw0 = Withdrawi(levels);
    withdraw0.root <== root;
    withdraw0.alpha <== alpha;
    withdraw0.nullifierPoint[0] <== nullifierPoint[0][0];
    withdraw0.nullifierPoint[1] <== nullifierPoint[0][1];
    withdraw0.nullifierHash <== nullifierHash[0];
    withdraw0.p[0] <== p[0][0];
    withdraw0.p[1] <== p[0][1];
    withdraw0.q[0] <== q[0][0];
    withdraw0.q[1] <== q[0][1];
    withdraw0.v <== v[0];
    withdraw0.pathElements <== pathElements[0];
    withdraw0.pathIndices <== pathIndices[0];

    component withdraw1 = Withdrawi(levels);
    withdraw1.root <== root;
    withdraw1.alpha <== alpha;
    withdraw1.nullifierPoint[0] <== nullifierPoint[1][0];
    withdraw1.nullifierPoint[1] <== nullifierPoint[1][1];
    withdraw1.nullifierHash <== nullifierHash[1];
    withdraw1.p[0] <== p[1][0];
    withdraw1.p[1] <== p[1][1];
    withdraw1.q[0] <== q[1][0];
    withdraw1.q[1] <== q[1][1];
    withdraw1.v <== v[1];
    withdraw1.pathElements <== pathElements[1];
    withdraw1.pathIndices <== pathIndices[1];
    
    component withdraw2 = Withdrawi(levels);
    withdraw2.root <== root;
    withdraw2.alpha <== alpha;
    withdraw2.nullifierPoint[0] <== nullifierPoint[2][0];
    withdraw2.nullifierPoint[1] <== nullifierPoint[2][1];
    withdraw2.nullifierHash <== nullifierHash[2];
    withdraw2.p[0] <== p[2][0];
    withdraw2.p[1] <== p[2][1];
    withdraw2.q[0] <== q[2][0];
    withdraw2.q[1] <== q[2][1];
    withdraw2.v <== v[2];
    withdraw2.pathElements <== pathElements[2];
    withdraw2.pathIndices <== pathIndices[2];

    component withdraw3 = Withdrawi(levels);
    withdraw3.root <== root;
    withdraw3.alpha <== alpha;
    withdraw3.nullifierPoint[0] <== nullifierPoint[3][0];
    withdraw3.nullifierPoint[1] <== nullifierPoint[3][1];
    withdraw3.nullifierHash <== nullifierHash[3];
    withdraw3.p[0] <== p[3][0];
    withdraw3.p[1] <== p[3][1];
    withdraw3.q[0] <== q[3][0];
    withdraw3.q[1] <== q[3][1];
    withdraw3.v <== v[3];
    withdraw3.pathElements <== pathElements[3];
    withdraw3.pathIndices <== pathIndices[3];

    component withdraw4 = Withdrawi(levels);
    withdraw4.root <== root;
    withdraw4.alpha <== alpha;
    withdraw4.nullifierPoint[0] <== nullifierPoint[4][0];
    withdraw4.nullifierPoint[1] <== nullifierPoint[4][1];
    withdraw4.nullifierHash <== nullifierHash[4];
    withdraw4.p[0] <== p[4][0];
    withdraw4.p[1] <== p[4][1];
    withdraw4.q[0] <== q[4][0];
    withdraw4.q[1] <== q[4][1];
    withdraw4.v <== v[4];
    withdraw4.pathElements <== pathElements[4];
    withdraw4.pathIndices <== pathIndices[4];

    component withdraw5 = Withdrawi(levels);
    withdraw5.root <== root;
    withdraw5.alpha <== alpha;
    withdraw5.nullifierPoint[0] <== nullifierPoint[5][0];
    withdraw5.nullifierPoint[1] <== nullifierPoint[5][1];
    withdraw5.nullifierHash <== nullifierHash[5];
    withdraw5.p[0] <== p[5][0];
    withdraw5.p[1] <== p[5][1];
    withdraw5.q[0] <== q[5][0];
    withdraw5.q[1] <== q[5][1];
    withdraw5.v <== v[5];
    withdraw5.pathElements <== pathElements[5];
    withdraw5.pathIndices <== pathIndices[5];

    component withdraw6 = Withdrawi(levels);
    withdraw6.root <== root;
    withdraw6.alpha <== alpha;
    withdraw6.nullifierPoint[0] <== nullifierPoint[6][0];
    withdraw6.nullifierPoint[1] <== nullifierPoint[6][1];
    withdraw6.nullifierHash <== nullifierHash[6];
    withdraw6.p[0] <== p[6][0];
    withdraw6.p[1] <== p[6][1];
    withdraw6.q[0] <== q[6][0];
    withdraw6.q[1] <== q[6][1];
    withdraw6.v <== v[6];
    withdraw6.pathElements <== pathElements[6];
    withdraw6.pathIndices <== pathIndices[6];

    component withdraw7 = Withdrawi(levels);
    withdraw7.root <== root;
    withdraw7.alpha <== alpha;
    withdraw7.nullifierPoint[0] <== nullifierPoint[7][0];
    withdraw7.nullifierPoint[1] <== nullifierPoint[7][1];
    withdraw7.nullifierHash <== nullifierHash[7];
    withdraw7.p[0] <== p[7][0];
    withdraw7.p[1] <== p[7][1];
    withdraw7.q[0] <== q[7][0];
    withdraw7.q[1] <== q[7][1];
    withdraw7.v <== v[7];
    withdraw7.pathElements <== pathElements[7];
    withdraw7.pathIndices <== pathIndices[7];

    component withdraw8 = Withdrawi(levels);
    withdraw8.root <== root;
    withdraw8.alpha <== alpha;
    withdraw8.nullifierPoint[0] <== nullifierPoint[8][0];
    withdraw8.nullifierPoint[1] <== nullifierPoint[8][1];
    withdraw8.nullifierHash <== nullifierHash[8];
    withdraw8.p[0] <== p[8][0];
    withdraw8.p[1] <== p[8][1];
    withdraw8.q[0] <== q[8][0];
    withdraw8.q[1] <== q[8][1];
    withdraw8.v <== v[8];
    withdraw8.pathElements <== pathElements[8];
    withdraw8.pathIndices <== pathIndices[8];

    component withdraw9 = Withdrawi(levels);
    withdraw9.root <== root;
    withdraw9.alpha <== alpha;
    withdraw9.nullifierPoint[0] <== nullifierPoint[9][0];
    withdraw9.nullifierPoint[1] <== nullifierPoint[9][1];
    withdraw9.nullifierHash <== nullifierHash[9];
    withdraw9.p[0] <== p[9][0];
    withdraw9.p[1] <== p[9][1];
    withdraw9.q[0] <== q[9][0];
    withdraw9.q[1] <== q[9][1];
    withdraw9.v <== v[9];
    withdraw9.pathElements <== pathElements[9];
    withdraw9.pathIndices <== pathIndices[9];

    // Add hidden signals to make sure that tampering with recipient or fee will invalidate the snark proof
    // Most likely it is not required, but it's better to stay on the safe side and it only takes 2 constraints
    // Squares are used to prevent optimizer from removing those constraints
    signal recipientSquare;
    recipientSquare <== recipient * recipient;
}

component main {public [root, nullifierHash,recipient, w]} = Withdraw(12);
