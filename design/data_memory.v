`timescale 1ns / 1ps

module data_memory(
    input clk,
    input res,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data
    );
    
    reg [31:0] mem [0:1023];
    integer i;
    
    always @(*) begin
        read_data = (mem_read) ? mem[address[11:2]] : 32'bx;
    end
    
    always @(posedge clk or negedge res) begin
        if (!res) begin
            for (i = 0; i < 1024; i = i + 1)
                mem[i] <= 32'd0;
        end else if (mem_write) begin
            mem[address[11:2]] <= write_data;
        end
    end
endmodule
