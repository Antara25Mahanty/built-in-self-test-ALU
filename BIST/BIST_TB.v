`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Module Name:   BIST_tb
// Description:   Top-level testbench. Instantiates the LFSR (standalone, for
//                observation), the CUT_ALU, and the MISR signature analyzer,
//                drives a 10 ns-period clock, and monitors the LFSR pattern
//                and MISR signature over a 500 ns run.
////////////////////////////////////////////////////////////////////////////////

module BIST_tb;

    // Inputs
    reg clk;
    reg reset;

    // Outputs
    wire [7:0] q;
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
    wire [73:0] MISR;
    wire pass;

    // Standalone LFSR instance, purely for observation via $monitor
    LFSR_input uut (
        .clk(clk),
        .reset(reset),
        .q(q)
    );

    // Circuit Under Test
    CUT_ALU test(.clk(clk),.reset(reset),
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

    // Response compactor
    MISR_golden_sign sign(.clk(clk),.reset(reset),.MISR(MISR));

    // Pass/fail comparator against a pre-captured golden signature
    golden_compare cmp(.live_signature(MISR), .pass(pass));

    initial clk=0;
    always #5 clk=~clk;

    initial begin
        reset = 1;
        #10 reset=0;

        $monitor("t=%0t | q=%d | MISR=%d | pass=%b",$time,q,MISR,pass);

        #200;

        $display("Final signature at t=%0t: MISR=%d", $time, MISR);
        $finish;

    end

endmodule
