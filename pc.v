module pc(
    input clk,
    input reset,
    input [31:0] next_pc,

    output reg [31:0] pc
);

always @(posedge clk) begin

    if (reset)
        pc <= 32'b0;
    else
        pc <= next_pc;

end

endmodule