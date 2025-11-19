`timescale 1ns / 1ps

module instruction_memory(
    input [9:0] address,
    output reg [31:0] instruction
    );
    
    reg [31:0] mem [0:1023];

    integer i;
    initial begin
        for (i=0; i<=1023; i=i+1)
            mem[i] = 8'h00; 
        $readmemb("code.mem", mem);
    end

    always@(*) begin
        instruction = mem[address];
    end

endmodule
