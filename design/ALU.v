`timescale 1ns / 1ps

module ALU(
    input [3:0] ALUop,
    input [31:0] ina, inb,
    output zero,
    output reg [31:0] out
    );
    
    always@(*) begin
        case(ALUop)
            // and / andi
            4'b0000: out = ina & inb;
            // or / ori
            4'b0001: out = ina | inb;    
            // lw / sw / add / addi 
            4'b0010: out = ina + inb;
            // xor / xori
            4'b0011: out = ina ^ inb;
            // sll / slli
            4'b0100: out = ina << inb;
            // srl / srli
            4'b0101: out = ina >> inb;
            // sub / beq / bne
            4'b0110: out = ina - inb;
            // sltu / bltu / bgeu
            4'b0111: out = (ina < inb) ? 32'd1 : 32'd0;
            // slt / blt / bge 
            4'b1000: out = ($signed(ina) < $signed(inb)) ? 32'd1 : 32'd0;
            // sra / srai
            4'b1001: out = ina >>> inb;
            default: out = 32'dX;            
        endcase
    end
    
    assign zero = (out == 32'd0) ? 1'b1 : 1'b0;
endmodule
