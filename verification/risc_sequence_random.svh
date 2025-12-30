import uvm_pkg::*;
`include "uvm_macros.svh"

class risc_sequence_random extends uvm_sequence #(risc_program_transaction);
    `uvm_object_utils(risc_sequence_random)

    rand int num_instructions;
    constraint reasonable_count { num_instructions inside {[8:15]}; }

    function new(string name = "risc_sequence_random");
        super.new(name);
    endfunction

    task body();
        risc_program_transaction packet;
        logic [31:0] machine_code;
        risc_instruction_generator instr_gen = new();

        packet = risc_program_transaction::type_id::create("risc_program");
        packet.instructions = new[num_instructions];

        for (int instr = 0; instr < num_instructions; instr++) begin
            machine_code = instr_gen.generate_random_machine_code(num_instructions);
            packet.instructions[instr] = machine_code;
        end

        start_item(packet);
        finish_item(packet);
    endtask

endclass
