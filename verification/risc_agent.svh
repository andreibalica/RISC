import uvm_pkg::*;
`include "uvm_macros.svh"

class risc_agent extends uvm_agent;
    `uvm_component_utils(risc_agent)

    risc_driver    driver;
    risc_sequencer  sequencer;
    risc_monitor   monitor;

    function new(string name = "risc_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver = risc_driver::type_id::create("driver", this);
        sequencer = risc_sequencer::type_id::create("sequencer", this);
        monitor = risc_monitor::type_id::create("monitor", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
