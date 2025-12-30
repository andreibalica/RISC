`timescale 1ns / 1ps

module ID(
    input clk,
    input reset,
    input [31:0] PC_ID, INSTRUCTION_ID,
    input RegWrite_WB,
    input [31:0] ALU_DATA_WB,
    input [4:0] RD_EX,
    input [4:0] RD_WB,
    input MemRead_EX,
    output [31:0] IMM_ID,
    output [31:0] REG_DATA1_ID, REG_DATA2_ID,
    output [2:0] FUNCT3_ID,
    output [6:0] FUNCT7_ID,
    output [4:0] RD_ID,
    output [4:0] RS1_ID,
    output [4:0] RS2_ID,
    output PC_write,
    output IF_ID_Write,
    output RegWrite_ID,
    output MemtoReg_ID,
    output MemRead_ID,
    output MemWrite_ID,
    output Branch_ID,
    output ALUSrc_ID,
    output [1:0] ALUop_ID
    );
    
    wire Control_sel;
    wire [6:0] OPCODE_ID;
    wire Branch_temp, MemRead_temp, MemtoReg_temp, MemWrite_temp, ALUSrc_temp, RegWrite_temp;
    wire [1:0] ALUop_temp;
    assign FUNCT3_ID = INSTRUCTION_ID[14:12];
    assign FUNCT7_ID = INSTRUCTION_ID[31:25];
    assign OPCODE_ID = INSTRUCTION_ID[6:0];
    assign RD_ID = INSTRUCTION_ID[11:7];
    assign RS1_ID = INSTRUCTION_ID[19:15];
    assign RS2_ID = INSTRUCTION_ID[24:20]; 
    control_path CONTROL_PATH(OPCODE_ID, Branch_temp, MemRead_temp, MemtoReg_temp, ALUop_temp, MemWrite_temp, ALUSrc_temp, RegWrite_temp);
    mux_control MUX_CONTROL(8'b0, {ALUSrc_temp, MemtoReg_temp, RegWrite_temp, MemRead_temp, MemWrite_temp, Branch_temp, ALUop_temp},
                            Control_sel, {ALUSrc_ID, MemtoReg_ID, RegWrite_ID, MemRead_ID, MemWrite_ID, Branch_ID, ALUop_ID});
    registers REGISTERS(clk, reset, RegWrite_WB, RS1_ID, RS2_ID, RD_WB, ALU_DATA_WB, REG_DATA1_ID, REG_DATA2_ID);
    imm_gen IMM_GEN(INSTRUCTION_ID, IMM_ID);
    hazard_detection HAZARD_DETECTION(RD_EX, RS1_ID, RS2_ID, MemRead_EX, PC_write, IF_ID_Write, Control_sel);
    
endmodule
