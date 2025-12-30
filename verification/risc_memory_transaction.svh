import uvm_pkg::*;
`include "uvm_macros.svh"

class risc_memory_transaction extends uvm_sequence_item;
    `uvm_object_utils_begin(risc_memory_transaction)
        `uvm_field_array_int(memory, UVM_DEFAULT)
    `uvm_object_utils_end

    bit [31:0] memory[];

    function new(string name = "risc_memory_transaction");
        super.new(name);
    endfunction

endclass
