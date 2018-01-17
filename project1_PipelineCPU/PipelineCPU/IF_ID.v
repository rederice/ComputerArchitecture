module IF_ID(
	// Signal
	input clk_i,
	input stall, // if stall, do not write anything on this latch
	input flush,
	input [31:0] PC_add_4, instruction,
	output reg [31:0] PC_add_out, 
	output reg [31:0] inst_o
);

// initial (why?)
initial begin
#1
	PC_add_out = 0;
	inst_o = 0;
end 

always @(posedge clk_i) begin
	// If flush, put NOOP into IF_ID latch
	if (flush) begin
		inst_o <= 32'b0;
		PC_add_out <= 32'b0;
	end
	else if (stall) begin
		inst_o <= instruction;
		PC_add_out <= PC_add_4;
	end
end

endmodule