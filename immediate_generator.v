module immediate_generator(
    input [31:0] instruction,
    input [2:0] imm_type,
    output reg [31:0] immediate
);

// Immediate type codes
localparam I_TYPE       = 3'b000;
localparam SHIFT_I_TYPE = 3'b001;
localparam S_TYPE       = 3'b010;
localparam B_TYPE       = 3'b011;
localparam U_TYPE       = 3'b100;
localparam J_TYPE       = 3'b101;

always @(*) begin

    case (imm_type)

        // I-type
        // ADDI, SLTI, SLTIU, XORI, ORI, ANDI
        // LB, LH, LW, LBU, LHU, JALR
        I_TYPE:
            immediate = {{20{instruction[31]}},
                         instruction[31:20]};

        // Shift-immediate
        // SLLI, SRLI, SRAI
        SHIFT_I_TYPE:
            immediate = {27'b0, instruction[24:20]};

        // S-type
        // SB, SH, SW
        S_TYPE:
            immediate = {{20{instruction[31]}},
                         instruction[31:25],
                         instruction[11:7]};

        // B-type
        // BEQ, BNE, BLT, BGE, BLTU, BGEU
        B_TYPE:
            immediate = {{19{instruction[31]}},
                         instruction[31],
                         instruction[7],
                         instruction[30:25],
                         instruction[11:8],
                         1'b0};

        // U-type
        // LUI, AUIPC
        U_TYPE:
            immediate = {instruction[31:12], 12'b0};

        // J-type
        // JAL
        J_TYPE:
            immediate = {{11{instruction[31]}},
                         instruction[31],
                         instruction[19:12],
                         instruction[20],
                         instruction[30:21],
                         1'b0};

        default:
            immediate = 32'b0;

    endcase

end

endmodule