module Sign_Extend(data_i, data_o);
	input [15:0] data_i;
	output [31:0] data_o;
	// type
	reg [31:0] data_o;
	integer i;
	always @(data_i) begin
		// copy highest bit
		for(i = 16; i < 32; i=i+1) begin
			data_o[i] = data_i[15];
		end
		data_o[15:0] = data_i[15:0];
	end
endmodule