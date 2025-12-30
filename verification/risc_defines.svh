`ifndef RISC_DEFINES_SVH
`define RISC_DEFINES_SVH

// --- Opcodes for RISC-V Instructions ---
`define OPCODE_NOP    7'b0000000
`define OPCODE_LW     7'b0000011
`define OPCODE_SW     7'b0100011
`define OPCODE_RTYPE  7'b0110011
`define OPCODE_ITYPE  7'b0010011
`define OPCODE_BRANCH 7'b1100011

// --- Function3 codes for R-Type and I-Type Instructions ---
`define FUNCT3_ADD_SUB 3'b000  // ADD/SUB/ADDI
`define FUNCT3_SLL     3'b001  // SLL/SLLI
`define FUNCT3_SLT     3'b010  // SLT/SLTI
`define FUNCT3_SLTU    3'b011  // SLTU/SLTIU
`define FUNCT3_XOR     3'b100  // XOR/XORI
`define FUNCT3_SRL_SRA 3'b101  // SRL/SRLI/SRA/SRAI
`define FUNCT3_OR      3'b110  // OR/ORI
`define FUNCT3_AND     3'b111  // AND/ANDI

// --- Function3 codes for Branch Instructions ---
`define FUNCT3_BEQ     3'b000
`define FUNCT3_BNE     3'b001
`define FUNCT3_BLT     3'b100
`define FUNCT3_BGE     3'b101
`define FUNCT3_BLTU    3'b110
`define FUNCT3_BGEU    3'b111

// --- Function7 codes for R-Type Instructions ---
`define FUNCT7_NORMAL  7'b0000000  // ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND
`define FUNCT7_ALT     7'b0100000  // SUB, SRA

// --- ALU Control codes (4-bit signal) ---
`define ALU_CTRL_AND   4'b0000
`define ALU_CTRL_OR    4'b0001
`define ALU_CTRL_ADD   4'b0010
`define ALU_CTRL_XOR   4'b0011
`define ALU_CTRL_SLL   4'b0100
`define ALU_CTRL_SRL   4'b0101
`define ALU_CTRL_SUB   4'b0110
`define ALU_CTRL_SLTU  4'b0111
`define ALU_CTRL_SLT   4'b1000
`define ALU_CTRL_SRA   4'b1001

// --- ALUOp definitions (2-bit signal) ---
`define ALU_OP_LW_SW   2'b00
`define ALU_OP_BRANCH  2'b01
`define ALU_OP_RTYPE   2'b10
`define ALU_OP_ITYPE   2'b11

`endif // RISC_DEFINES_SVH
