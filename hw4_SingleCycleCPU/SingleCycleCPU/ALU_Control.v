module ALU_Control
(
   funct_i,
   ALUOp_i,
	ALUCtrl_o
);
// Interface
input   [5:0]   funct_i;
input   [1:0]   ALUOp_i;
output  [2:0]   ALUCtrl_o;

assign temp1  = ~funct_i[2];
assign temp2 = funct_i[0] || funct_i[3];
assign ALUCtrl_o = (ALUOp_i==2'b00)?{3'b010}:
                   (ALUOp_i==2'b01)?{3'b110}:
                   (ALUOp_i==2'b10)?{funct_i[1],temp1,temp2}:
                   3'bxxx;
endmodule