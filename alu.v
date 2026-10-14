module alu(
    input [31:0] operand_a,
    input [31:0] operand_b,
    input [3:0] alu_control,

    output reg [31:0] result,
    output zero
);

// ALU operation codes
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

always @(*) begin

    case (alu_control)

        // ADD
        ALU_ADD:
            result = operand_a + operand_b;

        // SUB
        ALU_SUB:
            result = operand_a - operand_b;

        // SLL - Shift Left Logical
        ALU_SLL:
            result = operand_a << operand_b[4:0];

        // SLT - Set Less Than (Signed)
        ALU_SLT:
            result = ($signed(operand_a) < $signed(operand_b))
                     ? 32'd1 : 32'd0;

        // SLTU - Set Less Than (Unsigned)
        ALU_SLTU:
            result = (operand_a < operand_b)
                     ? 32'd1 : 32'd0;

        // XOR
        ALU_XOR:
            result = operand_a ^ operand_b;

        // SRL - Shift Right Logical
        ALU_SRL:
            result = operand_a >> operand_b[4:0];

        // SRA - Shift Right Arithmetic
        ALU_SRA:
            result = $signed(operand_a) >>> operand_b[4:0];

        // OR
        ALU_OR:
            result = operand_a | operand_b;

        // AND
        ALU_AND:
            result = operand_a & operand_b;

        // PASS_B
        // Used by LUI
        ALU_PASS_B:
            result = operand_b;

        // Default
        default:
            result = 32'b0;

    endcase

end

// Zero flag
assign zero = (result == 32'b0);

endmodule