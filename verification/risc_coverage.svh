import uvm_pkg::*;
`include "uvm_macros.svh"
`include "risc_defines.svh"

class risc_coverage extends uvm_component;

    `uvm_component_utils(risc_coverage)
    uvm_analysis_imp #(risc_instruction_transaction, risc_coverage) analysis_export;

    logic [31:0] instr;
    bit pc_src;
    logic [6:0] opcode;
    logic [4:0] rs1, rs2, rd;
    logic [2:0] funct3;
    logic [6:0] funct7;
    
    covergroup instr_type_cg;
        opcode_cp: coverpoint opcode {
            bins nop = {`OPCODE_NOP};
            bins lw = {`OPCODE_LW};
            bins sw = {`OPCODE_SW};
            bins rtype = {`OPCODE_RTYPE};
            bins itype = {`OPCODE_ITYPE};
            bins branch = {`OPCODE_BRANCH};
        }
    endgroup

    covergroup reg_usage_cg;
        rs1_cp: coverpoint rs1 iff (opcode inside {`OPCODE_RTYPE, `OPCODE_ITYPE, 
                                                    `OPCODE_LW, `OPCODE_SW, `OPCODE_BRANCH}) {
            bins zero = {0};
            bins temporaries[] = {[5:7], [28:31]};
            bins saved[] = {[8:9], [18:27]};
            bins args[] = {[10:17]};
            bins special[] = {1, 2, 3, 4};
        }

        rs2_cp: coverpoint rs2 iff (opcode inside {`OPCODE_RTYPE, `OPCODE_SW, `OPCODE_BRANCH}) {
            bins zero = {0};
            bins temporaries[] = {[5:7], [28:31]};
            bins saved[] = {[8:9], [18:27]};
            bins args[] = {[10:17]};
            bins special[] = {1, 2, 3, 4};
        }

        rd_cp: coverpoint rd iff (opcode inside {`OPCODE_RTYPE, `OPCODE_ITYPE, `OPCODE_LW}) {
            bins zero = {0};
            bins temporaries[] = {[5:7], [28:31]};
            bins saved[] = {[8:9], [18:27]};
            bins args[] = {[10:17]};
            bins special[] = {1, 2, 3, 4};
        }
    endgroup

    covergroup rtype_cg;
        funct_cp: cross funct7, funct3 iff (opcode == `OPCODE_RTYPE) {
            bins add = binsof(funct7) intersect {`FUNCT7_NORMAL} && binsof(funct3) intersect {`FUNCT3_ADD_SUB};
            bins sub = binsof(funct7) intersect {`FUNCT7_ALT} && binsof(funct3) intersect {`FUNCT3_ADD_SUB};
            bins sll = binsof(funct7) intersect {`FUNCT7_NORMAL} && binsof(funct3) intersect {`FUNCT3_SLL};
            bins slt = binsof(funct7) intersect {`FUNCT7_NORMAL} && binsof(funct3) intersect {`FUNCT3_SLT};
            bins sltu = binsof(funct7) intersect {`FUNCT7_NORMAL} && binsof(funct3) intersect {`FUNCT3_SLTU};
            bins xor_op = binsof(funct7) intersect {`FUNCT7_NORMAL} && binsof(funct3) intersect {`FUNCT3_XOR};
            bins srl = binsof(funct7) intersect {`FUNCT7_NORMAL} && binsof(funct3) intersect {`FUNCT3_SRL_SRA};
            bins sra = binsof(funct7) intersect {`FUNCT7_ALT} && binsof(funct3) intersect {`FUNCT3_SRL_SRA};
            bins or_op = binsof(funct7) intersect {`FUNCT7_NORMAL} && binsof(funct3) intersect {`FUNCT3_OR};
            bins and_op = binsof(funct7) intersect {`FUNCT7_NORMAL} && binsof(funct3) intersect {`FUNCT3_AND};
        }
    endgroup

    covergroup itype_cg;
        funct3_i_cp: coverpoint funct3 iff (opcode == `OPCODE_ITYPE) {
            bins addi = {`FUNCT3_ADD_SUB};
            bins slli = {`FUNCT3_SLL};
            bins slti = {`FUNCT3_SLT};
            bins sltiu = {`FUNCT3_SLTU};
            bins xori = {`FUNCT3_XOR};
            bins srli_srai = {`FUNCT3_SRL_SRA};
            bins ori = {`FUNCT3_OR};
            bins andi = {`FUNCT3_AND};
        }
    endgroup

    covergroup branch_cg;
        funct3_b_cp: coverpoint funct3 iff (opcode == `OPCODE_BRANCH) {
            bins beq = {`FUNCT3_BEQ};
            bins bne = {`FUNCT3_BNE};
            bins blt = {`FUNCT3_BLT};
            bins bge = {`FUNCT3_BGE};
            bins bltu = {`FUNCT3_BLTU};
            bins bgeu = {`FUNCT3_BGEU};
        }
        branch_taken_cp: coverpoint pc_src;
        cross_cp: cross funct3_b_cp, branch_taken_cp;
    endgroup

    function new(string name = "risc_coverage", uvm_component parent = null);
        super.new(name, parent);
        analysis_export = new("analysis_export", this);
        instr_type_cg = new();
        reg_usage_cg = new();
        rtype_cg = new();
        itype_cg = new();
        branch_cg = new();
    endfunction

    function void write(risc_instruction_transaction t);
        instr = t.instr;
        pc_src = t.pc_src;
        opcode = instr[6:0];
        rd = instr[11:7];
        funct3 = instr[14:12];
        rs1 = instr[19:15];
        rs2 = instr[24:20];
        funct7 = instr[31:25];
        
        instr_type_cg.sample();
        reg_usage_cg.sample();
        rtype_cg.sample();
        itype_cg.sample();
        branch_cg.sample();
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("COVERAGE", $sformatf("Instruction Type Coverage: %.2f%%", instr_type_cg.get_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("Register Usage Coverage: %.2f%%", reg_usage_cg.get_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("R-Type Coverage: %.2f%%", rtype_cg.get_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("I-Type Coverage: %.2f%%", itype_cg.get_coverage()), UVM_LOW)
        `uvm_info("COVERAGE", $sformatf("Branch Coverage: %.2f%%", branch_cg.get_coverage()), UVM_LOW)
    endfunction

endclass
