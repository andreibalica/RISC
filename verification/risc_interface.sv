`timescale 1ns / 1ps

interface risc_interface;
    
    logic clk = 0;
    logic reset = 1;
    
    logic [31:0] instr;
    logic        pc_src;
    logic [31:0] pc_current;
    logic [31:0] ram [0:1023];

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

endinterface
