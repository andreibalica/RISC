`timescale 1ns / 1ps

module REG_EX_MEM(
    input clk, res, write,
    input [31:0] PC_in,
    input [2:0] funct3_in,
    input zero_in,
    input [31:0] ALU_in,
    input [31:0] reg2_data_in,
    input [4:0] rd_in,
    input RegWrite_WB_in, MemtoReg_WB_in,
    input Branch_MEM_in, MemRead_MEM_in, MemWrite_MEM_in,
    output reg [31:0] PC_out,
    output reg [2:0] funct3_out,
    output reg zero_out,
    output reg [31:0] ALU_out,
    output reg [31:0] reg2_data_out,
    output reg [4:0] rd_out,
    output reg RegWrite_WB_out, MemtoReg_WB_out,
    output reg Branch_MEM_out, MemRead_MEM_out, MemWrite_MEM_out
    );
    
    always @(posedge clk or negedge res) begin
        if(!res) begin
            PC_out <= 32'd0;
            funct3_out <= 3'd0;
            zero_out <= 1'd0;
            ALU_out <= 32'd0;
            reg2_data_out <= 32'd0;
            rd_out <= 5'd0;
            RegWrite_WB_out <= 1'd0;
            MemtoReg_WB_out <= 1'd0;
            Branch_MEM_out <= 1'd0;
            MemRead_MEM_out <= 1'd0;
            MemWrite_MEM_out <= 1'd0;
        end else if(write) begin
            PC_out <= PC_in;
            funct3_out <= funct3_in;
            zero_out <= zero_in;
            ALU_out <= ALU_in;
            reg2_data_out <= reg2_data_in;
            rd_out <= rd_in;
            RegWrite_WB_out <= RegWrite_WB_in;
            MemtoReg_WB_out <= MemtoReg_WB_in;
            Branch_MEM_out <= Branch_MEM_in;
            MemRead_MEM_out <= MemRead_MEM_in;
            MemWrite_MEM_out <= MemWrite_MEM_in;
        end else begin
            PC_out <= 32'dx;
            funct3_out <= 3'dx;
            zero_out <= 1'bx;
            ALU_out <= 32'dx;
            reg2_data_out <= 32'dx;
            rd_out <= 5'dx;
            RegWrite_WB_out <= 1'bx;
            MemtoReg_WB_out <= 1'bx;
            Branch_MEM_out <= 1'bx;
            MemRead_MEM_out <= 1'bx;
            MemWrite_MEM_out <= 1'bx;
        end
    end
    
endmodule
