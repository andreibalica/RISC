`timescale 1ns / 1ps

module REG_MEM_WB(
    input clk, res, write,
    input [31:0] data_in,
    input [31:0] alu_in,
    input [4:0] rd_in,
    input RegWrite_WB_in, MemtoReg_WB_in,
    output reg [31:0] data_out,
    output reg [31:0] alu_out,
    output reg [4:0] rd_out,
    output reg RegWrite_WB_out, MemtoReg_WB_out
    );
    
    always @(posedge clk or negedge res) begin
        if(!res) begin
            data_out <= 32'd0;
            alu_out <= 32'd0;
            rd_out <= 5'd0;
            RegWrite_WB_out <= 1'd0;
            MemtoReg_WB_out <= 1'd0;
        end else if(write) begin
            data_out <= data_in;
            alu_out <= alu_in;
            rd_out <= rd_in;
            RegWrite_WB_out <= RegWrite_WB_in;
            MemtoReg_WB_out <= MemtoReg_WB_in;
        end else begin
            data_out <= 32'dx;
            alu_out <= 32'dx;
            rd_out <= 5'dx;
            RegWrite_WB_out <= 1'bx;
            MemtoReg_WB_out <= 1'bx;
        end
    end
    
endmodule
