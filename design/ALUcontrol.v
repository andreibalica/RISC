`timescale 1ns / 1ps

module ALUcontrol(
    input [1:0] ALUop,
    input [6:0] funct7,
    input [2:0] funct3,
    output reg [3:0] ALUinput
    );

    always@(*) begin
        casex({ALUop, funct7, funct3})
            // lw / sw
            12'b00_xxxxxxx_xxx: ALUinput = 4'b0010;
            // beq / bne
            12'b01_xxxxxxx_00x: ALUinput = 4'b0110;
            // blt / bge
            12'b01_xxxxxxx_10x: ALUinput = 4'b1000;
            // bltu / bgeu
            12'b01_xxxxxxx_11x: ALUinput = 4'b0111;            
            // sub
            12'b10_0100000_000: ALUinput = 4'b0110; 
            // add / addi 
            12'b1x_xxxxxxx_000: ALUinput = 4'b0010;
            // sll / slli
            12'b1x_0000000_001: ALUinput = 4'b0100;
            // slt / slti
            12'b1x_xxxxxxx_010: ALUinput = 4'b1000;
            // sltu / sltiu
            12'b1x_xxxxxxx_011: ALUinput = 4'b0111;
            // xor / xori
            12'b1x_xxxxxxx_100: ALUinput = 4'b0011;
            // srl / srli
            12'b1x_0000000_101: ALUinput = 4'b0101;
            // sra / srai
            12'b1x_0100000_101: ALUinput = 4'b1001;
            // or / ori
            12'b1x_xxxxxxx_110: ALUinput = 4'b0001;
            // and / andi
            12'b1x_xxxxxxx_111: ALUinput = 4'b0000;
            default: ALUinput = 4'bxxxx;
        endcase
    end
endmodule