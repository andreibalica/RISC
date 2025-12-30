import uvm_pkg::*;
`include "uvm_macros.svh"
`include "risc_defines.svh"

class risc_parser extends uvm_object;
    `uvm_object_utils(risc_parser)

    function string get_register_name(int reg_num);
        case(reg_num)
            0: return "x0/zero";  1: return "x1/ra";    2: return "x2/sp";    3: return "x3/gp";
            4: return "x4/tp";    5: return "x5/t0";    6: return "x6/t1";    7: return "x7/t2";
            8: return "x8/s0";    9: return "x9/s1";    10: return "x10/a0";  11: return "x11/a1";
            12: return "x12/a2";  13: return "x13/a3";  14: return "x14/a4";  15: return "x15/a5";
            16: return "x16/a6";  17: return "x17/a7";  18: return "x18/s2";  19: return "x19/s3";
            20: return "x20/s4";  21: return "x21/s5";  22: return "x22/s6";  23: return "x23/s7";
            24: return "x24/s8";  25: return "x25/s9";  26: return "x26/s10"; 27: return "x27/s11";
            28: return "x28/t3";  29: return "x29/t4";  30: return "x30/t5";  31: return "x31/t6";
            default: return "x0/zero";
        endcase
    endfunction

    function new(string name = "risc_parser");
        super.new(name);
    endfunction

    function string decode_machine_code(logic [31:0] machine_code);
        logic [6:0] opcode = machine_code[6:0];
        logic [4:0] rd = machine_code[11:7];
        logic [2:0] funct3 = machine_code[14:12];
        logic [4:0] rs1 = machine_code[19:15];
        logic [4:0] rs2 = machine_code[24:20];
        logic [6:0] funct7 = machine_code[31:25];
        logic [11:0] imm_i = machine_code[31:20];
        logic [11:0] imm_s = {machine_code[31:25], machine_code[11:7]};
        logic [12:0] imm_b = {machine_code[31], machine_code[7], machine_code[30:25], machine_code[11:8], 1'b0};
        string result;
        
        case(opcode)
            `OPCODE_NOP: begin
                result = "nop";
            end
            
            `OPCODE_RTYPE: begin
                case({funct7, funct3})
                    {`FUNCT7_NORMAL, `FUNCT3_ADD_SUB}: result = $sformatf("add %s, %s, %s", 
                        get_register_name(rd), get_register_name(rs1), get_register_name(rs2));
                    {`FUNCT7_ALT, `FUNCT3_ADD_SUB}: result = $sformatf("sub %s, %s, %s", 
                        get_register_name(rd), get_register_name(rs1), get_register_name(rs2));
                    {`FUNCT7_NORMAL, `FUNCT3_SLL}: result = $sformatf("sll %s, %s, %s", 
                        get_register_name(rd), get_register_name(rs1), get_register_name(rs2));
                    {`FUNCT7_NORMAL, `FUNCT3_SLT}: result = $sformatf("slt %s, %s, %s", 
                        get_register_name(rd), get_register_name(rs1), get_register_name(rs2));
                    {`FUNCT7_NORMAL, `FUNCT3_SLTU}: result = $sformatf("sltu %s, %s, %s", 
                        get_register_name(rd), get_register_name(rs1), get_register_name(rs2));
                    {`FUNCT7_NORMAL, `FUNCT3_XOR}: result = $sformatf("xor %s, %s, %s", 
                        get_register_name(rd), get_register_name(rs1), get_register_name(rs2));
                    {`FUNCT7_NORMAL, `FUNCT3_SRL_SRA}: result = $sformatf("srl %s, %s, %s", 
                        get_register_name(rd), get_register_name(rs1), get_register_name(rs2));
                    {`FUNCT7_ALT, `FUNCT3_SRL_SRA}: result = $sformatf("sra %s, %s, %s", 
                        get_register_name(rd), get_register_name(rs1), get_register_name(rs2));
                    {`FUNCT7_NORMAL, `FUNCT3_OR}: result = $sformatf("or %s, %s, %s", 
                        get_register_name(rd), get_register_name(rs1), get_register_name(rs2));
                    {`FUNCT7_NORMAL, `FUNCT3_AND}: result = $sformatf("and %s, %s, %s", 
                        get_register_name(rd), get_register_name(rs1), get_register_name(rs2));
                    default: result = $sformatf("unknown_rtype [0x%08h]", machine_code);
                endcase
            end
            
            `OPCODE_ITYPE: begin
                case(funct3)
                    `FUNCT3_ADD_SUB: result = $sformatf("addi %s, %s, %0d", 
                        get_register_name(rd), get_register_name(rs1), $signed(imm_i));
                    `FUNCT3_SLL: result = $sformatf("slli %s, %s, %0d", 
                        get_register_name(rd), get_register_name(rs1), rs2);
                    `FUNCT3_SLT: result = $sformatf("slti %s, %s, %0d", 
                        get_register_name(rd), get_register_name(rs1), $signed(imm_i));
                    `FUNCT3_SLTU: result = $sformatf("sltiu %s, %s, %0d", 
                        get_register_name(rd), get_register_name(rs1), $signed(imm_i));
                    `FUNCT3_XOR: result = $sformatf("xori %s, %s, %0d", 
                        get_register_name(rd), get_register_name(rs1), $signed(imm_i));
                    `FUNCT3_SRL_SRA: begin
                        if (funct7 == `FUNCT7_NORMAL)
                            result = $sformatf("srli %s, %s, %0d", 
                                get_register_name(rd), get_register_name(rs1), rs2);
                        else
                            result = $sformatf("srai %s, %s, %0d", 
                                get_register_name(rd), get_register_name(rs1), rs2);
                    end
                    `FUNCT3_OR: result = $sformatf("ori %s, %s, %0d", 
                        get_register_name(rd), get_register_name(rs1), $signed(imm_i));
                    `FUNCT3_AND: result = $sformatf("andi %s, %s, %0d", 
                        get_register_name(rd), get_register_name(rs1), $signed(imm_i));
                    default: result = $sformatf("unknown_itype [0x%08h]", machine_code);
                endcase
            end
            
            `OPCODE_LW: result = $sformatf("lw %s, %0d(%s)", 
                get_register_name(rd), $signed(imm_i), get_register_name(rs1));
                
            `OPCODE_SW: result = $sformatf("sw %s, %0d(%s)", 
                get_register_name(rs2), $signed(imm_s), get_register_name(rs1));
                
            `OPCODE_BRANCH: begin
                case(funct3)
                    `FUNCT3_BEQ: result = $sformatf("beq %s, %s, %0d", 
                        get_register_name(rs1), get_register_name(rs2), $signed(imm_b));
                    `FUNCT3_BNE: result = $sformatf("bne %s, %s, %0d", 
                        get_register_name(rs1), get_register_name(rs2), $signed(imm_b));
                    `FUNCT3_BLT: result = $sformatf("blt %s, %s, %0d", 
                        get_register_name(rs1), get_register_name(rs2), $signed(imm_b));
                    `FUNCT3_BGE: result = $sformatf("bge %s, %s, %0d", 
                        get_register_name(rs1), get_register_name(rs2), $signed(imm_b));
                    `FUNCT3_BLTU: result = $sformatf("bltu %s, %s, %0d", 
                        get_register_name(rs1), get_register_name(rs2), $signed(imm_b));
                    `FUNCT3_BGEU: result = $sformatf("bgeu %s, %s, %0d", 
                        get_register_name(rs1), get_register_name(rs2), $signed(imm_b));
                    default: result = $sformatf("unknown_branch [0x%08h]", machine_code);
                endcase
            end
            
            default: result = $sformatf("unknown [0x%08h]", machine_code);
        endcase
        
        return result;
    endfunction

endclass
