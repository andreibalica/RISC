import uvm_pkg::*;
`include "uvm_macros.svh"
`include "risc_defines.svh"

class risc_golden_model extends uvm_object;
    `uvm_object_utils(risc_golden_model)

    logic [31:0] registers [0:31];
    logic [31:0] memory [0:1023];

    int max_instructions_per_program = 50;

    function new(string name = "risc_golden_model");
        super.new(name);
    endfunction

    function void execute_from_file(string filename);
        logic [31:0] rom [0:1023];
        int pc = 0;
        int instructions_executed = 0;
        for (int i = 0; i < 32; i++) registers[i] = 32'h0;
        for (int i = 0; i < 1024; i++) memory[i] = 32'h0;
        
        $readmemh(filename, rom);

        while (!($isunknown(rom[pc]) || instructions_executed >= max_instructions_per_program || pc < 0 || pc >= 1024)) begin
            execute_machine_instruction(rom[pc], pc);
            instructions_executed++;
        end
        
    endfunction

    function void execute_machine_instruction(logic [31:0] instr, ref int pc);
        logic [6:0] opcode = instr[6:0];
        logic [4:0] rd = instr[11:7];
        logic [2:0] funct3 = instr[14:12];
        logic [4:0] rs1 = instr[19:15];
        logic [4:0] rs2 = instr[24:20];
        logic [6:0] funct7 = instr[31:25];
        logic [11:0] imm_i = instr[31:20];
        logic [11:0] imm_s = {instr[31:25], instr[11:7]};
        logic [12:0] imm_b = {instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        int offset, target_addr;
        bit branch_taken;
        
        case(opcode)
            `OPCODE_NOP: begin
                // No operation
            end
            
            `OPCODE_RTYPE: begin
                case({funct7, funct3})
                    {`FUNCT7_NORMAL, `FUNCT3_ADD_SUB}: if (rd != 0) registers[rd] = registers[rs1] + registers[rs2];
                    {`FUNCT7_ALT, `FUNCT3_ADD_SUB}: if (rd != 0) registers[rd] = registers[rs1] - registers[rs2];
                    {`FUNCT7_NORMAL, `FUNCT3_SLL}: if (rd != 0) registers[rd] = registers[rs1] << registers[rs2][4:0];
                    {`FUNCT7_NORMAL, `FUNCT3_SLT}: if (rd != 0) registers[rd] = ($signed(registers[rs1]) < $signed(registers[rs2])) ? 1 : 0;
                    {`FUNCT7_NORMAL, `FUNCT3_SLTU}: if (rd != 0) registers[rd] = (registers[rs1] < registers[rs2]) ? 1 : 0;
                    {`FUNCT7_NORMAL, `FUNCT3_XOR}: if (rd != 0) registers[rd] = registers[rs1] ^ registers[rs2];
                    {`FUNCT7_NORMAL, `FUNCT3_SRL_SRA}: if (rd != 0) registers[rd] = registers[rs1] >> registers[rs2][4:0];
                    {`FUNCT7_ALT, `FUNCT3_SRL_SRA}: if (rd != 0) registers[rd] = $signed(registers[rs1]) >>> registers[rs2][4:0];
                    {`FUNCT7_NORMAL, `FUNCT3_OR}: if (rd != 0) registers[rd] = registers[rs1] | registers[rs2];
                    {`FUNCT7_NORMAL, `FUNCT3_AND}: if (rd != 0) registers[rd] = registers[rs1] & registers[rs2];
                endcase
            end
            
            `OPCODE_ITYPE: begin
                case(funct3)
                    `FUNCT3_ADD_SUB: if (rd != 0) registers[rd] = registers[rs1] + $signed(imm_i);
                    `FUNCT3_SLL: if (rd != 0) registers[rd] = registers[rs1] << rs2;
                    `FUNCT3_SLT: if (rd != 0) registers[rd] = ($signed(registers[rs1]) < $signed(imm_i)) ? 1 : 0;
                    `FUNCT3_SLTU: if (rd != 0) registers[rd] = (registers[rs1] < imm_i) ? 1 : 0;
                    `FUNCT3_XOR: if (rd != 0) registers[rd] = registers[rs1] ^ $signed(imm_i);
                    `FUNCT3_SRL_SRA: begin
                        if (funct7 == `FUNCT7_NORMAL)
                            if (rd != 0) registers[rd] = registers[rs1] >> rs2;
                        else
                            if (rd != 0) registers[rd] = $signed(registers[rs1]) >>> rs2;
                    end
                    `FUNCT3_OR: if (rd != 0) registers[rd] = registers[rs1] | $signed(imm_i);
                    `FUNCT3_AND: if (rd != 0) registers[rd] = registers[rs1] & $signed(imm_i);
                endcase
            end
            
            `OPCODE_LW: begin
                offset = registers[rs1] + $signed(imm_i);
                if (offset >= 0 && offset < 4096) begin
                    if (rd != 0) registers[rd] = memory[offset >> 2];
                end
            end
            
            `OPCODE_SW: begin
                offset = registers[rs1] + $signed(imm_s);
                if (offset >= 0 && offset < 4096) begin
                    memory[offset >> 2] = registers[rs2];
                end
            end
            
            `OPCODE_BRANCH: begin
                branch_taken = 0;
                case(funct3)
                    `FUNCT3_BEQ: branch_taken = (registers[rs1] == registers[rs2]);
                    `FUNCT3_BNE: branch_taken = (registers[rs1] != registers[rs2]);
                    `FUNCT3_BLT: branch_taken = ($signed(registers[rs1]) < $signed(registers[rs2]));
                    `FUNCT3_BGE: branch_taken = ($signed(registers[rs1]) >= $signed(registers[rs2]));
                    `FUNCT3_BLTU: branch_taken = (registers[rs1] < registers[rs2]);
                    `FUNCT3_BGEU: branch_taken = (registers[rs1] >= registers[rs2]);
                endcase
                
                if (branch_taken) begin
                    target_addr = pc + $signed(imm_b) / 4;
                    pc = target_addr;
                    return;
                end
            end
        endcase
        pc++;
    endfunction

endclass
