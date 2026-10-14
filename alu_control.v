// ============================================================
// alu_control.v  –  ALU Control Unit
// RV32I Single-Cycle Processor  |  COA Assignment
// Description : Decodes the ALU operation code (from the
//               main control unit) together with funct3 and
//               funct7 to produce the 4-bit ALU control
//               signal used by alu.v.
// ============================================================
`timescale 1ns / 1ps

module alu_control(
    input [2:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg [3:0] alu_control
);

// ALU control codes
localparam ALU_ADD     = 4'b0000;
localparam ALU_SUB     = 4'b0001;
localparam ALU_SLL     = 4'b0010;
localparam ALU_SLT     = 4'b0011;
localparam ALU_SLTU    = 4'b0100;
localparam ALU_XOR     = 4'b0101;
localparam ALU_SRL     = 4'b0110;
localparam ALU_SRA     = 4'b0111;
localparam ALU_OR      = 4'b1000;
localparam ALU_AND     = 4'b1001;
localparam ALU_PASS_B  = 4'b1010;

// ALU operation types from Control Unit
localparam ALU_OP_R      = 3'b000;
localparam ALU_OP_I      = 3'b001;
localparam ALU_OP_BRANCH = 3'b010;
localparam ALU_OP_ADD    = 3'b011;
localparam ALU_OP_PASS_B = 3'b100;

always @(*) begin

    // Default operation
    alu_control = ALU_ADD;

    case (alu_op)

        // ----------------------------------------
        // R-type instructions
        // ----------------------------------------
        ALU_OP_R: begin

            case (funct3)

                // ADD / SUB
                3'b000: begin
                    if (funct7[5] == 1'b1)
                        alu_control = ALU_SUB;
                    else
                        alu_control = ALU_ADD;
                end

                // SLL
                3'b001:
                    alu_control = ALU_SLL;

                // SLT
                3'b010:
                    alu_control = ALU_SLT;

                // SLTU
                3'b011:
                    alu_control = ALU_SLTU;

                // XOR
                3'b100:
                    alu_control = ALU_XOR;

                // SRL / SRA
                3'b101: begin
                    if (funct7[5] == 1'b1)
                        alu_control = ALU_SRA;
                    else
                        alu_control = ALU_SRL;
                end

                // OR
                3'b110:
                    alu_control = ALU_OR;

                // AND
                3'b111:
                    alu_control = ALU_AND;

                default:
                    alu_control = ALU_ADD;

            endcase

        end

        // ----------------------------------------
        // I-type arithmetic
        // ----------------------------------------
        ALU_OP_I: begin

            case (funct3)

                // ADDI
                3'b000:
                    alu_control = ALU_ADD;

                // SLLI
                3'b001:
                    alu_control = ALU_SLL;

                // SLTI
                3'b010:
                    alu_control = ALU_SLT;

                // SLTIU
                3'b011:
                    alu_control = ALU_SLTU;

                // XORI
                3'b100:
                    alu_control = ALU_XOR;

                // SRLI / SRAI
                3'b101: begin
                    if (funct7[5] == 1'b1)
                        alu_control = ALU_SRA;
                    else
                        alu_control = ALU_SRL;
                end

                // ORI
                3'b110:
                    alu_control = ALU_OR;

                // ANDI
                3'b111:
                    alu_control = ALU_AND;

                default:
                    alu_control = ALU_ADD;

            endcase

        end

        // ----------------------------------------
        // Branch instructions
        // ----------------------------------------
        ALU_OP_BRANCH:
            alu_control = ALU_SUB;

        // ----------------------------------------
        // Address calculation
        // Loads, Stores, AUIPC, JAL
        // ----------------------------------------
        ALU_OP_ADD:
            alu_control = ALU_ADD;

        // ----------------------------------------
        // LUI
        // ----------------------------------------
        ALU_OP_PASS_B:
            alu_control = ALU_PASS_B;

        default:
            alu_control = ALU_ADD;

    endcase

end

endmodule