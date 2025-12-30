import uvm_pkg::*;
`include "uvm_macros.svh"
`include "risc_defines.svh"

class risc_monitor extends uvm_monitor;
    `uvm_component_utils(risc_monitor)

    virtual risc_interface i;
    uvm_analysis_port #(risc_memory_transaction) memory_inport;
    uvm_analysis_port #(risc_instruction_transaction) instr_inport;
    
    risc_parser parser;

    int max_instructions_per_program = 50; 
    int instructions_executed = 0;

    function new(string name = "risc_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        memory_inport = new("memory_inport", this);
        instr_inport = new("instr_inport", this);
        parser = new("parser");
        void'(uvm_config_db#(virtual risc_interface)::get(this, "", "risc_vif", i));
    endfunction

    task run_phase(uvm_phase phase);
        risc_instruction_transaction instr_tr;
        logic [31:0] instr;
        string instr_decoded;

        forever begin
            @(posedge i.clk);
            
            if (i.reset) begin

                if(instructions_executed == 0) begin
                    `uvm_info("MONITOR", "=== START OF NEW PROGRAM ===", UVM_MEDIUM)
                end

                instructions_executed++;
                instr = i.instr;

                if ($isunknown(instr) || instructions_executed > max_instructions_per_program) begin
                    `uvm_info("MONITOR", $sformatf("=== END OF PROGRAM (after %0d instructions) ===", instructions_executed), UVM_MEDIUM)
                    collect_memory();
                    instructions_executed = 0;
                    
                    @(negedge i.reset);
                    @(posedge i.reset); 
                    
                    continue;
                end

                instr_tr = risc_instruction_transaction::type_id::create("instr_tr");

                instr_decoded = parser.decode_machine_code(instr);
                `uvm_info("MONITOR", $sformatf("PC=0x%08h | Machine: 0x%08h | Assembly: %s | Branch: %b", 
                         i.pc_current, instr, instr_decoded, i.pc_src), UVM_MEDIUM)
                
                instr_tr.instr = instr;
                instr_tr.pc_src = i.pc_src;
                
                instr_inport.write(instr_tr);
            end
        end
    endtask

    function void collect_memory();
        risc_memory_transaction mem_tr;
        mem_tr = risc_memory_transaction::type_id::create("mem_tr");
        mem_tr.memory = new[1024];
        for (int idx = 0; idx < 1024; idx++) begin
            mem_tr.memory[idx] = i.ram[idx];
        end
        memory_inport.write(mem_tr);
    endfunction

endclass
