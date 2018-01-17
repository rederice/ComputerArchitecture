module MUX8
(
	harzard_i,
	signal_i,
	signal_o
);

input [7:0] signal_i;
input harzard_i;
output [7:0] signal_o;

assign signal_o = harzard_i? signal_i:8'd0;

endmodule