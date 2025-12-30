import uvm_pkg::*;
`include "uvm_macros.svh"

class risc_driver extends uvm_driver #(risc_program_transaction);
    `uvm_component_utils(risc_driver)

    virtual risc_interface i;

    function new(string name = "risc_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_config_db#(virtual risc_interface)::get(this, "", "risc_vif", i));
    endfunction

    task run_phase(uvm_phase phase);
        risc_program_transaction packet;
        
        forever begin
            seq_item_port.get_next_item(packet);
            process_instructions(packet);
            seq_item_port.item_done();
        end
        
    endtask

    task process_instructions(risc_program_transaction packet);
        int instruction_count;
        int instructions_executed = 0;
        int max_instructions_per_program = 50;
        
        instruction_count = packet.instructions.size();
        
        $writememh("instructions.mem", packet.instructions);
        for (int instr = 0; instr < instruction_count; instr++) begin
            `uvm_info("DRIVER", $sformatf("Written to instructions.mem: %08h", packet.instructions[instr]), UVM_DEBUG)
        end
        `uvm_info("DRIVER", $sformatf("Generated instructions.mem with %0d instructions", instruction_count), UVM_MEDIUM)
        
        #1ns;
        
        `uvm_info("DRIVER", "Resetting DUT for new program", UVM_MEDIUM)
        i.reset = 0;
        repeat(3) @(posedge i.clk);
        i.reset = 1;
        @(posedge i.clk);

        do begin
            @(posedge i.clk);
            instructions_executed++;
        end while (!$isunknown(i.instr) && instructions_executed <= max_instructions_per_program);

    endtask

endclass
