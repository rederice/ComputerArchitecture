module MEM_WB(
	input clk_i,
	// MEM (Memory Stage)
	input MemtoReg,
	input RegWrite,
	//
	input [31:0] Read_data,
	input [31:0] ALU_result,
	input [4:0] Write_register,
	// MEM (Memory Stage)
	output reg MemtoReg_o,
	output reg RegWrite_o,
	//
	output reg [31:0] Read_data_o, //MUX32_data
	output reg [31:0] ALU_result_o, //MUX32_addr
	output reg [4:0] Write_register_o,
	input halt_i
);
initial begin
#1
	MemtoReg_o <= 0;
	RegWrite_o <= 0;
	Read_data_o <= 0;
	ALU_result_o <= 0;
	Write_register_o <= 0;
end
always @(posedge clk_i) begin
	if (~halt_i) begin
		MemtoReg_o <= MemtoReg;
		RegWrite_o <= RegWrite;
		Read_data_o <= Read_data;
		ALU_result_o <= ALU_result;
		Write_register_o <= Write_register;
	end
	else begin
		MemtoReg_o <= MemtoReg_o;
		RegWrite_o <= RegWrite_o;
		Read_data_o <= Read_data_o;
		ALU_result_o <= ALU_result_o;
		Write_register_o <= Write_register_o;
	end
	
end
endmodule