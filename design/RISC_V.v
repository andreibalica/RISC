`timescale 1ns / 1ps

module RISC_V(
    input clk,
    input reset
    );
    
    // IF
    wire [31:0] PC_IF, INSTRUCTION_IF;
    wire PCSrc, PC_write, IF_ID_write;
    
    // IF/ID
    wire [31:0] PC_ID, INSTRUCTION_ID;
    
    // ID
    wire [31:0] IMM_ID, REG_DATA1_ID, REG_DATA2_ID;
    wire [2:0] funct3_ID;
    wire [6:0] funct7_ID;
    wire [4:0] RD_ID, RS1_ID, RS2_ID;
    wire RegWrite_ID, MemtoReg_ID, MemRead_ID, MemWrite_ID, Branch_ID, ALUSrc_ID;
    wire [1:0] ALUop_ID;
    
    // ID/EX 
    wire [31:0] PC_EX, IMM_EX, REG_DATA1_EX, REG_DATA2_EX;
    wire [2:0] funct3_EX;
    wire [6:0] funct7_EX;
    wire [4:0] RD_EX, RS1_EX, RS2_EX;
    wire RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX, Branch_EX, ALUSrc_EX;
    wire [1:0] ALUop_EX;
    
    // EX
    wire zero_EX;
    wire [31:0] PC_Branch_EX, ALU_OUT_EX, REG_DATA2_EX_FINAL;
    wire [4:0] RD_EX_out;
    wire [1:0] forwardA, forwardB;
    wire RegWrite_EX_out, MemtoReg_EX_out, MemRead_EX_out, MemWrite_EX_out, Branch_EX_out;
    
    // EX/MEM 
    wire [31:0] ALU_OUT_MEM, REG_DATA2_MEM;
    wire [2:0] funct3_MEM;
    wire zero_MEM;
    wire [4:0] RD_MEM;
    wire RegWrite_MEM, MemtoReg_MEM, MemRead_MEM, MemWrite_MEM, Branch_MEM;
    
    // MEM 
    wire [31:0] PC_MEM, DATA_MEMORY_MEM;
    wire [31:0] ALU_OUT_MEM_WB;
    wire [4:0] RD_MEM_out;
    wire RegWrite_MEM_out, MemtoReg_MEM_out;
    
    // MEM/WB 
    wire [31:0] DATA_MEMORY_WB, ALU_OUT_WB;
    wire [4:0] RD_WB;
    wire RegWrite_WB, MemtoReg_WB;
    
    // WB
    wire [31:0] ALU_DATA_WB;
    wire [31:0] PC_MEM_out;
    
    IF IF(clk, reset, PCSrc, PC_write, PC_MEM_out, PC_IF, INSTRUCTION_IF);
    REG_IF_ID REG_IF_ID(clk, reset, IF_ID_write, PC_IF, INSTRUCTION_IF, PC_ID, INSTRUCTION_ID);
    ID ID(clk, reset, PC_ID, INSTRUCTION_ID, RegWrite_WB, ALU_DATA_WB, RD_EX, RD_WB, MemRead_EX,
          IMM_ID, REG_DATA1_ID, REG_DATA2_ID, funct3_ID, funct7_ID, RD_ID, RS1_ID, RS2_ID,
          PC_write, IF_ID_write, RegWrite_ID, MemtoReg_ID, MemRead_ID, MemWrite_ID, Branch_ID, ALUSrc_ID, ALUop_ID);
    REG_ID_EX REG_ID_EX(clk, reset, 1'b1, PC_ID, funct3_ID, funct7_ID, REG_DATA1_ID, REG_DATA2_ID,
                RS1_ID, RS2_ID, RD_ID, IMM_ID, RegWrite_ID, MemtoReg_ID, Branch_ID, MemRead_ID, MemWrite_ID, ALUop_ID, ALUSrc_ID,
                PC_EX, funct3_EX, funct7_EX, REG_DATA1_EX, REG_DATA2_EX,
                RS1_EX, RS2_EX, RD_EX, IMM_EX, RegWrite_EX, MemtoReg_EX, Branch_EX, MemRead_EX, MemWrite_EX, ALUop_EX, ALUSrc_EX);
    EX EX(IMM_EX, REG_DATA1_EX, REG_DATA2_EX, PC_EX, funct3_EX, funct7_EX, RD_EX, RS1_EX, RS2_EX,
          RegWrite_EX, MemtoReg_EX, MemRead_EX, MemWrite_EX, ALUop_EX, ALUSrc_EX, Branch_EX,
          RD_MEM, RD_WB, RegWrite_MEM, RegWrite_WB, ALU_DATA_WB, ALU_OUT_MEM,
          zero_EX, ALU_OUT_EX, PC_Branch_EX, REG_DATA2_EX_FINAL, RD_EX_out,
          RegWrite_EX_out, MemtoReg_EX_out, MemRead_EX_out, MemWrite_EX_out, Branch_EX_out,
          forwardA, forwardB);
    REG_EX_MEM REG_EX_MEM(clk, reset, 1'b1, PC_Branch_EX, funct3_EX, zero_EX, ALU_OUT_EX, REG_DATA2_EX_FINAL, RD_EX_out,
                  RegWrite_EX_out, MemtoReg_EX_out, Branch_EX_out, MemRead_EX_out, MemWrite_EX_out,
                  PC_MEM, funct3_MEM, zero_MEM, ALU_OUT_MEM, REG_DATA2_MEM, RD_MEM,
                  RegWrite_MEM, MemtoReg_MEM, Branch_MEM, MemRead_MEM, MemWrite_MEM);
    MEM MEM(clk, reset, ALU_OUT_MEM, zero_MEM, PC_MEM, REG_DATA2_MEM, RD_MEM, funct3_MEM,
            RegWrite_MEM, MemtoReg_MEM, MemRead_MEM, MemWrite_MEM, Branch_MEM,
            PC_MEM_out, ALU_OUT_MEM_WB, DATA_MEMORY_MEM, RD_MEM_out,
            RegWrite_MEM_out, MemtoReg_MEM_out, PCSrc);
    REG_MEM_WB REG_MEM_WB(clk, reset, 1'b1, DATA_MEMORY_MEM, ALU_OUT_MEM_WB, RD_MEM_out,
                  RegWrite_MEM_out, MemtoReg_MEM_out,
                  DATA_MEMORY_WB, ALU_OUT_WB, RD_WB,
                  RegWrite_WB, MemtoReg_WB);
    WB WB(MemtoReg_WB, DATA_MEMORY_WB, ALU_OUT_WB, ALU_DATA_WB); 
endmodule
