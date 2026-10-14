// ============================================================
// data_memory.v  –  Data Memory (RAM)
// RV32I Single-Cycle Processor  |  COA Assignment
// Description : 1024-byte little-endian byte-addressable RAM.
//               Supports LB, LH, LW, LBU, LHU (reads) and
//               SB, SH, SW (synchronous writes).
//               Read is combinational; write is clocked.
// ============================================================
`timescale 1ns / 1ps

module data_memory(
    input clk,
    input reset,

    input [31:0] address,
    input [31:0] write_data,

    input mem_read,
    input mem_write,

    input [2:0] mem_control,

    output reg [31:0] read_data
);

// Memory contains 1024 bytes
reg [7:0] memory [0:1023];

integer i;

// Memory operation codes
localparam MEM_LB  = 3'b000;
localparam MEM_LH  = 3'b001;
localparam MEM_LW  = 3'b010;
localparam MEM_LBU = 3'b011;
localparam MEM_LHU = 3'b100;

localparam MEM_SB  = 3'b101;
localparam MEM_SH  = 3'b110;
localparam MEM_SW  = 3'b111;

// Reset and store operations
always @(posedge clk) begin

    if (reset) begin

        for (i = 0; i < 1024; i = i + 1)
            memory[i] <= 8'b0;

    end

    else if (mem_write) begin

        case (mem_control)

            // Store Byte
            MEM_SB:
                memory[address] <= write_data[7:0];

            // Store Halfword
            MEM_SH: begin
                memory[address]     <= write_data[7:0];
                memory[address + 1] <= write_data[15:8];
            end

            // Store Word
            MEM_SW: begin
                memory[address]     <= write_data[7:0];
                memory[address + 1] <= write_data[15:8];
                memory[address + 2] <= write_data[23:16];
                memory[address + 3] <= write_data[31:24];
            end

            default:
                ;

        endcase

    end

end

// Load operations
always @(*) begin

    read_data = 32'b0;

    if (mem_read) begin

        case (mem_control)

            // Load Byte - signed
            MEM_LB:
                read_data = {{24{memory[address][7]}},
                             memory[address]};

            // Load Halfword - signed
            MEM_LH:
                read_data = {{16{memory[address + 1][7]}},
                             memory[address + 1],
                             memory[address]};

            // Load Word
            MEM_LW:
                read_data = {memory[address + 3],
                             memory[address + 2],
                             memory[address + 1],
                             memory[address]};

            // Load Byte - unsigned
            MEM_LBU:
                read_data = {24'b0, memory[address]};

            // Load Halfword - unsigned
            MEM_LHU:
                read_data = {16'b0,
                             memory[address + 1],
                             memory[address]};

            default:
                read_data = 32'b0;

        endcase

    end

end

endmodule