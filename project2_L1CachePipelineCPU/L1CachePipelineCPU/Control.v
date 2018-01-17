module Control
(
	Op_i, 
	RegDst_o, 
	Jump_o, 
	Branch_o, 
	MemRead_o,
	MemtoReg_o, 
	ALUOp_o,
	MemWrite_o, 
	ALUSrc_o, 
	RegWrite_o,
	Ext_o // Useless in this hw
);
	// Input 
	input [5:0] Op_i;
	// Output
	output RegDst_o, Jump_o, Branch_o, MemRead_o, MemtoReg_o, MemWrite_o, ALUSrc_o, 
	RegWrite_o, Ext_o;
	output [1:0] ALUOp_o;
	
	// type
	reg RegDst_o, Jump_o, Branch_o, MemRead_o, MemtoReg_o, MemWrite_o, ALUSrc_o,
	RegWrite_o, Ext_o;
	reg [1:0] ALUOp_o;

	localparam 
		// Op Type
		R_TYPE = 6'b000000,
		ADDI = 6'b001000,
		LW = 6'b100011,
		SW = 6'b101011,
		BEQ = 6'b000100,
		JUMP = 6'b000010,
		// ALUop
		ALU_R_TYPE = 2'b11,
		ALU_ADD = 2'b00,
		ALU_SUB = 2'b01,
		ALU_OR = 2'b10;
	/*
	R-type:
		1.and
		2.or
		3.add
		4.sub
		5.mul
	I-type:
		1.addi
		2.lw
		3.sw
		4.beq
	J-type:
		1.j
	*/
	// WARNING: Only when Op_i changed wil the output change
	always @(Op_i) begin
		case (Op_i)
			R_TYPE:
			begin
				MemRead_o <= 1'b0;
				RegDst_o <= 1'b1;
				ALUSrc_o <= 1'b0;
				MemtoReg_o <= 1'b0;
				RegWrite_o <= 1'b1;
				MemWrite_o <= 1'b0;
				Branch_o <= 1'b0;
				Jump_o <= 1'b0;
				Ext_o <= 1'b0; // x
				ALUOp_o <= ALU_R_TYPE;
			end
			// addi 
			ADDI:
			begin
				MemRead_o <= 1'b0;
				RegDst_o <= 1'b0;
				ALUSrc_o <= 1'b1;
				MemtoReg_o <= 1'b0;
				RegWrite_o <= 1'b1;
				MemWrite_o <= 1'b0;
				Branch_o <= 1'b0;
				Jump_o <= 1'b0;
				Ext_o <= 1'b0;
				ALUOp_o <= ALU_ADD;
			end
			LW:
			begin
				MemRead_o <= 1'b1; // Touch memory
				RegDst_o <= 1'b0; 
				ALUSrc_o <= 1'b1;
				MemtoReg_o <= 1'b1;
				RegWrite_o <= 1'b1;
				MemWrite_o <= 1'b0;
				Branch_o <= 1'b0;
				Jump_o <= 1'b0;
				Ext_o <= 1'b1; // Useless in this hw
				ALUOp_o <= ALU_ADD; // Add
			end
			SW:
			begin
				MemRead_o <= 1'b0;
				RegDst_o <= 1'b0; // x
				ALUSrc_o <= 1'b1;
				MemtoReg_o <= 1'b0; // x
				RegWrite_o <= 1'b0;
				MemWrite_o <= 1'b1;
				Branch_o <= 1'b0;
				Jump_o <= 1'b0;
				Ext_o <= 1'b1; // Useless
				ALUOp_o <= ALU_ADD;
			end
			BEQ:
			begin
				MemRead_o <= 1'b0;
				RegDst_o <= 1'b0; // x
				ALUSrc_o <= 1'b0;
				MemtoReg_o <= 1'b0; // x
				RegWrite_o <= 1'b0;
				MemWrite_o <= 1'b0;
				Branch_o <= 1'b1;
				Jump_o <= 1'b0;
				Ext_o <= 1'b0; // x
				ALUOp_o <= ALU_SUB; // WARNING: In pipelined cpu, ALUOp_o in BEG will become useless
			end
			JUMP:
			begin
				MemRead_o <= 1'b0;
				RegDst_o <= 1'b0; // x
				ALUSrc_o <= 1'b0; // x
				MemtoReg_o <= 1'b0; // x
				RegWrite_o <= 1'b0; 
				MemWrite_o <= 1'b0;
				Branch_o <= 1'b0;
				Jump_o <= 1'b1;
				Ext_o <= 1'b0; // x
				ALUOp_o <= ALU_ADD; //x			
			end
			default:
			begin
				MemRead_o <= 1'b0;
				RegDst_o <= 1'b0; 
				ALUSrc_o <= 1'b0; 
				MemtoReg_o <= 1'b0; 
				RegWrite_o <= 1'b0; 
				MemWrite_o <= 1'b0;
				Branch_o <= 1'b0;
				Jump_o <= 1'b0;
				Ext_o <= 1'b0; 
				ALUOp_o <= ALU_ADD; 
			end
			endcase
	end
	
endmodule
