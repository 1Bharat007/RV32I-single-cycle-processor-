// ============================================================
// control_unit.v  –  Main Control Unit
// RV32I Single-Cycle Processor  |  COA Assignment
// Description : Decodes the 7-bit opcode (and funct3 for
//               loads/stores/branches) to generate all
//               datapath control signals: reg_write, alu_src,
//               alu_a_src, mem_read/write, branch/jump/jalr,
//               writeback_sel, imm_type, alu_op,
//               mem_control, branch_type.
// Supported instructions:
//   R-type, I-type arith, Loads, Stores, Branches,
//   JAL, JALR, LUI, AUIPC
// ============================================================
`timescale 1ns / 1ps

module control_unit(
    input [6:0] opcode,
    input [2:0] funct3,

    output reg reg_write,
    output reg alu_src,
    output reg alu_a_src,

    output reg mem_read,
    output reg mem_write,

    output reg branch,
    output reg jump,
    output reg jalr,

    output reg [1:0] writeback_sel,

    output reg [2:0] imm_type,
    output reg [2:0] alu_op,

    output reg [2:0] mem_control,
    output reg [2:0] branch_type
);

// Writeback selection
localparam WB_ALU = 2'b00;
localparam WB_MEM = 2'b01;
localparam WB_PC4 = 2'b10;

// Immediate types
localparam I_TYPE       = 3'b000;
localparam SHIFT_I_TYPE = 3'b001;
localparam S_TYPE       = 3'b010;
localparam B_TYPE       = 3'b011;
localparam U_TYPE       = 3'b100;
localparam J_TYPE       = 3'b101;

// ALU operation types
localparam ALU_OP_R      = 3'b000;
localparam ALU_OP_I      = 3'b001;
localparam ALU_OP_BRANCH = 3'b010;
localparam ALU_OP_ADD    = 3'b011;
localparam ALU_OP_PASS_B = 3'b100;

// Memory operation types
localparam MEM_LB  = 3'b000;
localparam MEM_LH  = 3'b001;
localparam MEM_LW  = 3'b010;
localparam MEM_LBU = 3'b011;
localparam MEM_LHU = 3'b100;
localparam MEM_SB  = 3'b101;
localparam MEM_SH  = 3'b110;
localparam MEM_SW  = 3'b111;

// Branch types
localparam BR_BEQ  = 3'b000;
localparam BR_BNE  = 3'b001;
localparam BR_BLT  = 3'b010;
localparam BR_BGE  = 3'b011;
localparam BR_BLTU = 3'b100;
localparam BR_BGEU = 3'b101;

// RV32I opcodes
localparam OPCODE_R      = 7'b0110011;
localparam OPCODE_I      = 7'b0010011;
localparam OPCODE_LOAD   = 7'b0000011;
localparam OPCODE_STORE  = 7'b0100011;
localparam OPCODE_BRANCH = 7'b1100011;
localparam OPCODE_JAL    = 7'b1101111;
localparam OPCODE_JALR   = 7'b1100111;
localparam OPCODE_LUI    = 7'b0110111;
localparam OPCODE_AUIPC  = 7'b0010111;

always @(*) begin

    // Default values
    reg_write = 1'b0;
    alu_src = 1'b0;
    alu_a_src = 1'b0;

    mem_read = 1'b0;
    mem_write = 1'b0;

    branch = 1'b0;
    jump = 1'b0;
    jalr = 1'b0;

    writeback_sel = WB_ALU;

    imm_type = I_TYPE;
    alu_op = ALU_OP_ADD;

    mem_control = MEM_LW;
    branch_type = BR_BEQ;

    case (opcode)

        // ----------------------------------------
        // R-type
        // ADD, SUB, SLL, SLT, SLTU,
        // XOR, SRL, SRA, OR, AND
        // ----------------------------------------
        OPCODE_R: begin
            reg_write = 1'b1;
            alu_src = 1'b0;
            alu_a_src = 1'b0;
            writeback_sel = WB_ALU;
            alu_op = ALU_OP_R;
        end

        // ----------------------------------------
        // I-type arithmetic
        // ADDI, SLTI, SLTIU, XORI, ORI, ANDI
        // SLLI, SRLI, SRAI
        // ----------------------------------------
        OPCODE_I: begin

            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_a_src = 1'b0;
            writeback_sel = WB_ALU;
            alu_op = ALU_OP_I;

            // SLLI
            // SRLI
            // SRAI
            if ((funct3 == 3'b001) || (funct3 == 3'b101))
                imm_type = SHIFT_I_TYPE;
            else
                imm_type = I_TYPE;

        end

        // ----------------------------------------
        // Loads
        // LB, LH, LW, LBU, LHU
        // ----------------------------------------
        OPCODE_LOAD: begin

            reg_write = 1'b1;
            alu_src = 1'b1;
            alu_a_src = 1'b0;

            mem_read = 1'b1;

            writeback_sel = WB_MEM;
            imm_type = I_TYPE;
            alu_op = ALU_OP_ADD;

            case (funct3)

                3'b000: mem_control = MEM_LB;
                3'b001: mem_control = MEM_LH;
                3'b010: mem_control = MEM_LW;
                3'b100: mem_control = MEM_LBU;
                3'b101: mem_control = MEM_LHU;

                default: mem_control = MEM_LW;

            endcase

        end

        // ----------------------------------------
        // Stores
        // SB, SH, SW
        // ----------------------------------------
        OPCODE_STORE: begin

            alu_src = 1'b1;
            alu_a_src = 1'b0;

            mem_write = 1'b1;

            imm_type = S_TYPE;
            alu_op = ALU_OP_ADD;

            case (funct3)

                3'b000: mem_control = MEM_SB;
                3'b001: mem_control = MEM_SH;
                3'b010: mem_control = MEM_SW;

                default: mem_control = MEM_SW;

            endcase

        end

        // ----------------------------------------
        // Branches
        // BEQ, BNE, BLT, BGE, BLTU, BGEU
        // ----------------------------------------
        OPCODE_BRANCH: begin

            branch = 1'b1;

            alu_src = 1'b0;
            alu_a_src = 1'b0;

            imm_type = B_TYPE;
            alu_op = ALU_OP_BRANCH;

            case (funct3)

                3'b000: branch_type = BR_BEQ;
                3'b001: branch_type = BR_BNE;
                3'b100: branch_type = BR_BLT;
                3'b101: branch_type = BR_BGE;
                3'b110: branch_type = BR_BLTU;
                3'b111: branch_type = BR_BGEU;

                default: branch_type = BR_BEQ;

            endcase

        end

        // ----------------------------------------
        // JAL
        // ----------------------------------------
        OPCODE_JAL: begin

            reg_write = 1'b1;

            jump = 1'b1;

            alu_src = 1'b1;
            alu_a_src = 1'b1;

            writeback_sel = WB_PC4;

            imm_type = J_TYPE;
            alu_op = ALU_OP_ADD;

        end

        // ----------------------------------------
        // JALR
        // ----------------------------------------
        OPCODE_JALR: begin

            reg_write = 1'b1;

            jalr = 1'b1;

            alu_src = 1'b1;
            alu_a_src = 1'b0;

            writeback_sel = WB_PC4;

            imm_type = I_TYPE;
            alu_op = ALU_OP_ADD;

        end

        // ----------------------------------------
        // LUI
        // ----------------------------------------
        OPCODE_LUI: begin

            reg_write = 1'b1;

            alu_src = 1'b1;
            alu_a_src = 1'b0;

            writeback_sel = WB_ALU;

            imm_type = U_TYPE;
            alu_op = ALU_OP_PASS_B;

        end

        // ----------------------------------------
        // AUIPC
        // ----------------------------------------
        OPCODE_AUIPC: begin

            reg_write = 1'b1;

            alu_src = 1'b1;
            alu_a_src = 1'b1;

            writeback_sel = WB_ALU;

            imm_type = U_TYPE;
            alu_op = ALU_OP_ADD;

        end

        // Invalid instruction
        default: begin
        end

    endcase

end

endmodule