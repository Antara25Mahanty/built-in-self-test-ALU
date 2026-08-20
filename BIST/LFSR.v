`timescale 1ns / 1ps //1 Verilog time unit = 1 ns, and the simulator can distinguish time changes as small as 1 ps.
//////////////////////////////////////////////////////////////////////////////////
// Module Name:    LFSR_input
// Description:    8-bit GALOIS LFSR (Pseudo-Random Pattern Generator, PRPG).
//                 Feedback taps at bits 1, 4, 5. Seeds to 8'd1 on reset
//                 (never 0, since an all-zero seed would stay stuck at 0).
//////////////////////////////////////////////////////////////////////////////////
module LFSR_input(
    input wire clk,
    input wire reset,
    output reg [7:0] q
    );

    always@(posedge clk)begin
        if(reset)
            q<=8'd1;
        else begin
            q[0]<=q[7];
            q[1]<=q[0]^q[7];
            q[2]<=q[1];
            q[3]<=q[2];
            q[4]<=q[3]^q[7];
            q[5]<=q[4]^q[7];
            q[6]<=q[5];
            q[7]<=q[6];
        end
    end

endmodule
