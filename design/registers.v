`timescale 1ns / 1ps

module registers(
    input clk, 
    input res,
    input reg_write,
    input [4:0] read_reg1, read_reg2, write_reg,
    input [31:0] write_data,
    output [31:0] read_data1, read_data2
    );
    
    reg [31:0] mem_reg [0:31];
    integer i;
    
    always@(posedge clk or negedge res) begin
        if (!res) begin
            for (i = 0; i < 32; i = i + 1)
                mem_reg[i] <= 32'd0;
        end else if (reg_write) begin
            if(write_reg != 5'h0) begin
                mem_reg[write_reg] <= write_data;
            end
        end
    end
    
    assign read_data1 = (reg_write && (write_reg == read_reg1) && (write_reg != 0)) 
                        ? write_data 
                        : mem_reg[read_reg1];
    assign read_data2 = (reg_write && (write_reg == read_reg2) && (write_reg != 0)) 
                        ? write_data 
                        : mem_reg[read_reg2];
endmodule
