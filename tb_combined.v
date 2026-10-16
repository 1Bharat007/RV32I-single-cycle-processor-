// ============================================================
// tb_combined.v  -  All-In-One Combined Testbench for RV32I CPU
// RV32I Single-Cycle Processor  |  COA Assignment
//
// Features:
//   1. Single-file compilation: includes all processor modules.
//      Run simply with:
//          iverilog -o tb_combined.vvp tb_combined.v
//          vvp tb_combined.vvp
//          gtkwave dump_combined.vcd
//   2. Comprehensive instruction coverage:
//      - R-Type: ADD, SUB, AND, OR, XOR, SLL, SRL, SLT
//      - I-Type Arith & Shift: ADDI, SLLI, SRLI
//      - Upper Immediate: LUI, AUIPC
//      - Memory: SW, SH, SB, LW, LH, LB
//      - Branches: BEQ, BNE, BLT, BGE (taken & skipped paths)
//      - Jumps: JAL, JALR (return address link + target jump)
//      - Architecture Invariants: x0 register hardwired zero
//   3. Automated Self-Checking Assertions with Pass/Fail stats
// ============================================================
`timescale 1ns / 1ps

`ifndef RV32I_MODULES_ALREADY_INCLUDED
`define RV32I_MODULES_ALREADY_INCLUDED
`include "pc.v"
`include "instruction_memory.v"
`include "register_file.v"
`include "immediate_generator.v"
`include "alu_control.v"
`include "alu.v"
`include "branch_unit.v"
`include "muxes.v"
`include "next_pc.v"
`include "data_memory.v"
`include "control_unit.v"
`include "riscv_cpu.v"
`endif

