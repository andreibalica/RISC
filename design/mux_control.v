`timescale 1ns / 1ps

module mux_control(
    input [7:0] ina, inb,
    input sel,
    output [7:0] out 
    );
    
    assign out = (sel == 1'b0) ? ina : inb;
    
endmodule
