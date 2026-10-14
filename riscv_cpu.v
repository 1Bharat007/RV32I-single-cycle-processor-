module riscv_cpu(
    input clk,
    input reset,

    output [31:0] pc_out,
    output [31:0] instruction_out
);

    // =========================================================
    // PC
    // =========================================================

    wire [31:0] pc_current;
    wire [31:0] next_pc_value;

    pc pc_unit (
        .clk(clk),
        .reset(reset),
        .next_pc(next_pc_value),
        .pc(pc_current)
    );

    assign pc_out = pc_current;


    // =========================================================
    // Instruction Memory
    // =========================================================

    wire [31:0] instruction;

    instruction_memory instruction_mem (
        .address(pc_current),
        .instruction(instruction)
    );

    assign instruction_out = instruction;


    // =========================================================
    // Instruction fields
    // =========================================================

    wire [6:0] opcode;
    wire [2:0] funct3;
    wire [6:0] funct7;

    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;

    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];


    // =========================================================
    // Control Unit
    // =========================================================

    wire reg_write;
    wire alu_src;
    wire alu_a_src;

    wire mem_read;
    wire mem_write;

    wire branch;
    wire jump;
    wire jalr;

    wire [1:0] writeback_sel;

    wire [2:0] imm_type;
    wire [2:0] alu_op;

    wire [2:0] mem_control;
    wire [2:0] branch_type;

    control_unit control (
        .opcode(opcode),
        .funct3(funct3),

        .reg_write(reg_write),
        .alu_src(alu_src),
        .alu_a_src(alu_a_src),

        .mem_read(mem_read),
        .mem_write(mem_write),

        .branch(branch),
        .jump(jump),
        .jalr(jalr),

        .writeback_sel(writeback_sel),

        .imm_type(imm_type),
        .alu_op(alu_op),

        .mem_control(mem_control),
        .branch_type(branch_type)
    );


    // =========================================================
    // Register File
    // =========================================================

    wire [31:0] rs1_value;
    wire [31:0] rs2_value;

    wire [31:0] writeback_data;

    register_file registers (
        .clk(clk),
        .reset(reset),

        .read_reg1(rs1),
        .read_reg2(rs2),

        .read_data1(rs1_value),
        .read_data2(rs2_value),

        .write_reg(rd),
        .write_data(writeback_data),
        .write_enable(reg_write)
    );


    // =========================================================
    // Immediate Generator
    // =========================================================

    wire [31:0] immediate;

    immediate_generator imm_gen (
        .instruction(instruction),
        .imm_type(imm_type),
        .immediate(immediate)
    );


    // =========================================================
    // ALU Control
    // =========================================================

    wire [3:0] alu_control_signal;

    alu_control alu_ctrl (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .alu_control(alu_control_signal)
    );


    // =========================================================
    // MUXes
    // =========================================================

    wire [31:0] alu_operand_a;
    wire [31:0] alu_operand_b;

    wire [31:0] alu_result;


    // PC + 4
    wire [31:0] pc_plus4;

    assign pc_plus4 = pc_current + 32'd4;


    muxes datapath_muxes (
        .rs1_value(rs1_value),
        .pc(pc_current),

        .rs2_value(rs2_value),
        .immediate(immediate),

        .alu_result(alu_result),
        .memory_data(memory_read_data),
        .pc_plus4(pc_plus4),

        .alu_a_src(alu_a_src),
        .alu_src(alu_src),
        .writeback_sel(writeback_sel),

        .alu_operand_a(alu_operand_a),
        .alu_operand_b(alu_operand_b),
        .writeback_data(writeback_data)
    );


    // =========================================================
    // ALU
    // =========================================================

    wire alu_zero;

    alu alu_unit (
        .operand_a(alu_operand_a),
        .operand_b(alu_operand_b),
        .alu_control(alu_control_signal),

        .result(alu_result),
        .zero(alu_zero)
    );


    // =========================================================
    // Data Memory
    // =========================================================

    wire [31:0] memory_read_data;

    data_memory data_mem (
        .clk(clk),
        .reset(reset),

        .address(alu_result),
        .write_data(rs2_value),

        .mem_read(mem_read),
        .mem_write(mem_write),

        .mem_control(mem_control),

        .read_data(memory_read_data)
    );


    // =========================================================
    // Branch Unit
    // =========================================================

    wire branch_taken;

    branch_unit branch_logic (
        .branch(branch),
        .branch_type(branch_type),

        .operand_a(rs1_value),
        .operand_b(rs2_value),

        .branch_taken(branch_taken)
    );


    // =========================================================
    // Next PC Logic
    // =========================================================

    next_pc next_pc_logic (
        .pc(pc_current),

        .branch_immediate(immediate),
        .jump_immediate(immediate),
        .jalr_immediate(immediate),

        .rs1_value(rs1_value),

        .branch(branch),
        .branch_taken(branch_taken),

        .jump(jump),
        .jalr(jalr),

        .next_pc(next_pc_value)
    );

endmodule