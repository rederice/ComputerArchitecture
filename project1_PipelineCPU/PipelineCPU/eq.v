module eq(data1_i, data2_i, eq_o);
input [31:0]data1_i, data2_i;
output eq_o;

assign eq_o = (data1_i == data2_i)? 1'b1:1'b0;

endmodule