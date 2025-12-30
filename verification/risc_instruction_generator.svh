import uvm_pkg::*;
`include "uvm_macros.svh"
`include "risc_defines.svh"

class risc_instruction_generator extends uvm_object;
    `uvm_object_utils(risc_instruction_generator)

    typedef enum {
        // Common instructions
        INSTR_ADD, INSTR_ADDI,
        INSTR_LW, INSTR_SW,
        // Branch instructions
        INSTR_BEQ, INSTR_BNE,
        INSTR_BLT, INSTR_BGE,
        INSTR_BLTU, INSTR_BGEU,
        // Common logical operations
        INSTR_AND, INSTR_ANDI,
        INSTR_OR, INSTR_ORI,
        INSTR_XOR, INSTR_XORI,
        // Less common operations
        INSTR_SUB, INSTR_SLT, INSTR_SLTU, INSTR_SLTI, INSTR_SLTIU,
        INSTR_SLL, INSTR_SLLI, INSTR_SRL, INSTR_SRLI, INSTR_SRA, INSTR_SRAI
    } instr_type_e;

    parameter int REG_INC_PROB = 5;
    parameter int INSTR_DEC_PROB = 3;
    parameter int TOTAL_PROB = 100;
    parameter int NR_REGISTERS = 32;
    parameter int NR_INSTRUCTIONS = 27;

    int register_probability[NR_REGISTERS];
    int instruction_probability[NR_INSTRUCTIONS];
    
    function new(string name = "risc_instruction_generator");
        super.new(name);
        for (int i = 0; i < NR_REGISTERS; i++) begin
            register_probability[i] = TOTAL_PROB / NR_REGISTERS;
        end
        for (int i = 0; i < NR_INSTRUCTIONS; i++) begin
            instruction_probability[i] = TOTAL_PROB / NR_INSTRUCTIONS;
        end
    endfunction

    function int get_register();
        int rand_val, cumulative_prob = 0;
        int reg_decrease;

        rand_val = $urandom_range(1, TOTAL_PROB);

        for (int i = 0; i < NR_REGISTERS; i++) begin
            cumulative_prob += register_probability[i];
            if (rand_val <= cumulative_prob) begin
                register_probability[i] += REG_INC_PROB;
                
                for (int j = 0; j < NR_REGISTERS; j++) begin
                    if (j != i) begin
                        reg_decrease = register_probability[j] * REG_INC_PROB / (NR_REGISTERS * TOTAL_PROB);
                        register_probability[j] = (register_probability[j] > reg_decrease) ? 
                                                  register_probability[j] - reg_decrease : 0;
                    end
                end
                
                return i;
            end
        end
    endfunction

    function instr_type_e get_instruction();
        int rand_val, cumulative_prob = 0;
        int instr_increase;

        rand_val = $urandom_range(1, TOTAL_PROB);

        for (int i = 0; i < NR_INSTRUCTIONS; i++) begin
            cumulative_prob += instruction_probability[i];
            if (rand_val <= cumulative_prob) begin
                instruction_probability[i] += INSTR_DEC_PROB;
                
                for (int j = 0; j < NR_INSTRUCTIONS; j++) begin
                    if (j != i) begin
                        instr_increase = instruction_probability[j] * INSTR_DEC_PROB / (NR_INSTRUCTIONS * TOTAL_PROB);
                        instruction_probability[j] = (instruction_probability[j] > instr_increase) ? 
                                                      instruction_probability[j] - instr_increase : 0;
                    end
                end
                
                return instr_type_e'(i);
            end
        end
    endfunction

    
    function logic [31:0] generate_random_machine_code(int num_instructions);
        instr_type_e instr_type;
        logic [4:0] rs1, rs2, rd;
        logic [11:0] immediate;
        logic [12:0] branch_offset;
        logic [31:0] machine_code;
        
        instr_type = get_instruction();

        rs1 = get_register();
        rs2 = get_register(); 
        rd = get_register();

        if (rd == 0 && (instr_type inside {INSTR_ADD, INSTR_SUB, INSTR_SLL, INSTR_SLT, INSTR_SLTU,
                                            INSTR_XOR, INSTR_SRL, INSTR_SRA, INSTR_OR, INSTR_AND,
                                            INSTR_ADDI, INSTR_SLLI, INSTR_SLTI, INSTR_SLTIU,
                                            INSTR_XORI, INSTR_SRLI, INSTR_SRAI, INSTR_ORI, INSTR_ANDI,
                                            INSTR_LW})) begin
            rd = get_register();
            if (rd == 0) rd = 1;
        end
        
        case(instr_type)
            // R-Type instructions
            INSTR_ADD: begin
                machine_code = {`FUNCT7_NORMAL, rs2, rs1, `FUNCT3_ADD_SUB, rd, `OPCODE_RTYPE};
            end
            INSTR_SUB: begin
                machine_code = {`FUNCT7_ALT, rs2, rs1, `FUNCT3_ADD_SUB, rd, `OPCODE_RTYPE};
            end
            INSTR_SLL: begin
                machine_code = {`FUNCT7_NORMAL, rs2, rs1, `FUNCT3_SLL, rd, `OPCODE_RTYPE};
            end
            INSTR_SLT: begin
                machine_code = {`FUNCT7_NORMAL, rs2, rs1, `FUNCT3_SLT, rd, `OPCODE_RTYPE};
            end
            INSTR_SLTU: begin
                machine_code = {`FUNCT7_NORMAL, rs2, rs1, `FUNCT3_SLTU, rd, `OPCODE_RTYPE};
            end
            INSTR_XOR: begin
                machine_code = {`FUNCT7_NORMAL, rs2, rs1, `FUNCT3_XOR, rd, `OPCODE_RTYPE};
            end
            INSTR_SRL: begin
                machine_code = {`FUNCT7_NORMAL, rs2, rs1, `FUNCT3_SRL_SRA, rd, `OPCODE_RTYPE};
            end
            INSTR_SRA: begin
                machine_code = {`FUNCT7_ALT, rs2, rs1, `FUNCT3_SRL_SRA, rd, `OPCODE_RTYPE};
            end
            INSTR_OR: begin
                machine_code = {`FUNCT7_NORMAL, rs2, rs1, `FUNCT3_OR, rd, `OPCODE_RTYPE};
            end
            INSTR_AND: begin
                machine_code = {`FUNCT7_NORMAL, rs2, rs1, `FUNCT3_AND, rd, `OPCODE_RTYPE};
            end
            
            // I-Type instructions
            INSTR_ADDI: begin
                immediate = $urandom_range(-100, 100);
                machine_code = {immediate, rs1, `FUNCT3_ADD_SUB, rd, `OPCODE_ITYPE};
            end
            INSTR_SLLI: begin
                machine_code = {`FUNCT7_NORMAL, rs2[4:0], rs1, `FUNCT3_SLL, rd, `OPCODE_ITYPE};
            end
            INSTR_SLTI: begin
                immediate = $urandom_range(-100, 100);
                machine_code = {immediate, rs1, `FUNCT3_SLT, rd, `OPCODE_ITYPE};
            end
            INSTR_SLTIU: begin
                immediate = $urandom_range(-100, 100);
                machine_code = {immediate, rs1, `FUNCT3_SLTU, rd, `OPCODE_ITYPE};
            end
            INSTR_XORI: begin
                immediate = $urandom_range(-100, 100);
                machine_code = {immediate, rs1, `FUNCT3_XOR, rd, `OPCODE_ITYPE};
            end
            INSTR_SRLI: begin
                machine_code = {`FUNCT7_NORMAL, rs2[4:0], rs1, `FUNCT3_SRL_SRA, rd, `OPCODE_ITYPE};
            end
            INSTR_SRAI: begin
                machine_code = {`FUNCT7_ALT, rs2[4:0], rs1, `FUNCT3_SRL_SRA, rd, `OPCODE_ITYPE};
            end
            INSTR_ORI: begin
                immediate = $urandom_range(-100, 100);
                machine_code = {immediate, rs1, `FUNCT3_OR, rd, `OPCODE_ITYPE};
            end
            INSTR_ANDI: begin
                immediate = $urandom_range(-100, 100);
                machine_code = {immediate, rs1, `FUNCT3_AND, rd, `OPCODE_ITYPE};
            end
            
            INSTR_LW: begin
                immediate = $urandom_range(0, 255) << 2;
                machine_code = {immediate, rs1, 3'b010, rd, `OPCODE_LW};
            end
            INSTR_SW: begin
                immediate = $urandom_range(0, 255) << 2;
                machine_code = {immediate[11:5], rs2, rs1, 3'b010, immediate[4:0], `OPCODE_SW};
            end
            
            INSTR_BEQ: begin
                branch_offset = $urandom_range(-2, 2) << 2;
                machine_code = {branch_offset[12], branch_offset[10:5], rs2, rs1, `FUNCT3_BEQ, 
                               branch_offset[4:1], branch_offset[11], `OPCODE_BRANCH};
            end
            INSTR_BNE: begin
                branch_offset = $urandom_range(-2, 2) << 2;
                machine_code = {branch_offset[12], branch_offset[10:5], rs2, rs1, `FUNCT3_BNE, 
                               branch_offset[4:1], branch_offset[11], `OPCODE_BRANCH};
            end
            INSTR_BLT: begin
                branch_offset = $urandom_range(-2, 2) << 2;
                machine_code = {branch_offset[12], branch_offset[10:5], rs2, rs1, `FUNCT3_BLT, 
                               branch_offset[4:1], branch_offset[11], `OPCODE_BRANCH};
            end
            INSTR_BGE: begin
                branch_offset = $urandom_range(-2, 2) << 2;
                machine_code = {branch_offset[12], branch_offset[10:5], rs2, rs1, `FUNCT3_BGE, 
                               branch_offset[4:1], branch_offset[11], `OPCODE_BRANCH};
            end
            INSTR_BLTU: begin
                branch_offset = $urandom_range(-2, 2) << 2;
                machine_code = {branch_offset[12], branch_offset[10:5], rs2, rs1, `FUNCT3_BLTU, 
                               branch_offset[4:1], branch_offset[11], `OPCODE_BRANCH};
            end
            INSTR_BGEU: begin
                branch_offset = $urandom_range(-2, 2) << 2;
                machine_code = {branch_offset[12], branch_offset[10:5], rs2, rs1, `FUNCT3_BGEU, 
                               branch_offset[4:1], branch_offset[11], `OPCODE_BRANCH};
            end
            default: machine_code = 32'h00000013; // NOP
        endcase
        
        return machine_code;
    endfunction

endclass
