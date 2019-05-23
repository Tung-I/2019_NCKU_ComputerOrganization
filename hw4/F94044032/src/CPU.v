// Please include verilog file if you write module in other file

`include "Adder.v"
`include "ALU.v"
`include "ALUCtr_unit.v"
`include "control_unit.v"
`include "Equal.v"
`include "MUX5_2to1.v"
`include "MUX32_2to1.v"
`include "PC.v"
`include "Shift_left_2.v"
`include "Shift_left_2_26to28.v"
`include "Sign_Extend_12to32.v"
`include "Sign_Extend_20to32.v"

module CPU(
    input         clk,
    input         rst,
    output        instr_read,
    output [31:0] instr_addr,
    input  [31:0] instr_out,
    output        data_read,
    output        data_write,
    output [31:0] data_addr,
    output [31:0] data_in,
    input  [31:0] data_out
);

/*ID*/
wire    [6:0]   Funct7;
wire    [4:0]   RS; 
wire    [4:0]   RT; 
wire    [2:0]   Funct3;
wire    [4:0]   RD; 
wire    [6:0]   Opcode;
     
wire    [11:0]  Imm11_0_I;  
wire    [4:0]   Shamt_I;

wire    [6:0]   Imm11_5_S;
wire    [4:0]   Imm4_0_S;
wire 	[11:0]	Imm11_5_4_0_S;

wire            Imm12_B;
wire            Imm11_B;
wire    [5:0]   Imm10_5_B;
wire    [3:0]   Imm4_1_B;
wire 	[11:0]	Imm12_11_10_5_4_1_B;

wire    [19:0]  Imm31_12_U;

wire            Imm20_J;
wire    [7:0]   Imm19_12_J;
wire            Imm11_J;
wire    [9:0]   Imm10_1_J;
wire 	[19:0]	Imm20_19_12_11_10_1_J;


/* */
wire    [31:0]  Immediate32_I
wire    [31:0]  Immediate32_S
wire    [31:0]  Immediate32_B
wire    [31:0]  Immediate32_U
wire    [31:0]  Immediate32_J

wire    [31:0]  Immediate32



/* Address */
wire    [31:0]  PC_in;
wire    [31:0]  PC_out;
wire    [31:0]  Add_PC_out;

/* Control Signal */


wire            PCWrite;

wire            RegDst;
wire            ALUSrc;
wire            MemtoReg;
wire            RegWrite;
wire            MemRead;
wire            MemWrite;
wire            Branch;
wire    [1:0]   ALUOp;

wire    [2:0]   ALUCtrl;

wire            Eq;


/* EX */


wire    [31:0]  MUX1_out;
wire    [31:0]  MUX2_out;
wire    [31:0]  MUX3_out;
wire    [31:0]  ALU_out;


/* MEM */
wire    [31:0]  MemIn;
wire    [31:0]  MemOut;



/* WB */
wire    [31:0]  Mem_out_WB;
wire    [31:0]  ALU_out_WB;



/* Left top */
wire    [27:0]  ShiftLeft28;
wire    [31:0]  Jump_addr;




assign  RS[4:0] = instr_out[24:20];
assign  RT[4:0] = instr_out[19:15];
assign  RD[4:0] = instr_out[11:7];
assign  Opcode[6:0] = instr_out[6:0];
assign  Funct7[6:0] = instr_out[31:25];
assign  Funct3[2:0] = instr_out[14:12];


/* immediate */
assign  Imm11_0_I[15:0] = instr_out[31:20];
assign  Shamt_I[4:0] = instr_out[24:20];

assign  Imm11_5_S[6:0] = instr_out[31:25];
assign  Imm4_0_S[4:0] = instr_out[11:7];
assign 	Imm11_5_4_0_S = {Imm11_5_S, Imm4_0_S};

assign  Imm12_B = instr_out[31];
assign  Imm11_B = instr_out[7];
assign  Imm10_5_B[5:0] = instr_out[30:25];
assign  Imm4_1_B[3:0] = instr_out[11:8];
assign 	Imm12_11_10_5_4_1_B = {Imm12_B, Imm11_B, Imm10_5_B, Imm4_1_B};

assign  Imm31_12_U = instr_out[31:12];

assign  Imm20_J = instr_out[31];
assign  Imm19_12_J[7:0] = instr_out[19:12];
assign  Imm11_J = instr_out[20];
assign  Imm10_1_J[9:0] = instr_out[30:21];
assign 	Imm20_19_12_11_10_1_J = {Imm20_J, Imm19_12_J, Imm11_J, Imm10_1_J};


/* j concat */
assign  jump_addr = { {Add_PC_out[31:28]} , ShiftLeft28 };



PC PC(
    .clk_i      (clk),
    .rst_i      (rst),
    .pc_i       (PC_in),
    .pc_o       (PC_out)
);

Adder Add_PC(
    .data1_i    (PC_out),
    .data2_i    (32'd4),

    .data_o     (Add_PC_out)
);

Shift_Left_2_26to28 Shift_Left_2_26to28(
    .data_i     (IF_ID_inst[25:0]),
    .data_o     (ShiftLeft28)
);



Sign_Extend_12to32 SE_I(
    .data_i     (Imm11_0_I),
    .data_o     (Immediate32_I)
);

Sign_Extend_12to32 SE_S(
    .data_i     (Imm11_5_4_0_S),
    .data_o     (Immediate32_S)
);

Sign_Extend_12to32 SE_B(
    .data_i     (Imm12_11_10_5_4_1_B),
    .data_o     (Immediate32_B)
);

Sign_Extend_20to32 SE_U(
    .data_i     (Imm31_12_U),
    .data_o     (Immediate32_U)
);

Sign_Extend_20to32 SE_J(
    .data_i     (Imm20_19_12_11_10_1_J),
    .data_o     (Immediate32_J)
);




endmodule
