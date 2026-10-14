// ============================================================
// tb_riscv_cpu.v  -  Testbench for RV32I Single-Cycle CPU
// RV32I Single-Cycle Processor  |  COA Assignment
// Description : Drives clock and reset, loads a small test
//               program directly into instruction_memory,
//               and dumps a VCD waveform for GTKWave.
// How to run  :
//   iverilog -o tb.vvp tb_riscv_cpu.v riscv_cpu.v pc.v     \
//            instruction_memory.v control_unit.v             \
//            register_file.v immediate_generator.v           \
//            alu_control.v alu.v muxes.v data_memory.v       \
//            branch_unit.v next_pc.v
//   vvp tb.vvp
//   gtkwave dump.vcd
// ============================================================
`timescale 1ns / 1ps

module tb_riscv_cpu;

    // ---- clock and reset -------------------------------------------
    reg clk;
    reg reset;

    // ---- outputs we want to watch ----------------------------------
    wire [31:0] pc_out;
    wire [31:0] instruction_out;

    // ---- instantiate the processor ---------------------------------
    riscv_cpu uut (
        .clk            (clk),
        .reset          (reset),
        .pc_out         (pc_out),
        .instruction_out(instruction_out)
    );

    // ---- 10 ns clock period (50 MHz) --------------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- load test program into instruction memory -----------------
    //
    //  This tiny program tests a handful of instructions:
    //
    //  0:  addi x1, x0, 5      -> x1 = 5
    //  4:  addi x2, x0, 10     -> x2 = 10
    //  8:  add  x3, x1, x2     -> x3 = 15
    //  12: sub  x4, x2, x1     -> x4 = 5
    //  16: and  x5, x1, x2     -> x5 = 0  (5 & 10)
    //  20: or   x6, x1, x2     -> x6 = 15 (5 | 10)
    //  24: xor  x7, x1, x2     -> x7 = 15 (5 ^ 10)
    //  28: slt  x8, x1, x2     -> x8 = 1  (5 < 10)
    //  32: beq  x1, x1, +12    -> branch taken -> jumps to 44
    //  36: addi x9, x0, 99     -> should be skipped
    //  40: addi x9, x0, 99     -> should be skipped
    //  44: addi x10, x0, 42    -> x10 = 42  (branch lands here)
    //  48: sw   x3, 0(x0)      -> mem[0] = 15
    //  52: lw   x11, 0(x0)     -> x11 = 15
    //  56: jal  x12, 0         -> x12 = 60, jump to 56 (infinite loop)
    //
    initial begin
        // addi x1, x0, 5      -- 0x00500093
        uut.instruction_mem.memory[0]  = 32'h00500093;
        // addi x2, x0, 10     -- 0x00A00113
        uut.instruction_mem.memory[1]  = 32'h00A00113;
        // add  x3, x1, x2     -- 0x002081B3
        uut.instruction_mem.memory[2]  = 32'h002081B3;
        // sub  x4, x2, x1     -- 0x40110233
        uut.instruction_mem.memory[3]  = 32'h40110233;
        // and  x5, x1, x2     -- 0x0020F2B3
        uut.instruction_mem.memory[4]  = 32'h0020F2B3;
        // or   x6, x1, x2     -- 0x0020E333
        uut.instruction_mem.memory[5]  = 32'h0020E333;
        // xor  x7, x1, x2     -- 0x0020C3B3
        uut.instruction_mem.memory[6]  = 32'h0020C3B3;
        // slt  x8, x1, x2     -- 0x0020A433
        uut.instruction_mem.memory[7]  = 32'h0020A433;
        // beq  x1, x1, +12    -- 0x00108663
        uut.instruction_mem.memory[8]  = 32'h00108663;
        // addi x9, x0, 99  (skipped)  -- 0x06300493
        uut.instruction_mem.memory[9]  = 32'h06300493;
        // addi x9, x0, 99  (skipped)  -- 0x06300493
        uut.instruction_mem.memory[10] = 32'h06300493;
        // addi x10, x0, 42    -- 0x02A00513
        uut.instruction_mem.memory[11] = 32'h02A00513;
        // sw   x3, 0(x0)      -- 0x00302023
        uut.instruction_mem.memory[12] = 32'h00302023;
        // lw   x11, 0(x0)     -- 0x00002583
        uut.instruction_mem.memory[13] = 32'h00002583;
        // jal  x12, 0         -- 0x0000066F  (infinite loop)
        uut.instruction_mem.memory[14] = 32'h0000066F;
        // fill rest with NOP
        begin : fill_nop
            integer k;
            for (k = 15; k < 256; k = k + 1)
                uut.instruction_mem.memory[k] = 32'h00000013;
        end
    end

    // ---- VCD dump --------------------------------------------------
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_riscv_cpu);
    end

    // ---- run and check results ------------------------------------
    integer cycle;
    initial begin
        // reset for 2 cycles
        reset = 1;
        repeat(2) @(posedge clk);
        reset = 0;

        $display("----------------------------------------------");
        $display("  RV32I Single-Cycle Processor  -  Test Run   ");
        $display("----------------------------------------------");
        $display("  cycle |   PC   | instruction");
        $display("----------------------------------------------");

        // run for 20 cycles, print PC and instruction each cycle
        for (cycle = 0; cycle < 20; cycle = cycle + 1) begin
            @(posedge clk);
            #1; // small delay so values settle
            $display("  %4d  | 0x%04h | 0x%08h",
                      cycle, pc_out, instruction_out);
        end

        $display("----------------------------------------------");
        $display("  Register snapshot after 20 cycles:");
        $display("  x1  = %0d  (expect 5)",  uut.registers.registers[1]);
        $display("  x2  = %0d  (expect 10)", uut.registers.registers[2]);
        $display("  x3  = %0d  (expect 15)", uut.registers.registers[3]);
        $display("  x4  = %0d  (expect 5)",  uut.registers.registers[4]);
        $display("  x5  = %0d  (expect 0)",  uut.registers.registers[5]);
        $display("  x6  = %0d  (expect 15)", uut.registers.registers[6]);
        $display("  x7  = %0d  (expect 15)", uut.registers.registers[7]);
        $display("  x8  = %0d  (expect 1)",  uut.registers.registers[8]);
        $display("  x9  = %0d  (expect 0 - branch skipped)", uut.registers.registers[9]);
        $display("  x10 = %0d  (expect 42)", uut.registers.registers[10]);
        $display("  x11 = %0d  (expect 15 - loaded from mem)", uut.registers.registers[11]);
        $display("----------------------------------------------");

        $finish;
    end

endmodule
