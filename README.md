# Proiect RISC-V - Procesor Pipeline (In Dezvoltare)

## Descriere Generala

Acest proiect implementeaza un procesor RISC-V cu arhitectura pipeline in Verilog, bazat pe specificatiile RISC-V ISA. Procesorul este conceput cu pipeline pe 5 etape pentru performanta imbunatatita, similar arhitecturii clasice prezentate in **"Computer Organization and Design: The Hardware/Software Interface"** de David A. Patterson si John L. Hennessy.

**Status actual**: Implementate etapele **IF (Instruction Fetch)** si **ID (Instruction Decode)** ale pipeline-ului.

## Structura Proiectului

```
RISC/
├── design/
│   ├── RISC_V_IF_ID.v        # Modul principal (IF + ID)
│   ├── IF.v                   # Etapa Instruction Fetch
│   ├── ID.v                   # Etapa Instruction Decode
│   ├── PC.v                   # Program Counter
│   ├── REG_IF_ID.v            # Registru pipeline IF/ID
│   ├── instruction_memory.v   # Memoria de instructiuni
│   ├── registers.v            # Fisierul de registre
│   ├── imm_gen.v              # Generator de valori imediate
│   ├── mux2_1.v               # Multiplexor 2:1
│   └── adder.v                # Sumator
└── verification/
    ├── test_riscv_stud.v      # Testbench principal
    ├── tb_reg_file.v          # Test pentru fisierul de registre
    └── code.mem               # Memoria cu instructiuni de test
```

## Arhitectura Pipeline RISC-V

### Etapele Pipeline-ului (Plan Complet):

1. ✅ **IF (Instruction Fetch)** - *Implementat*
2. ✅ **ID (Instruction Decode)** - *Implementat*
3. ⏳ **EX (Execute)** - *In dezvoltare*
4. ⏳ **MEM (Memory Access)** - *In dezvoltare*
5. ⏳ **WB (Write Back)** - *In dezvoltare*

## Componente Implementate

### 1. Etapa IF (Instruction Fetch)

**Modul**: `IF.v`

Gestioneaza citirea instructiunilor din memorie si actualizarea Program Counter-ului.

#### Functionalitati:
- **Program Counter (PC)**: Mentine adresa instructiunii curente
- **Instruction Memory**: Citeste instructiunea de la adresa PC
- **Adder**: Calculeaza PC+4 pentru instructiunea urmatoare
- **Branch MUX**: Selecteaza intre PC+4 si adresa de salt (PC_Branch)

#### Semnale de Control:
- `PCSrc`: Selecteaza sursa pentru noul PC (0 = PC+4, 1 = PC_Branch)
- `PC_write`: Activeaza scrierea in PC (pentru gestionarea hazard-urilor)
- `PC_Branch`: Adresa tinta pentru instructiunile de salt

### 2. Registrul Pipeline IF/ID

**Modul**: `REG_IF_ID.v`

Registru pipeline care separa etapele IF si ID, stocheaza:
- Adresa PC a instructiunii curente
- Instructiunea citita din memorie

#### Semnale de Control:
- `IF_ID_write`: Activeaza scrierea in registrul pipeline (pentru inserarea de stall-uri)

### 3. Etapa ID (Instruction Decode)

**Modul**: `ID.v`

Decodeaza instructiunea si pregateste operanzii pentru executie.

#### Functionalitati:
- **Extragerea campurilor instructiunii**:
  - `OPCODE`: Codul operatiei [6:0]
  - `RD`: Registrul destinatie [11:7]
  - `FUNCT3`: Functia tertiara [14:12]
  - `RS1`: Registrul sursa 1 [19:15]
  - `RS2`: Registrul sursa 2 [24:20]
  - `FUNCT7`: Functia secundara [31:25]

- **Register File**: Citeste valorile din registrele RS1 si RS2
- **Immediate Generator**: Extinde si genereaza valorile imediate pentru diferite formate de instructiuni (I-Type, S-Type, B-Type, U-Type, J-Type)
- **Write Back**: Suport pentru scrierea rezultatului in registrul destinatie

#### Iesiri:
- `REG_DATA1_ID`, `REG_DATA2_ID`: Datele citite din registre
- `IMM_ID`: Valoarea imediata extinsa cu semn
- Campurile instructiunii decodate (OPCODE, FUNCT3, FUNCT7, RD, RS1, RS2)

## Componente Auxiliare

### Register File (`registers.v`)
- 32 de registre generale de 32-bit (x0-x31)
- Registrul x0 este hardwired la valoarea 0
- Doua porturi de citire (RS1, RS2)
- Un port de scriere (RD)
- Scriere sincrona, citire asincrona

### Immediate Generator (`imm_gen.v`)
Genereaza valorile imediate extinse cu semn pentru:
- **I-Type**: Load, operatii ALU cu immediate, JALR
- **S-Type**: Store
- **B-Type**: Branch
- **U-Type**: LUI, AUIPC
- **J-Type**: JAL

### Program Counter (`PC.v`)
- Registru de 32-bit
- Suport pentru reset
- Semnale de control pentru stall si branch

## Instructiuni RISC-V (Planificate)

### R-Type (Registru-Registru):
- `ADD`, `SUB`, `AND`, `OR`, `XOR`, `SLL`, `SRL`, `SRA`, `SLT`, `SLTU`

### I-Type (Immediate):
- **Operatii ALU**: `ADDI`, `ANDI`, `ORI`, `XORI`, `SLTI`, `SLTIU`
- **Shift**: `SLLI`, `SRLI`, `SRAI`
- **Load**: `LW`, `LH`, `LB`, `LHU`, `LBU`
- **Jump**: `JALR`

### S-Type (Store):
- `SW`, `SH`, `SB`

### B-Type (Branch):
- `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU`

### U-Type (Upper Immediate):
- `LUI`, `AUIPC`

### J-Type (Jump):
- `JAL`

## Etape Urmatoare

### EX (Execute) - In dezvoltare
- Implementarea ALU cu operatii aritmetice si logice
- Calcularea adreselor pentru branch-uri
- Unitate de forwarding pentru rezolvarea hazard-urilor de date

### MEM (Memory Access) - In dezvoltare
- Memoria de date
- Operatii de load/store
- Rezolvarea branch-urilor

### WB (Write Back) - In dezvoltare
- Multiplexor pentru selectarea datei de scris (ALU sau Memory)
- Inchiderea buclei de write-back catre registre

### Gestionarea Hazard-urilor - Planificat
- **Data Hazards**: Forwarding unit si hazard detection
- **Control Hazards**: Branch prediction si flush pipeline
- **Structural Hazards**: Gestionarea conflictelor de resurse

## Mediu de Verificare

### Testbench-uri Disponibile:
- **`test_riscv_stud.v`**: Testbench principal pentru procesorul IF/ID
- **`tb_reg_file.v`**: Test dedicat pentru fisierul de registre

### Fisiere de Test:
- **`code.mem`**: Memoria cu instructiuni de test pentru simulare
