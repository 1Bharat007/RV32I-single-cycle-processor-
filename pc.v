// ============================================================
// pc.v  –  Program Counter
// RV32I Single-Cycle Processor  |  COA Assignment
// Description : 32-bit register that holds the current PC.
//               Resets to 0x00000000 on reset.
// ============================================================
`timescale 1ns / 1ps

module pc(
    input clk,
    input reset,
    input [31:0] next_pc,

    output reg [31:0] pc
);

always @(posedge clk) begin

    if (reset)
        pc <= 32'b0;
    else
        pc <= next_pc;

end

endmodule