module tb_combined;

    // ---- Clock & Reset ---------------------------------------------
    reg clk;
    reg reset;

    // ---- Processor Probe Outputs -----------------------------------
    wire [31:0] pc_out;
    wire [31:0] instruction_out;

    // ---- Test Verification Statistics ------------------------------
    integer pass_count;
    integer fail_count;
    integer cycle;

    // ---- Instantiate Top-Level CPU ---------------------------------
    riscv_cpu uut (
        .clk            (clk),
        .reset          (reset),
        .pc_out         (pc_out),
        .instruction_out(instruction_out)
    );

    // ---- 10 ns Clock (50 MHz) --------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Load Combined Test Program --------------------------------
    initial begin
        uut.instruction_mem.memory[ 0] = 32'h01400093; // PC =   0: addi x1, x0, 20
        uut.instruction_mem.memory[ 1] = 32'h00500113; // PC =   4: addi x2, x0, 5
        uut.instruction_mem.memory[ 2] = 32'h002081B3; // PC =   8: add x3, x1, x2
        uut.instruction_mem.memory[ 3] = 32'h40208233; // PC =  12: sub x4, x1, x2
        uut.instruction_mem.memory[ 4] = 32'h0020F2B3; // PC =  16: and x5, x1, x2
        uut.instruction_mem.memory[ 5] = 32'h0020E333; // PC =  20: or x6, x1, x2
        uut.instruction_mem.memory[ 6] = 32'h0020C3B3; // PC =  24: xor x7, x1, x2
        uut.instruction_mem.memory[ 7] = 32'h00211433; // PC =  28: sll x8, x2, x2
        uut.instruction_mem.memory[ 8] = 32'h002454B3; // PC =  32: srl x9, x8, x2
        uut.instruction_mem.memory[ 9] = 32'h00112533; // PC =  36: slt x10, x2, x1
        uut.instruction_mem.memory[10] = 32'h00211593; // PC =  40: slli x11, x2, 1
        uut.instruction_mem.memory[11] = 32'h0020D613; // PC =  44: srli x12, x1, 5
        uut.instruction_mem.memory[12] = 32'h123456B7; // PC =  48: lui x13, 0x12345000
        uut.instruction_mem.memory[13] = 32'h00001717; // PC =  52: auipc x14, 0x1000
        uut.instruction_mem.memory[14] = 32'h00302823; // PC =  56: sw x3, 16(x0)
        uut.instruction_mem.memory[15] = 32'h01002783; // PC =  60: lw x15, 16(x0)
        uut.instruction_mem.memory[16] = 32'h00101A23; // PC =  64: sh x1, 20(x0)
        uut.instruction_mem.memory[17] = 32'h01401803; // PC =  68: lh x16, 20(x0)
        uut.instruction_mem.memory[18] = 32'h00200C23; // PC =  72: sb x2, 24(x0)
        uut.instruction_mem.memory[19] = 32'h01800883; // PC =  76: lb x17, 24(x0)
        uut.instruction_mem.memory[20] = 32'h00B08663; // PC =  80: beq x1, x11, +12
        uut.instruction_mem.memory[21] = 32'h06300913; // PC =  84: addi x18, x0, 99 (skipped)
        uut.instruction_mem.memory[22] = 32'h06300913; // PC =  88: addi x18, x0, 99 (skipped)
        uut.instruction_mem.memory[23] = 32'h00209663; // PC =  92: bne x1, x2, +12
        uut.instruction_mem.memory[24] = 32'h06300993; // PC =  96: addi x19, x0, 99 (skipped)
        uut.instruction_mem.memory[25] = 32'h06300993; // PC = 100: addi x19, x0, 99 (skipped)
        uut.instruction_mem.memory[26] = 32'h00114663; // PC = 104: blt x2, x1, +12
        uut.instruction_mem.memory[27] = 32'h06300A13; // PC = 108: addi x20, x0, 99 (skipped)
        uut.instruction_mem.memory[28] = 32'h06300A13; // PC = 112: addi x20, x0, 99 (skipped)
        uut.instruction_mem.memory[29] = 32'h0020D663; // PC = 116: bge x1, x2, +12
        uut.instruction_mem.memory[30] = 32'h06300A93; // PC = 120: addi x21, x0, 99 (skipped)
        uut.instruction_mem.memory[31] = 32'h06300A93; // PC = 124: addi x21, x0, 99 (skipped)
        uut.instruction_mem.memory[32] = 32'h00800B6F; // PC = 128: jal x22, +8
        uut.instruction_mem.memory[33] = 32'h06300B93; // PC = 132: addi x23, x0, 99 (skipped)
        uut.instruction_mem.memory[34] = 32'h09000C13; // PC = 136: addi x24, x0, 144
        uut.instruction_mem.memory[35] = 32'h000C0CE7; // PC = 140: jalr x25, 0(x24)
        uut.instruction_mem.memory[36] = 32'h04D00D13; // PC = 144: addi x26, x0, 77
        uut.instruction_mem.memory[37] = 32'h07B00013; // PC = 148: addi x0, x0, 123 (x0 hardwired 0 check)
        uut.instruction_mem.memory[38] = 32'h0000006F; // PC = 152: jal x0, 0 (infinite loop halt)

        // Fill remaining entries with NOP
        begin : fill_nops
            integer k;
            for (k = 39; k < 256; k = k + 1)
                uut.instruction_mem.memory[k] = 32'h00000013;
        end
    end

    // ---- VCD Waveform Dump for GTKWave -----------------------------
    initial begin
        $dumpfile("dump_combined.vcd");
        $dumpvars(0, tb_combined);
    end

    // ---- Assertion Check Task (256-bit string to avoid truncation) -
    task check_reg;
        input integer reg_num;
        input [31:0] expected;
        input [255:0] test_name;
        reg [31:0] actual;
        begin
            actual = uut.registers.registers[reg_num];
            if (actual === expected) begin
                $display("  [PASS] Test %-28s | x%-2d = %0d (0x%08h)", test_name, reg_num, actual, actual);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] Test %-28s | x%-2d = %0d (0x%08h), EXPECTED = %0d (0x%08h)",
                         test_name, reg_num, actual, actual, expected, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // ---- Main Simulation & Self-Checking Sequence ------------------
    initial begin
        pass_count = 0;
        fail_count = 0;

        // Apply synchronous reset for 2 clock cycles
        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;

        $display("");
        $display("===============================================================================");
        $display("             RV32I SINGLE-CYCLE PROCESSOR - COMBINED TESTBENCH                 ");
        $display("===============================================================================");
        $display("  Cycle |     PC     |  Instruction  | Description / Pipeline Event            ");
        $display("-------------------------------------------------------------------------------");

        // Run execution trace for 32 instruction cycles
        for (cycle = 0; cycle < 32; cycle = cycle + 1) begin
            @(posedge clk);
            #1; // Wait for values to settle
            $display("   %3d  | 0x%08h |   0x%08h  | Active Execution", cycle, pc_out, instruction_out);
        end

        $display("-------------------------------------------------------------------------------");
        $display("                 AUTOMATED SELF-CHECKING VERIFICATION REPORT                  ");
        $display("-------------------------------------------------------------------------------");

        // Group 1: Immediate & Basic Arithmetic
        $display(" -- [Group 1: Basic Arithmetic & Immediates] --");
        check_reg(1,  32'd20,          "ADDI (x1 = 20)");
        check_reg(2,  32'd5,           "ADDI (x2 = 5)");
        check_reg(3,  32'd25,          "ADD  (x3 = 20 + 5)");
        check_reg(4,  32'd15,          "SUB  (x4 = 20 - 5)");

        // Group 2: Logical & Shifts
        $display(" -- [Group 2: Bitwise Logic & Shift Operations] --");
        check_reg(5,  32'd4,           "AND  (x5 = 20 & 5)");
        check_reg(6,  32'd21,          "OR   (x6 = 20 | 5)");
        check_reg(7,  32'd17,          "XOR  (x7 = 20 ^ 5)");
        check_reg(8,  32'd160,         "SLL  (x8 = 5 << 5)");
        check_reg(9,  32'd5,           "SRL  (x9 = 160 >> 5)");
        check_reg(10, 32'd1,           "SLT  (x10 = 5 < 20)");
        check_reg(11, 32'd20,          "SLLI (x11 = 5 << 2)");
        check_reg(12, 32'd5,           "SRLI (x12 = 20 >> 2)");

        // Group 3: Upper Immediates
        $display(" -- [Group 3: Upper Immediate Instructions] --");
        check_reg(13, 32'h12345000,    "LUI  (x13 = upper imm)");
        check_reg(14, 32'h00001034,    "AUIPC(x14 = PC+0x1000)");

        // Group 4: Memory Operations (Word, Halfword, Byte)
        $display(" -- [Group 4: Data Memory Load & Store Operations] --");
        check_reg(15, 32'd25,          "SW + LW (Word store/load)");
        check_reg(16, 32'd20,          "SH + LH (Halfword load)");
        check_reg(17, 32'd5,           "SB + LB (Byte load)");

        // Group 5: Control Flow & Branches
        $display(" -- [Group 5: Branch Conditions & Hazard Skipping] --");
        check_reg(18, 32'd0,           "BEQ  (Branch taken)");
        check_reg(19, 32'd0,           "BNE  (Branch taken)");
        check_reg(20, 32'd0,           "BLT  (Branch taken)");
        check_reg(21, 32'd0,           "BGE  (Branch taken)");

        // Group 6: Jumps & Links
        $display(" -- [Group 6: Unconditional Jumps (JAL & JALR)] --");
        check_reg(22, 32'd132,         "JAL  (Return link x22)");
        check_reg(23, 32'd0,           "JAL  (Target jumped)");
        check_reg(24, 32'd144,         "ADDI (Target address)");
        check_reg(25, 32'd144,         "JALR (Return link x25)");
        check_reg(26, 32'd77,          "JALR (Target landed)");

        // Group 7: Hardware Invariant (x0 hardwired 0)
        $display(" -- [Group 7: Hardware Invariants] --");
        check_reg(0,  32'd0,           "x0 Hardwired to 0");

        $display("===============================================================================");
        if (fail_count == 0) begin
            $display("  >>> ALL %0d TESTS PASSED SUCCESSFULLY! (Failures: 0) <<<", pass_count);
            $display("  Processor Simulation Status: FULLY OPERATIONAL & VERIFIED");
        end else begin
            $display("  >>> SIMULATION FAILED: %0d PASSED, %0d FAILED <<<", pass_count, fail_count);
        end
        $display("===============================================================================");
        $display("  VCD waveform dumped to 'dump_combined.vcd'");
        $display("");

        $finish;
    end

endmodule
