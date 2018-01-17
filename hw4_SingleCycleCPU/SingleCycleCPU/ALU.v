module ALU
(
	data1_i,
	data2_i,
	ALUCtrl_i,
	data_o,
	Zero_o
);

// Interface
input	[31:0]	data1_i;
input	[31:0]	data2_i;
input [2:0]   ALUCtrl_i;
output	[31:0]	data_o;
output Zero_o;

wire [31:0] wr_and;
wire [31:0] wr_or;
wire [31:0] wr_add;
wire [31:0] wr_sub;
wire [31:0] wr_mul;
assign wr_and=data1_i & data2_i;
assign wr_or =data1_i | data2_i;
assign wr_add=data1_i + data2_i;
assign wr_sub=data1_i - data2_i;
assign wr_mul=data1_i * data2_i;

assign data_o =(ALUCtrl_i==3'b000)?wr_and/*AND*/:
               (ALUCtrl_i==3'b001)?wr_or/*OR*/:
               (ALUCtrl_i==3'b010)?wr_add/*ADD*/:
               (ALUCtrl_i==3'b011)?wr_mul/*MUL*/:
               (ALUCtrl_i==3'b110)?wr_sub/*SUB*/:
               {32{1'bx}};

assign Zero_o = (wr_sub==32'b0);

endmodule