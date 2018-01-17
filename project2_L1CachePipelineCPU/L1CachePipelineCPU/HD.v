module HazardDetectionUnit(
	input ID_EX_MemRead,
	input [4:0] IF_ID_RSaddr,
	input [4:0] IF_ID_RTaddr,
	input [4:0] ID_EX_RTaddr,
	// output 
	output pchazard_o,
    output IF_ID_hazard_o,
    output mux8select_o
);
wire control;
assign control = ID_EX_MemRead && ((ID_EX_RTaddr == IF_ID_RTaddr) ||
	(ID_EX_RTaddr == IF_ID_RSaddr));
assign pchazard_o = !control;
assign IF_ID_hazard_o = !control;
assign mux8select_o = !control;
endmodule