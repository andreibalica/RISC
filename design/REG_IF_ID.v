`timescale 1ns / 1ps

module REG_IF_ID(
    input clk, res, write,
    input [31:0] PC_in,
    input [31:0] instruction_in,
    output reg [31:0] PC_out,
    output reg [31:0] instruction_out
    );
    
    always @(posedge clk or negedge res) begin
        if(!res) begin
            PC_out <= 32'd0;
            instruction_out <= 32'd0;
        end else if(write) begin
            PC_out <= PC_in;
            instruction_out <= instruction_in;
        end else begin
            PC_out <= 32'dx;
            instruction_out <= 32'dx;
        end
    end
    
endmodule
