`timescale 1ns / 1ps

module adder4 (carryin, X, Y, S, carryout);
    input carryin;
    input [3:0] X, Y;
    output [3:0] S;
    output carryout;
    wire [3:1] C;
    fulladder stage0 (1'b0, X[0], Y[0], S[0], C[1]);
    fulladder stage1 (C[1], X[1], Y[1], S[1], C[2]);
    fulladder stage2 (C[2], X[2], Y[2], S[2], C[3]);
    fulladder stage3 (C[3], X[3], Y[3], S[3], carryout);
endmodule 

module fulladder (Cin, x, y, s, Cout);
    input Cin, x, y;
    output s, Cout;
    assign s = x ^ y ^ Cin;
    assign Cout = (x & y) | (x & Cin) | (y & Cin);
endmodule  