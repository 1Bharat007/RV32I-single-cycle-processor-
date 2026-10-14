// ============================================================
// next_pc.v  –  Next Program Counter Logic
// RV32I Single-Cycle Processor  |  COA Assignment
// Description : Selects the next PC value among:
//               PC+4  (sequential),
//               PC + branch_imm  (taken branch),
//               PC + jump_imm    (JAL),
//               rs1 + jalr_imm   (JALR, LSB cleared).
// ============================================================
`timescale 1ns / 1ps

module next_pc(
    input [31:0] pc,

    input [31:0] branch_immediate,
    input [31:0] jump_immediate,
    input [31:0] jalr_immediate,

    input [31:0] rs1_value,

    input branch,
    input branch_taken,
    input jump,
    input jalr,

    output reg [31:0] next_pc
);

always @(*) begin

    // Default: normal sequential execution
    next_pc = pc + 32'd4;

    // Taken branch
    if (branch && branch_taken)
        next_pc = pc + branch_immediate;

    // JAL
    if (jump)
        next_pc = pc + jump_immediate;

    // JALR
    if (jalr)
        next_pc = (rs1_value + jalr_immediate) & 32'hFFFFFFFE;

end

endmodule