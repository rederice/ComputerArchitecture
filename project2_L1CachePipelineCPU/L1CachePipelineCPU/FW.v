module ForwardingUnit(
	input clk_i,
	// EX hazard, MEM hazard
	input EX_MEM_RegWrite,
	input [4:0] EX_MEM_RegisterRd, // Write_Register in EX_MEM.v 
	input [4:0] ID_EX_RegisterRs,
	input [4:0] ID_EX_RegisterRt,
	input MEM_WB_RegWrite,
	input [4:0] MEM_WB_RegisterRd,

	output reg[1:0] ForwardA,
	output reg[1:0] ForwardB
);
// BUG: Every change should reflect on ForwardA, ForwardB
always @(*) begin
	if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRs))
	begin
		ForwardA <= 2'b10;
	end
	else if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && (EX_MEM_RegisterRd != ID_EX_RegisterRs)
		&& (MEM_WB_RegisterRd == ID_EX_RegisterRs))
	begin
		ForwardA <= 2'b01;
	end
	else ForwardA <= 2'b00;

	if (EX_MEM_RegWrite && (EX_MEM_RegisterRd != 0) && (EX_MEM_RegisterRd == ID_EX_RegisterRt))
	begin
		ForwardB <= 2'b10;
	end
	else if (MEM_WB_RegWrite && (MEM_WB_RegisterRd != 0) && (EX_MEM_RegisterRd != ID_EX_RegisterRt)
		&& (MEM_WB_RegisterRd == ID_EX_RegisterRt))
	begin
		ForwardB <= 2'b01;
	end
	else ForwardB <= 2'b00;
end
endmodule