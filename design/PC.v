`timescale 1ns / 1ps

module PC(
    input clk, res, write,
    input [31:0] in,
    output reg [31:0] out
    );
    
    always @(posedge clk or negedge res) begin
        if(!res) begin
            out <= 32'h0;
        end else if(write) begin
            out <= in;
        end
    end
endmodule
