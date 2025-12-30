`timescale 1ns / 1ps

module WB(
    input MemtoReg_WB,
    input [31:0] DATA_MEMORY_WB,
    input [31:0] ALU_OUT_WB,
    output [31:0] ALU_DATA_WB
    );
    
    mux2_1 MUX_WB(ALU_OUT_WB, DATA_MEMORY_WB, MemtoReg_WB, ALU_DATA_WB);
endmodule
