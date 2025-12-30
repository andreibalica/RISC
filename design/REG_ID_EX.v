`timescale 1ns / 1ps

module REG_ID_EX(
    input clk, res, write,
    input [31:0] PC_in,
    input [2:0] funct3_in,
    input [6:0] funct7_in,
    input [31:0] ALU_A_in, ALU_B_in, 
    input [4:0] RS1_in, RS2_in, RD_in,
    input [31:0] IMM_in,
    input RegWrite_WB_in, MemtoReg_WB_in,
    input Branch_MEM_in, MemRead_MEM_in, MemWrite_MEM_in,
    input [1:0] ALUop_EX_in,
    input ALUSrc_in, 
    output reg [31:0] PC_out,
    output reg [2:0] funct3_out,
    output reg [6:0] funct7_out,
    output reg [31:0] ALU_A_out, ALU_B_out, 
    output reg [4:0] RS1_out, RS2_out, RD_out,
    output reg [31:0] IMM_out,
    output reg RegWrite_WB_out, MemtoReg_WB_out,
    output reg Branch_MEM_out, MemRead_MEM_out, MemWrite_MEM_out,
    output reg [1:0] ALUop_EX_out,
    output reg ALUSrc_out 
    );
    
    always @(posedge clk or negedge res) begin
        if(!res) begin
            PC_out <= 32'd0;
            funct3_out <= 3'd0;
            funct7_out <= 7'd0;
            ALU_A_out <= 32'd0;
            ALU_B_out <= 32'd0;
            RS1_out <= 5'd0;
            RS2_out <= 5'd0;
            RD_out <= 5'd0;
            IMM_out <= 32'd0;
            RegWrite_WB_out <= 1'd0;
            MemtoReg_WB_out <= 1'd0;
            Branch_MEM_out <= 1'd0;
            MemRead_MEM_out <= 1'd0;
            MemWrite_MEM_out <= 1'd0;
            ALUop_EX_out <= 2'd0;
            ALUSrc_out <= 1'd0;
        end else if(write) begin
            PC_out <= PC_in;
            funct3_out <= funct3_in;
            funct7_out <= funct7_in;
            ALU_A_out <= ALU_A_in;
            ALU_B_out <= ALU_B_in;
            RS1_out <= RS1_in;
            RS2_out <= RS2_in;
            RD_out <= RD_in;
            IMM_out <= IMM_in;
            RegWrite_WB_out <= RegWrite_WB_in;
            MemtoReg_WB_out <= MemtoReg_WB_in;
            Branch_MEM_out <= Branch_MEM_in;
            MemRead_MEM_out <= MemRead_MEM_in;
            MemWrite_MEM_out <= MemWrite_MEM_in;
            ALUop_EX_out <= ALUop_EX_in;
            ALUSrc_out <= ALUSrc_in;
        end else begin
            PC_out <= 32'dx;
            funct3_out <= 3'dx;
            funct7_out <= 7'dx;
            ALU_A_out <= 32'dx;
            ALU_B_out <= 32'dx;
            RS1_out <= 5'dx;
            RS2_out <= 5'dx;
            RD_out <= 5'dx;
            IMM_out <= 32'dx;
            RegWrite_WB_out <= 1'bx;
            MemtoReg_WB_out <= 1'bx;
            Branch_MEM_out <= 1'bx;
            MemRead_MEM_out <= 1'bx;
            MemWrite_MEM_out <= 1'bx;
            ALUop_EX_out <= 2'dx;
            ALUSrc_out <= 1'bx;
        end
    end
    
endmodule
