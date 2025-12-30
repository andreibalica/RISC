`timescale 1ns / 1ps

module instruction_memory(
    input clk,
    input res,
    input [9:0] address,
    output reg [31:0] instruction
    );
    
    reg [31:0] rom [0:1023];
    
    initial begin
        $readmemh("instructions.mem", rom);
    end

    always @(posedge clk or negedge res) begin
        if (!res) begin
            $readmemh("instructions.mem", rom);
        end
    end

    always@(*) begin
        instruction = rom[address];
    end

endmodule
