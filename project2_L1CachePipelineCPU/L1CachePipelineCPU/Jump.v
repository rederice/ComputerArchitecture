module Jump (shift_in, pc_4bit, jump_address);
	/*
	Jump:
		1. jump_address = Shift instruction[25:0] left by 2
		2. jump_address = Concatenate (PC+4)[31:28] and jump_address
	*/
	input [25:0] shift_in;
	input [3:0] pc_4bit;
	output [31:0] jump_address;
	assign jump_address[31:0] = {pc_4bit[3:0], shift_in[25:0], 2'b00};
endmodule