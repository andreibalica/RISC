`timescale 1ns / 1ps

module IF(
    input clk, reset,
    input PCSrc, PC_write,
    input [31:0] PC_Branch,
    output [31:0] PC_IF, INSTRUCTION_IF
    );
    
    wire [31:0] PC_mux, PC_IF_4;
    
    mux2_1 MUX(PC_IF_4, PC_Branch, PCSrc, PC_mux);
    PC PC(clk, reset, PC_write, PC_mux, PC_IF);
    instruction_memory INSTRUCTION_MEMORY(PC_IF[11:2], INSTRUCTION_IF);
    adder ADDER(PC_IF, 32'h4, PC_IF_4);
    
endmodule
