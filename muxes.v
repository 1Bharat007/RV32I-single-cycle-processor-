module muxes(
    // Inputs for ALU A MUX
    input [31:0] rs1_value,
    input [31:0] pc,

    // Inputs for ALU B MUX
    input [31:0] rs2_value,
    input [31:0] immediate,

    // Inputs for Writeback MUX
    input [31:0] alu_result,
    input [31:0] memory_data,
    input [31:0] pc_plus4,

    // Control signals
    input alu_a_src,
    input alu_src,
    input [1:0] writeback_sel,

    // MUX outputs
    output [31:0] alu_operand_a,
    output [31:0] alu_operand_b,
    output [31:0] writeback_data
);

// Writeback selection
localparam WB_ALU = 2'b00;
localparam WB_MEM = 2'b01;
localparam WB_PC4 = 2'b10;

// ALU A input MUX
// 0 -> rs1
// 1 -> PC
assign alu_operand_a =
    (alu_a_src == 1'b0) ? rs1_value : pc;

// ALU B input MUX
// 0 -> rs2
// 1 -> immediate
assign alu_operand_b =
    (alu_src == 1'b0) ? rs2_value : immediate;

// Writeback MUX
// 00 -> ALU result
// 01 -> memory data
// 10 -> PC + 4
assign writeback_data =
    (writeback_sel == WB_ALU) ? alu_result :
    (writeback_sel == WB_MEM) ? memory_data :
    (writeback_sel == WB_PC4) ? pc_plus4 :
    32'b0;

endmodule