`timescale 1ns / 1ps

module tb_reg_file();
    
    reg clk, reg_write;
    reg [4:0] read_reg1, read_reg2, write_reg;
    reg [31:0] write_data;
    wire [31:0] read_data1, read_data2;
    
    registers REGISTERS(
        .clk(clk), 
        .reg_write(reg_write), 
        .read_reg1(read_reg1), 
        .read_reg2(read_reg2), 
        .write_reg(write_reg), 
        .write_data(write_data), 
        .read_data1(read_data1), 
        .read_data2(read_data2)
    );
    
    always #5 clk=~clk;
    
    initial begin
        clk = 1'b0;
        reg_write = 1'b0;
        read_reg1 = 5'b0;
        read_reg2 = 5'b0;
        write_reg = 5'b0;
        write_data = 32'b0;

        #10;
       
        // --- TEST 1 Scriere simpla ---
        reg_write = 1'b1;
        write_reg = 5'd10;
        write_data = 32'd99;
        read_reg1 = 5'd10;
        
        #10;
        
        // --- TEST 2: Testare "Write Disable" (reg_write = 0) ---
        reg_write = 1'b0;
        write_reg = 5'd12;
        write_data = 32'd123;
        read_reg1 = 5'd12;
        
        #10;

        // --- TEST 3: Testare scriere in registrul 0 (ar trebui sa esueze) ---
        reg_write = 1'b1;
        write_reg = 5'd0;
        write_data = 32'd444;
        read_reg1 = 5'd0;
        
        #10;
        
        // --- TEST 4: Citiri independente si scriere falsa ---
        read_reg1 = 5'd7;
        read_reg2 = 5'd8;
        reg_write = 1'b1;
        write_reg = 5'd9;
        write_data = 32'd777;
        
        #10; 
        
        // --- TEST 5: Verificare TEST 4 (registrul 9 = 777)---
       
        read_reg1 = 5'd9;
        read_reg2 = 5'd8;
        reg_write = 1'b0;
        write_reg = 5'd16;
        write_data = 32'd0;
        
        #10; 
        
        // --- TEST 6: Verificare registru 2---
        read_reg1 = 5'd30;
        read_reg2 = 5'd22;
        reg_write = 1'b1;
        write_reg = 5'd22;
        write_data = 32'd399;
        
        #10; 
        
        // --- TEST 7: Scriere in ambele registre---
        read_reg1 = 5'd11;
        read_reg2 = 5'd11;
        reg_write = 1'b1;
        write_reg = 5'd11;
        write_data = 32'd907;
        
        
        #20;
        $stop;
    end
    
endmodule
