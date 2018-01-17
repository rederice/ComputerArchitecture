module Data_Memory (addr, write_data, read_data, clk, reset, MemRead, MemWrite);
	// input
	input [31:0] addr; // only need 5 bit to address data memory
	input [31:0] write_data;
	input clk, reset, MemRead, MemWrite;
	// output
	output [31:0] read_data;

	reg [31:0] memory [31:0]; // 32bits * 8 = 4bytes * 8 = 32bytes
	integer k;
	
	assign read_data = (MemRead) ? memory[addr] : 32'bx;
	// Note: Write when posedge
	always @(posedge clk or negedge reset) // reset when negedge
	begin
		//WARNING: No reset here
		if (~reset == 1'b1) 
			begin
				for (k=0; k<32; k=k+1) begin
					memory[k] = 32'b0;
				end
			end
		else
			if (MemWrite) memory[addr] = write_data; 
	end
endmodule