module register_file(
    input clk,
    input reset,

    input [4:0] read_reg1,
    input [4:0] read_reg2,

    output [31:0] read_data1,
    output [31:0] read_data2,

    input [4:0] write_reg,
    input [31:0] write_data,
    input write_enable
);

reg [31:0] registers [0:31];

integer i;

always @(posedge clk) begin

    if (reset) begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] <= 32'b0;
    end

    else if (write_enable && write_reg != 5'b00000) begin
        registers[write_reg] <= write_data;
    end

end

assign read_data1 = (read_reg1 == 5'b00000) ? 32'b0 : registers[read_reg1];

assign read_data2 = (read_reg2 == 5'b00000) ? 32'b0 : registers[read_reg2];

endmodule