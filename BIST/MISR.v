`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    MISR_golden_sign
// Description:    74-bit Multiple Input Signature Register (MISR).
//                 Instantiates its own CUT_ALU, concatenates all ALU outputs
//                 into a 74-bit vector (MISR_in), and compacts it cycle by
//                 cycle into a single 74-bit signature using an XOR shift
//                 chain with feedback taps at bit positions 58, 59, and 73.
//
//                 NOTE: this module regenerates a "golden" signature live by
//                 running its own internal copy of CUT_ALU. This is a valid
//                 way to demonstrate signature analysis in simulation, but a
//                 production BIST design would instead store one pre-computed
//                 golden signature as a constant and compare against it,
//                 rather than duplicating the CUT permanently on-chip.
//                 See golden_compare.v for that alternative approach.
//////////////////////////////////////////////////////////////////////////////////
module MISR_golden_sign(
    input clk,
    input reset,
    output reg[73:0] MISR
    );

    wire [7:0]sum;
    wire cout;
    wire [7:0]sub;
    wire borrow;
    wire [15:0] mul;
    wire [7:0] out_xor;
    wire [7:0] out_xnor;
    wire [7:0] out_NAND;
    wire [7:0] out_LL;
    wire [7:0] out_LR;


    CUT_ALU misr_in(.clk(clk),.reset(reset),
             .sum(sum),
             .cout(cout),
             .sub(sub),
             .borrow(borrow),
             .mul(mul),
             .out_xor(out_xor),
             .out_xnor(out_xnor),
             .out_NAND(out_NAND),
             .out_LL(out_LL),
             .out_LR(out_LR)
             );

    wire [73:0] MISR_in;
    assign MISR_in={sum,cout,sub,borrow,mul,out_xor,out_xnor,out_NAND,out_LL,out_LR};

    initial MISR=74'd0;

    wire [73:0] w1;
    // Cell 0 wraps around: its "previous cell" input is the last cell, w1[73]
    shifter_2 C0(.a(MISR_in[0]),.b(w1[73]),.c(w1[0]),.clk(clk),.reset(reset));

    genvar i;
    generate
    for(i=1;i<=73;i=i+1) begin: gen_loop
        if(i==58||i==59||i==73) begin:fb_loop
            // Feedback-tap cells: fold in w1[73] a second time (linear feedback)
            shifter_3 Ci(.a(MISR_in[i]),.b(w1[i-1]),.fb(w1[73]),.c(w1[i]),.clk(clk),.reset(reset));
        end
        else begin:norm_loop
            // Plain cells: shift + XOR with incoming CUT bit, no feedback
            shifter_2 C1(.a(MISR_in[i]),.b(w1[i-1]),.c(w1[i]),.clk(clk),.reset(reset));
        end
    end
    endgenerate


    always@(posedge clk)begin
        if(reset)
            MISR<=74'd0;
        else
            MISR<=w1;
    end

endmodule

module shifter_2(
    input a,
    input b,
    input clk,
    input reset,
    output reg c
    );

    always@(posedge clk)begin
        if(reset)
            c<=1'b0;
        else
            c<=a^b;
    end

endmodule

module shifter_3(
    input a,
    input b,
    input fb,
    input reset,
    input clk,
    output reg c
    );

    always@(posedge clk)begin
        if(reset)
            c<=1'b0;
        else
            c<=a^b^fb;
    end

endmodule
