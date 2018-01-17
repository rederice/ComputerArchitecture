module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

// Types
wire [31:0] PC_in, PC_out; // 
wire [31:0] instruction; // instruction
wire [31:0] ALU_result; // output of ALU module
wire [31:0] read_data_1, read_data_2; // output register (file)
wire [4:0] write_register; // output of mux 3
wire [31:0] sign_extended; // output of sign_extened module
wire [2:0] alu_control; // output of alu control module
wire [31:0] alu_src; // output of mux 4
wire [31:0] reg_write_data; // output of mux 5
wire [31:0] jump_address; // output of Jump module

// Pipeline latch
/*
    1. IF_ID
    2. ID_EX
    3. EX_MEM
    4. MEM_WB
*/

wire zero;

Control Control(
    .Op_i       (IF_ID.inst_o[31:26]),
    .RegDst_o   (),
    .Jump_o     (), 
    .Branch_o   (), 
    .MemRead_o  (),
    .MemtoReg_o (), 
    .ALUOp_o    (),
    .MemWrite_o (),
    .ALUSrc_o   (),
    .RegWrite_o (),
    .Ext_o      ()
);
// PC adder
Adder Add_PC(
    .data1_in   (PC_out),
    .data2_in   (32'd4),
    .data_o     ()
);


PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pchazard_i (HazardDetection.pchazard_o),
    .pc_i       (MUX_Jump.data_o),
    .pc_o       (PC_out)
);

// Jump part
Jump Jump(
    .shift_in   (IF_ID.inst_o[25:0]), 
    .pc_4bit    (MUX_Branch.data_o[31:28]), 
    .jump_address    (jump_address)
);

// Branch part
ALU_add_only ALU_add_only(
    .inA        (IF_ID.PC_add_out), 
    .inB        (sign_extended << 2),  // left shift
    .add_out    ()
);
Instruction_Memory Instruction_Memory(
    .addr_i     (PC_out), 
    .instr_o    (instruction)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (IF_ID.inst_o[25:21]),
    .RTaddr_i   (IF_ID.inst_o[20:16]),
    .RDaddr_i   (MEM_WB.Write_register_o), 
    .RDdata_i   (reg_write_data), 
    .RegWrite_i (MEM_WB.RegWrite_o), 
    .RSdata_o   (), 
    .RTdata_o   () 
);

Sign_Extend Sign_Extend(
    .data_i     (IF_ID.inst_o[15:0]),
    .data_o     (sign_extended)
);

ALU ALU(
    .data1_i    (MUX6.data_o),
    .data2_i    (MUX4.data_o),
    .ALUCtrl_i  (alu_control),
    .data_o     (),
    .Zero_o     (zero)
);

ALU_Control ALU_Control(
    .funct_i    (ID_EX.sign_extended_o[5:0]), //function bit
    .ALUOp_i    (ID_EX.ALUOp_o),
    .ALUCtrl_o  (alu_control)
);

Data_Memory Data_Memory(
    .addr       (EX_MEM.ALU_result_o), // only need 5 bit 
    .write_data (EX_MEM.Mem_Write_Data_o), 
    .read_data  (), // output
    .clk        (clk_i), 
    .reset      (rst_i), 
    .MemRead    (EX_MEM.MemRead_o), 
    .MemWrite   (EX_MEM.MemWrite_o)
);

// Branch Mux1
MUX32 MUX_Branch(
    .data1_i    (Add_PC.data_o), //if 0
    .data2_i    (ALU_add_only.add_out), 
    .select_i   (Control.Branch_o & eq.eq_o), // WARNING: Inline AND Gate!! 
    .data_o     ()    
);
// Jump Mux2
MUX32 MUX_Jump(
    .data1_i    (MUX_Branch.data_o), //if 0
    .data2_i    (jump_address), // if 1
    .select_i   (Control.Jump_o), 
    .data_o     ()    
);
// MUX3
MUX5 MUX_RegDst(
    
    .data1_i    (ID_EX.instruction_o[9:5]), // if 0, default rt
    .data2_i    (ID_EX.instruction_o[4:0]), // if 1, choose rd
    .select_i   (ID_EX.RegDst_o),
    .data_o     (write_register)
);

MUX32 MUX4(
    .data1_i(MUX7.data_o), // if 0
    .data2_i(ID_EX.sign_extended_o), // if 1
    .select_i(ID_EX.ALUSrc_o),
    .data_o()
);
// MUX5
MUX32 MUX_MemtoReg(
    .data1_i    (MEM_WB.ALU_result_o), // if 0
    .data2_i    (MEM_WB.Read_data_o), // if 1
    .select_i   (MEM_WB.MemtoReg_o),
    .data_o     (reg_write_data)
);

