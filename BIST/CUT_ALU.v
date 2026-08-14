`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    CUT_ALU
// Description:    Circuit Under Test (CUT). 8-bit ALU computing add, subtract,
//                 multiply, XOR, XNOR, NAND, and logical shifts on two
//                 consecutive LFSR-generated pseudo-random operands (q, q_past).
//                 Instantiates its own LFSR_input to self-generate stimulus.
//////////////////////////////////////////////////////////////////////////////////
module CUT_ALU(
    input wire clk,
    input wire reset,
    output reg [7:0]sum,
    output reg cout,
    output reg [7:0]sub,
    output reg borrow,
    output reg [15:0] mul,
    output reg [7:0] out_xor,
    output reg [7:0] out_xnor,
    output reg [7:0] out_NAND,
    output reg [7:0] out_LL,
    output reg [7:0] out_LR
    );

    wire [7:0] w;
    LFSR_input a0(.clk(clk),.reset(reset),.q(w));
    reg [7:0] q,q_past;
    initial begin
        q_past=8'd0;
        q=8'd0;
    end

    always@(posedge clk)begin
        if(reset)begin
            sum<=8'd0;
            cout<=1'd0;
            sub<=8'd0;
            borrow<=1'd0;
            mul<=16'd0;
            out_xor<=8'd0;
            out_xnor<=8'd0;
            out_NAND<=8'd0;
            out_LL<=8'd0;
            out_LR<=8'd0;
        end
        else begin
            q<=w;
            {cout,sum}<=q+q_past;
            {borrow,sub}<=q-q_past;
            mul<=q*q_past;
            out_xor<=q^q_past;
            out_xnor<=~(q^q_past);
            out_NAND<=~(q&q_past);
            out_LL<=q<<2;
            out_LR<=q>>2;

            q_past<=q;
        end
    end

endmodule
