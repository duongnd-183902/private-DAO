pragma circom 2.1.3;

include "../node_modules/circomlib/circuits/pedersen.circom";
include "../node_modules/circomlib/circuits/escalarmulany.circom";

template CommitmentHasher(){
    signal input p[2];
    signal input q[2];
    signal input v;

    signal output commitment;

    component commitmentHasher = Pedersen(1280);
    component pxBits = Num2Bits(256);
    component pyBits = Num2Bits(256);
    component qxBits = Num2Bits(256);
    component qyBits = Num2Bits(256);
    component vBits = Num2Bits(256);

    pxBits.in <== p[0];
    pyBits.in <== p[1];
    qxBits.in <== q[0];
    qyBits.in <== q[1];
    vBits.in <== v;

    for (var i = 0; i < 256; i++){
        commitmentHasher.in[i] <== pxBits.out[i];
        commitmentHasher.in[i + 256] <== pyBits.out[i];
        commitmentHasher.in[i + 512] <== qxBits.out[i];
        commitmentHasher.in[i + 768] <== qyBits.out[i];
        commitmentHasher.in[i + 1024] <== vBits.out[i];
    }

    commitment <== commitmentHasher.out[0];
}

template Withdrawi() {
    signal input alpha;
    signal input p[2];
    signal input q[2];
    signal input v
    

    component escalarMulAny = EscalarMulAny(256);
    component alphaBits = Num2Bits(256);
    alphaBits.in <== alpha;
    escalarMulAny.p[0] <== p[0];
    escalarMulAny.p[1] <== p[1];

    for (var i = 0; i < 256; i++){
        escalarMulAny.e[i] <== alphaBits.out[i];
    }

    q[0] === escalarMulAny.out[0];
    q[1] === escalarMulAny.out[1];
}

component main {public [p, q, v]} = Withdrawi();
