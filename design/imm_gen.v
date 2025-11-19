`timescale 1ns / 1ps

module imm_gen(
    input [31:0] in,
    output reg [31:0] out
    );
    
    always@(*) begin
        case(in[6:0])
            // LW (I-type)
            7'b0000011: begin
                out = {{21{in[31]}}, in[30:25], in[24:21], in[20]};
            end
                
            // ADDI + ANDI + ORI + XORI + SLTI + SLTIU + SRLI + SRAI (I-type)
            7'b0010011: begin
                out = {{21{in[31]}}, in[30:25], in[24:21], in[20]};
            end
            
            // SW (S-type)
            7'b0100011: begin
                out = {{21{in[31]}}, in[30:25], in[11:8], in[7]};
            end
            
            // BEQ + BNE + BLT + BGE + BLTU + BGEU (B-type)
            7'b1100011: begin
                out = {{20{in[31]}}, in[7], in[30:25], in[11:8], 1'b0};
            end
            
            default: begin
                out = 32'd0;
            end
                
        endcase  
    end
    
endmodule
