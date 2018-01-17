module Control
(
   Op_i,
   RegDst_o,
   ALUOp_o,
   ALUSrc_o,
   RegWrite_o
);
// Interface
input  [5:0] Op_i;
output       RegDst_o;
output       ALUSrc_o;
output       RegWrite_o;
output [1:0] ALUOp_o;

wire [10:0] temp;
assign temp = (Op_i==6'b000000)?{10'b1001000010}://R-format
              (Op_i==6'b100011)?{10'b0111100000}://lw
              (Op_i==6'b101011)?{10'bx1x0010000}://sw
              (Op_i==6'b000100)?{10'bx0x0001001}://beq
              (Op_i==6'b000010)?{10'b0000000100}://jump
              (Op_i==6'b001000)?{10'b0101000000}://addi              
               10'bxxxxxxxxxx;
               
assign RegDst_o   = temp[9];
assign ALUSrc_o   = temp[8];
assign RegWrite_o = temp[6];
assign ALUOp_o[1] = temp[1];
assign ALUOp_o[0] = temp[0];

endmodule