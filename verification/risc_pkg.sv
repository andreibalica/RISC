`timescale 1ns / 1ps

package risc_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  `include "risc_defines.svh"

  `include "risc_instruction_transaction.svh"
  `include "risc_program_transaction.svh"
  `include "risc_memory_transaction.svh"

  `include "risc_parser.svh"
  `include "risc_golden_model.svh"
  `include "risc_instruction_generator.svh"
  `include "risc_coverage.svh"

  `include "risc_sequence_random.svh"
  `include "risc_sequencer.svh"

  `include "risc_driver.svh"
  `include "risc_monitor.svh"

  `include "risc_scoreboard.svh"

  `include "risc_agent.svh"

  `include "risc_env.svh"

  `include "risc_test_random.svh"

endpackage
