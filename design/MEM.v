`timescale 1ns / 1ps

module MEM(
    input clk,
    input reset,
    input [31:0] ALU_OUT_MEM,
    input ZERO_MEM,
    input [31:0] PC_MEM,
    input [31:0] REG_DATA2_MEM,
    input [4:0] RD_MEM,
    input [2:0] FUNCT3_MEM,
    input RegWrite_MEM,
    input MemtoReg_MEM,
    input MemRead_MEM,
    input MemWrite_MEM,
    input Branch_MEM,
    output [31:0] PC_MEM_out,
    output [31:0] ALU_OUT_MEM_WB,
    output [31:0] DATA_MEMORY_MEM,
    output [4:0] RD_MEM_out,
    output RegWrite_MEM_out,
    output MemtoReg_MEM_out,
    output PCSrc_MEM
    );
    
    assign PC_MEM_out = PC_MEM;
    assign ALU_OUT_MEM_WB = ALU_OUT_MEM;
    assign RD_MEM_out = RD_MEM;
    assign RegWrite_MEM_out = RegWrite_MEM;
    assign MemtoReg_MEM_out = MemtoReg_MEM;
    data_memory DATA_MEMORY(clk, reset, MemRead_MEM, MemWrite_MEM, ALU_OUT_MEM, REG_DATA2_MEM, DATA_MEMORY_MEM);
    branch_control BRANCH_CONTROL(ZERO_MEM, ALU_OUT_MEM[0], Branch_MEM, FUNCT3_MEM, PCSrc_MEM);
endmodule
