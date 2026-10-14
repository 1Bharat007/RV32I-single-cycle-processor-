module instruction_memory(
    input [31:0] address,
    output [31:0] instruction
);

reg [31:0] memory [0:255];

initial begin
    memory[0] = 32'h00000013;
    memory[1] = 32'h00000013;
    memory[2] = 32'h00000013;
    memory[3] = 32'h00000013;
end

assign instruction = memory[address >> 2];

endmodule