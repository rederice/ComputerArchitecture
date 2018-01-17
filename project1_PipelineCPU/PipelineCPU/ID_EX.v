module ID_EX(
	input clk_i,
	/*
	- Control Signal Part
	*/
	// W/B (Write Back) Note: Variable named as ppt
	input MemtoReg,
	input RegWrite,
	// MEM (Memory Stage)
	input MemWrite,
	input MemRead,
	// EXE (Execution Stage)
	input ALUSrc,
	input [1:0]ALUOp,
	input RegDst,
	/*
	- Data Part
	*/
	// PC
	input [31:0] PC_add_4,
	input [31:0] read_data_1,
	input [31:0] read_data_2,
	input [31:0] sign_extended,
	// instruction [25:11]
	input [14:0] instruction,
//-------------------------------------------------//
	// Output
	output reg MemtoReg_o,
	output reg RegWrite_o,
	// MEM (Memory Stage)
	output reg MemWrite_o,
	output reg MemRead_o,
	// EXE (Execution Stage)
	output reg ALUSrc_o,
	output reg [1:0]ALUOp_o,
	output reg RegDst_o,
	// PC
	output reg [31:0] PC_add_4_o, // useless
	output reg [31:0] read_data_1_o,
	output reg [31:0] read_data_2_o,
	output reg [31:0] sign_extended_o,
	// instruction [25:11]
	output reg [14:0] instruction_o
);
initial begin
#1
	MemtoReg_o <= 0;
	RegWrite_o <= 0;
	MemWrite_o <= 0;
	MemRead_o <= 0;
	ALUSrc_o <= 0;
	ALUOp_o <= 0;
	RegDst_o <= 0;
	PC_add_4_o <= 0;
	read_data_1_o <= 0;
	read_data_2_o <= 0;
	sign_extended_o <= 0;
	instruction_o <= 0;
end
// Write when rising edge
always @(posedge clk_i) begin
	MemtoReg_o <= MemtoReg;
	RegWrite_o <= RegWrite;
	MemWrite_o <= MemWrite;
	MemRead_o <= MemRead;
	ALUSrc_o <= ALUSrc;
	ALUOp_o <= ALUOp;
	RegDst_o <= RegDst;
	PC_add_4_o <= PC_add_4;
	read_data_1_o <= read_data_1;
	read_data_2_o <= read_data_2;
	sign_extended_o <= sign_extended;
	instruction_o <= instruction;
end
endmodule