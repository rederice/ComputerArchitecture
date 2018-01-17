module EX_MEM(
	input clk_i,

	// W/B (Write Back) Note: Variable named as ppt
	input MemtoReg,
	input RegWrite,
	// MEM (Memory Stage)
	input MemWrite,
	input MemRead,
	//
	input [31:0] ALU_result,
	input [31:0] Mem_Write_Data, //MUX7_out
	input [4:0] Write_register, //MUX5_3_out

	// W/B (Write Back) Note: Variable named as ppt
	output reg MemtoReg_o,
	output reg RegWrite_o,
	// MEM (Memory Stage)
	output reg MemWrite_o,
	output reg MemRead_o,
	//
	output reg [31:0] ALU_result_o,
	output reg [31:0] Mem_Write_Data_o,
	output reg [4:0] Write_register_o,
	input halt_i
);
initial begin
#1
	MemtoReg_o <= 0;
	RegWrite_o <= 0;
	MemWrite_o <= 0;
	MemRead_o <= 0;
	ALU_result_o <= 0;
	Mem_Write_Data_o <= 0;
	Write_register_o <= 0; 
end
always @(posedge clk_i) begin
	if (~halt_i) begin
		MemtoReg_o <= MemtoReg;
		RegWrite_o <= RegWrite;
		MemWrite_o <= MemWrite;
		MemRead_o <= MemRead;
		ALU_result_o <= ALU_result;
		Mem_Write_Data_o <= Mem_Write_Data;
		Write_register_o <= Write_register;	
	end
	else begin
		MemtoReg_o <= MemtoReg_o;
		RegWrite_o <= RegWrite_o;
		MemWrite_o <= MemWrite_o;
		MemRead_o <= MemRead_o;
		ALU_result_o <= ALU_result_o;
		Mem_Write_Data_o <= Mem_Write_Data_o;
		Write_register_o <= Write_register_o;	
	end
end
endmodule