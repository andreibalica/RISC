`timescale 1ns / 1ps

module registers(
    input clk, reg_write,
    input [4:0] read_reg1, read_reg2, write_reg,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2
    );
    
    reg [31:0] mem_reg [0:31];
    integer i;
    
    initial begin
        for(i = 0; i < 32; i = i + 1) begin
            mem_reg[i] = i;
        end         
    end
    
    always@(posedge clk) begin
        if(reg_write) begin
            if(write_reg != 5'h0) begin
                mem_reg[write_reg] = write_data;
            end
        end
    end
    
    assign read_data1 = mem_reg[read_reg1];
    assign read_data2 = mem_reg[read_reg2];
endmodule
