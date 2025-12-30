`timescale 1ns / 1ps

import uvm_pkg::*;
import risc_pkg::*;

module top_risc;

    risc_interface risc_if();
    
    RISC_V dut(
        .clk(risc_if.clk),
        .reset(risc_if.reset)
    );

    assign risc_if.instr = dut.INSTRUCTION_ID;
    assign risc_if.pc_current = dut.PC_ID;
    assign risc_if.ram = dut.MEM.DATA_MEMORY.mem;
    assign risc_if.pc_src = dut.PCSrc;

    initial begin
        uvm_config_db#(virtual risc_interface)::set(null, "*", "risc_vif", risc_if);
        uvm_config_db#(int)::set(null, "*", "verbosity", UVM_HIGH);

        run_test("risc_test_random");
    end

endmodule