MUX_forward MUX6(
    .select_i(ForwardingUnit.ForwardA),
    .data_i(ID_EX.read_data_1_o),
    .forward_EM_i(EX_MEM.ALU_result_o),
    .forward_MW_i(reg_write_data),
    .data_o()
);

MUX_forward MUX7(
    .select_i(ForwardingUnit.ForwardB),
    .data_i(ID_EX.read_data_2_o), // if 00 choose original read_data_2_o(default)
    .forward_EM_i(EX_MEM.ALU_result_o), // if 10 choose prior ALU result
    .forward_MW_i(reg_write_data), // else
    .data_o()
);

MUX8 MUX8(
    .harzard_i(HazardDetection.mux8select_o),
    .signal_i({Control.RegDst_o, Control.ALUOp_o, Control.ALUSrc_o, Control.MemRead_o,
     Control.MemWrite_o, Control.RegWrite_o, Control.MemtoReg_o}),
    .signal_o()
);

HazardDetectionUnit HazardDetection(
    .ID_EX_MemRead(ID_EX.MemRead_o),
    .IF_ID_RSaddr(IF_ID.inst_o[25:21]),
    .IF_ID_RTaddr(IF_ID.inst_o[20:16]),
    .ID_EX_RTaddr(ID_EX.instruction_o[9:5]), 
    .pchazard_o(),
    .IF_ID_hazard_o(),
    .mux8select_o()
);


eq eq(
    .data1_i(Registers.RSdata_o),
    .data2_i(Registers.RTdata_o),
    .eq_o()
);

OR OR(
    .jump_i(Control.Jump_o),
    .branch_i(Control.Branch_o & eq.eq_o), 
    .flush_o()
);

IF_ID IF_ID(
    .clk_i(clk_i),
    .stall(HazardDetection.IF_ID_hazard_o),
    .flush(OR.flush_o),
    .PC_add_4(Add_PC.data_o),
    .instruction(instruction),
    .PC_add_out(),
    .inst_o()
);

ID_EX ID_EX(
    .clk_i(clk_i),
    .MemtoReg(MUX8.signal_o[0]),
    .RegWrite(MUX8.signal_o[1]),
    .MemWrite(MUX8.signal_o[2]),
    .MemRead(MUX8.signal_o[3]),
    .ALUSrc(MUX8.signal_o[4]),
    .ALUOp(MUX8.signal_o[6:5]),
    .RegDst(MUX8.signal_o[7]),
    .PC_add_4(IF_ID.PC_add_out),
    .read_data_1(Registers.RSdata_o),
    .read_data_2(Registers.RTdata_o),
    .sign_extended(sign_extended),
    .instruction(IF_ID.inst_o[25:11]),
    .MemtoReg_o(),
    .RegWrite_o(),
    .MemWrite_o(),
    .MemRead_o(),
    .ALUSrc_o(),
    .ALUOp_o(),
    .RegDst_o(),
    .PC_add_4_o(), // useless
    .read_data_1_o(),
    .read_data_2_o(),
    .sign_extended_o(),
    .instruction_o()
);

EX_MEM EX_MEM(
    .clk_i(clk_i),
    .MemtoReg(ID_EX.MemtoReg_o),
    .RegWrite(ID_EX.RegWrite_o),
    .MemWrite(ID_EX.MemWrite_o),
    .MemRead(ID_EX.MemRead_o),
    .ALU_result(ALU.data_o),
    .Mem_Write_Data(MUX7.data_o),
    .Write_register(write_register),
    .MemtoReg_o(),
    .RegWrite_o(),
    .MemWrite_o(),
    .MemRead_o(),
    .ALU_result_o(),
    .Mem_Write_Data_o(),
    .Write_register_o()
);

MEM_WB MEM_WB(
    .clk_i(clk_i),
    .MemtoReg(EX_MEM.MemtoReg_o),
    .RegWrite(EX_MEM.RegWrite_o),
    .Read_data(Data_Memory.read_data),
    .ALU_result(EX_MEM.ALU_result_o),
    .Write_register(EX_MEM.Write_register_o),
    .MemtoReg_o(),
    .RegWrite_o(),
    .Read_data_o(),
    .ALU_result_o(),
    .Write_register_o()
);

ForwardingUnit ForwardingUnit(
    .clk_i(clk_i),
    .EX_MEM_RegWrite(EX_MEM.RegWrite_o),
    .EX_MEM_RegisterRd(EX_MEM.Write_register_o),
    .ID_EX_RegisterRs(ID_EX.instruction_o[14:10]), //Rs
    .ID_EX_RegisterRt(ID_EX.instruction_o[9:5]), // Rt 
    .MEM_WB_RegWrite(MEM_WB.RegWrite_o),
    .MEM_WB_RegisterRd(MEM_WB.Write_register_o),
    .ForwardA(),
    .ForwardB()
);

endmodule