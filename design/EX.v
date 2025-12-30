`timescale 1ns / 1ps

module EX(
    input [31:0] IMM_EX,
    input [31:0] REG_DATA1_EX,
    input [31:0] REG_DATA2_EX,
    input [31:0] PC_EX,
    input [2:0] FUNCT3_EX,
    input [6:0] FUNCT7_EX,
    input [4:0] RD_EX,
    input [4:0] RS1_EX,
    input [4:0] RS2_EX,
    input RegWrite_EX,
    input MemtoReg_EX,
    input MemRead_EX,
    input MemWrite_EX,
    input [1:0] ALUop_EX,
    input ALUSrc_EX,
    input Branch_EX,
    input [4:0] RD_MEM,
    input [4:0] RD_WB,
    input RegWrite_MEM,
    input RegWrite_WB,
    input [31:0] ALU_DATA_WB,
    input [31:0] ALU_OUT_MEM,
    output ZERO_EX,
    output [31:0] ALU_OUT_EX,
    output [31:0] PC_BRANCH_EX,
    output [31:0] REG_DATA2_EX_FINAL,
    output [4:0] RD_EX_out,
    output RegWrite_EX_out,
    output MemtoReg_EX_out,
    output MemRead_EX_out,
    output MemWrite_EX_out,
    output Branch_EX_out,
    output [1:0] forwardA_out,
    output [1:0] forwardB_out
    );
    
    wire [31:0] ALU_Source1, ALU_Source2;
    wire [31:0] MUX_B_temp;
    wire [3:0] ALU_Control;
    wire [1:0] forwardA, forwardB;
    
    assign REG_DATA2_EX_FINAL = MUX_B_temp;
    assign RD_EX_out = RD_EX;
    assign RegWrite_EX_out = RegWrite_EX;
    assign MemtoReg_EX_out = MemtoReg_EX;
    assign MemRead_EX_out = MemRead_EX;
    assign MemWrite_EX_out = MemWrite_EX;
    assign Branch_EX_out = Branch_EX;
    assign forwardA_out = forwardA;
    assign forwardB_out = forwardB;
    
    forwarding FORWARDING_UNIT(RS1_EX, RS2_EX, RD_MEM, RD_WB, RegWrite_MEM, RegWrite_WB, forwardA, forwardB);
    adder ADDER(PC_EX, IMM_EX, PC_BRANCH_EX);
    mux3_1 MUX_FORWARD_A(REG_DATA1_EX, ALU_DATA_WB, ALU_OUT_MEM, forwardA, ALU_Source1);
    mux3_1 MUX_FORWARD_B(REG_DATA2_EX, ALU_DATA_WB, ALU_OUT_MEM, forwardB, MUX_B_temp);
    mux2_1 MUX_ALUSrc(MUX_B_temp, IMM_EX, ALUSrc_EX, ALU_Source2);
    ALUcontrol ALU_CONTROL(ALUop_EX, FUNCT7_EX, FUNCT3_EX, ALU_Control);
    ALU ALU(ALU_Control, ALU_Source1, ALU_Source2, ZERO_EX, ALU_OUT_EX);
endmodule
