module Sign_Extend
(
	data_i,
	data_o
);

// Interface
input	[15:0]	data_i;
output	[31:0]	data_o;

assign data_o[15:0] = data_i[15:0];
assign data_o[31:16] = data_i[15]?16'b1111_1111_1111_1111:16'b0;

endmodule