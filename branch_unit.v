// ============================================================
// branch_unit.v  –  Branch Condition Evaluator
// RV32I Single-Cycle Processor  |  COA Assignment
// Description : Evaluates all six RV32I branch conditions
//               (BEQ, BNE, BLT, BGE, BLTU, BGEU) and
//               asserts branch_taken when the condition
//               is satisfied and branch is enabled.
// ============================================================
`timescale 1ns / 1ps

module branch_unit(
    input branch,
    input [2:0] branch_type,

    input [31:0] operand_a,
    input [31:0] operand_b,

    output reg branch_taken
);

// Branch types
localparam BR_BEQ  = 3'b000;
localparam BR_BNE  = 3'b001;
localparam BR_BLT  = 3'b010;
localparam BR_BGE  = 3'b011;
localparam BR_BLTU = 3'b100;
localparam BR_BGEU = 3'b101;

always @(*) begin

    // Default: branch is not taken
    branch_taken = 1'b0;

    if (branch) begin

        case (branch_type)

            // BEQ - Branch if Equal
            BR_BEQ:
                branch_taken = (operand_a == operand_b);

            // BNE - Branch if Not Equal
            BR_BNE:
                branch_taken = (operand_a != operand_b);

            // BLT - Branch if Less Than (Signed)
            BR_BLT:
                branch_taken = ($signed(operand_a) < $signed(operand_b));

            // BGE - Branch if Greater Than or Equal (Signed)
            BR_BGE:
                branch_taken = ($signed(operand_a) >= $signed(operand_b));

            // BLTU - Branch if Less Than (Unsigned)
            BR_BLTU:
                branch_taken = (operand_a < operand_b);

            // BGEU - Branch if Greater Than or Equal (Unsigned)
            BR_BGEU:
                branch_taken = (operand_a >= operand_b);

            default:
                branch_taken = 1'b0;

        endcase

    end

end

endmodule