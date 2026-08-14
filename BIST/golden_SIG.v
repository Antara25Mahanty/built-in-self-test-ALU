`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    golden_compare
// Description:    Compares a live MISR signature against a pre-computed golden
//                 signature and asserts pass/fail. This avoids permanently
//                 duplicating the CUT on-chip (unlike MISR_golden_sign.v, which
//                 regenerates the golden value live via a second internal ALU).
//
//                 GOLDEN_SIG must be captured once, from a known-good
//                 simulation run: run BIST_tb.v, note the final MISR value
//                 printed at $finish, and paste it in as the localparam below.
//////////////////////////////////////////////////////////////////////////////////
module golden_compare(
    input [73:0] live_signature,
    output pass
    );

    // Replace with the MISR value captured from a known-good simulation run
    localparam [73:0] GOLDEN_SIG = 74'd9274203637661242882550;

    assign pass = (live_signature == GOLDEN_SIG);

endmodule
