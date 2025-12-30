# Proiect RISC-V - Procesor Pipeline

## Descriere Generala

Acest proiect implementeaza un procesor RISC-V-32 cu arhitectura pipeline in Verilog, conform cartii **"Computer Organization and Design: The Hardware/Software Interface"** de David A. Patterson si John L. Hennessy (RISC-V Edition).

Procesorul este conceput cu pipeline pe 5 etape pentru performanta imbunatatita si include un mediu complet de verificare folosind **UVM (Universal Verification Methodology)**.

## Structura Proiectului

```
RISC/
├── design/
│   ├── RISC_V.v                # Modul principal RISC-V pipeline
│   ├── IF.v                    # Etapa Instruction Fetch
│   ├── ID.v                    # Etapa Instruction Decode
│   ├── EX.v                    # Etapa Execute
│   ├── MEM.v                   # Etapa Memory Access
│   ├── WB.v                    # Etapa Write Back
│   ├── REG_IF_ID.v             # Registru pipeline IF/ID
│   ├── REG_ID_EX.v             # Registru pipeline ID/EX
│   ├── REG_EX_MEM.v            # Registru pipeline EX/MEM
│   ├── REG_MEM_WB.v            # Registru pipeline MEM/WB
│   ├── PC.v                    # Program Counter
│   ├── instruction_memory.v    # Memoria de instructiuni
│   ├── data_memory.v           # Memoria de date
│   ├── registers.v             # Fisierul de registre
│   ├── ALU.v                   # Unitatea Aritmetico-Logica
│   ├── ALUcontrol.v            # Control pentru ALU
│   ├── control_path.v          # Unitatea de control
│   ├── branch_control.v        # Control pentru branch-uri
│   ├── forwarding.v            # Unitate de forwarding
│   ├── hazard_detection.v      # Detectare hazard-uri
│   ├── imm_gen.v               # Generator de valori imediate
│   ├── mux2_1.v                # Multiplexor 2:1
│   ├── mux3_1.v                # Multiplexor 3:1
│   ├── mux_control.v           # Multiplexor pentru semnale control
│   └── adder.v                 # Sumator
└── verification/               # Mediul de testare UVM
    ├── risc_pkg.sv             # Package UVM principal
    ├── top_risc.sv             # Testbench top-level
    ├── risc_interface.sv       # Interfața SystemVerilog
    ├── risc_agent.svh          # Agent UVM
    ├── risc_driver.svh         # Driver pentru stimuli
    ├── risc_monitor.svh        # Monitor pentru colectare
    ├── risc_scoreboard.svh     # Verificare functionala
    ├── risc_coverage.svh       # Colectare acoperire
    ├── risc_golden_model.svh   # Model de referinta
    ├── risc_instruction_generator.svh  # Generator de instructiuni
    ├── risc_parser.svh         # Parser pentru decodare
    ├── risc_sequence_random.svh # Secventa de test random
    ├── risc_sequencer.svh      # Sequencer UVM
    ├── risc_test_random.svh    # Test aleatoriu
    ├── risc_defines.svh        # Definitii si constante
    ├── risc_instruction_transaction.svh  # Tranzactie instructiune
    ├── risc_program_transaction.svh      # Tranzactie program
    ├── risc_memory_transaction.svh       # Tranzactie memorie
    └── risc_env.svh            # Environment UVM
```

## Arhitectura RISC-V Pipeline

### Modulul Principal: `RISC_V.v`

Implementeaza pipeline complet pe 5 etape conform arhitecturii RISC-V clasice:

### Etapele Pipeline-ului:

#### 1. **IF (Instruction Fetch)**

**Modul**: `IF.v`

Gestioneaza citirea instructiunilor din memorie si actualizarea Program Counter-ului.

**Functionalitati:**
- **Program Counter (PC)**: Mentine adresa instructiunii curente
- **Instruction Memory**: Citeste instructiunea de la adresa PC[11:2]
- **Adder**: Calculeaza PC+4 pentru instructiunea urmatoare
- **Branch MUX**: Selectează între PC+4 și adresa de salt (PC_Branch)

**Semnale de Control:**
- `PCSrc`: Selecteaza sursa pentru noul PC (0 = PC+4, 1 = PC_Branch)
- `PC_write`: Activeaza scrierea in PC (pentru gestionarea hazard-urilor)

#### 2. **ID (Instruction Decode)**

**Modul**: `ID.v`

Decodeaza instructiunea si pregateste operanzii pentru executie.

**Functionalitati:**
- **Extragerea campurilor instructiunii**:
  - `OPCODE`: Codul operatiei [6:0]
  - `RD`: Registrul destinatie [11:7]
  - `FUNCT3`: Functia tertiara [14:12]
  - `RS1`: Registrul sursa 1 [19:15]
  - `RS2`: Registrul sursa 2 [24:20]
  - `FUNCT7`: Functia secundara [31:25]

- **Register File**: Citeste valorile din registrele RS1 si RS2
- **Control Path**: Genereaza semnalele de control pentru datapath
- **Immediate Generator**: Extinde valorile imediate pentru diferite formate
- **Hazard Detection Unit**: Detecteaza hazard-uri load-use

**Iesiri:**
- `REG_DATA1_ID`, `REG_DATA2_ID`: Datele citite din registre
- `IMM_ID`: Valoarea imediata extinsa cu semn
- Semnale de control: `RegWrite`, `MemtoReg`, `MemRead`, `MemWrite`, `Branch`, `ALUSrc`, `ALUop`

#### 3. **EX (Execute)**

**Modul**: `EX.v`

Executa operatiile aritmetice si logice, calculeaza adrese pentru branch-uri.

**Functionalitati:**
- **ALU**: Executa operatii aritmetice si logice
- **ALU Control**: Genereaza semnalul de control specific pentru ALU bazat pe funct3, funct7 si ALUop
- **Branch Adder**: Calculeaza adresa tinta pentru branch (PC + Immediate)
- **Forwarding Unit**: Detecteaza si rezolva hazard-urile de date
- **Multiplexoare**: Selecteaza sursa corecta pentru operanzi (forwarding sau valoare normala)

**Operatii ALU:**
- `AND`, `OR`, `XOR`: Operatii logice
- `ADD`, `SUB`: Operatii aritmetice
- `SLL`, `SRL`, `SRA`: Operatii de shift
- `SLT`, `SLTU`: Comparatii signed/unsigned

**Forwarding:**
- Forward de la EX/MEM (rezultat ALU din ciclul anterior)
- Forward de la MEM/WB (rezultat final din WB)
- Selectare automata bazata pe dependente

#### 4. **MEM (Memory Access)**

**Modul**: `MEM.v`

Acceseaza memoria de date si rezolva branch-urile.

**Functionalitati:**
- **Data Memory**: Operatii de load/store
  - Load Word (LW): Citeste 32-bit din memorie
  - Store Word (SW): Scrie 32-bit in memorie
- **Branch Control**: Determina daca branch-ul se ia sau nu
  - `BEQ`: Branch if Equal
  - `BNE`: Branch if Not Equal
  - `BLT`: Branch if Less Than (signed)
  - `BGE`: Branch if Greater or Equal (signed)
  - `BLTU`: Branch if Less Than (unsigned)
  - `BGEU`: Branch if Greater or Equal (unsigned)

**Iesiri:**
- `PCSrc`: Semnalul pentru actualizarea PC-ului
- `DATA_MEMORY`: Date citite din memorie (pentru LW)

#### 5. **WB (Write Back)**

**Modul**: `WB.v`

Scrie rezultatul inapoi in registre.

**Functionalitati:**
- **MUX MemtoReg**: Selecteaza intre rezultatul ALU si datele din memorie
- Scriere in Register File prin semnalul `RegWrite`

### Registre Pipeline:

- **REG_IF_ID**: Stocheaza PC si instructiunea intre IF si ID
- **REG_ID_EX**: Stocheaza date registre, immediate, semnale control intre ID si EX
- **REG_EX_MEM**: Stocheaza rezultat ALU, date pentru store, semnale control intre EX si MEM
- **REG_MEM_WB**: Stocheaza rezultat final si date memorie intre MEM si WB

### Componente Auxiliare

#### Register File (`registers.v`)
- 32 de registre generale de 32-bit (x0-x31)
- Registrul x0 este hardwired la valoarea 0
- Doua porturi de citire (RS1, RS2)
- Un port de scriere (RD)
- Scriere sincrona, citire asincrona cu internal forwarding

#### Immediate Generator (`imm_gen.v`)
Genereaza valorile imediate extinse cu semn pentru:
- **I-Type**: Load, operatii ALU cu immediate (12-bit)
- **S-Type**: Store (12-bit)
- **B-Type**: Branch (13-bit, LSB implicit 0)

#### Control Path (`control_path.v`)
Genereaza semnalele de control bazate pe OPCODE:
- `ALUSrc`: Selecteaza sursa pentru ALU (registru sau immediate)
- `MemtoReg`: Selecteaza sursa pentru write-back (ALU sau memorie)
- `RegWrite`: Activeaza scrierea in registre
- `MemRead`, `MemWrite`: Control pentru memoria de date
- `Branch`: Indica instructiune de branch
- `ALUop`: Tip de operatie pentru ALU

#### ALU Control (`ALUcontrol.v`)
Genereaza semnalul de control de 4-bit pentru ALU bazat pe:
- `ALUop[1:0]`: Tipul operatiei (R-type, I-type, Branch, Load/Store)
- `funct3[2:0]`: Camp functie din instructiune
- `funct7[6:0]`: Camp functie extinsa (pentru diferentierea ADD/SUB, SRL/SRA)

## Instructiuni RISC-V Suportate

### R-Type (Registru-Registru):
- **ADD** rd, rs1, rs2: Adunare
- **SUB** rd, rs1, rs2: Scadere
- **AND** rd, rs1, rs2: Operatie AND pe biti
- **OR** rd, rs1, rs2: Operatie OR pe biti
- **XOR** rd, rs1, rs2: Operatie XOR pe biti
- **SLL** rd, rs1, rs2: Shift logic left
- **SRL** rd, rs1, rs2: Shift logic right
- **SRA** rd, rs1, rs2: Shift aritmetic right
- **SLT** rd, rs1, rs2: Set less than (signed)
- **SLTU** rd, rs1, rs2: Set less than (unsigned)

### I-Type (Immediate):

**Operatii ALU:**
- **ADDI** rt, rs, immediate: Adunare cu valoare imediata
- **ANDI** rt, rs, immediate: AND cu valoare imediata
- **ORI** rt, rs, immediate: OR cu valoare imediata
- **XORI** rt, rs, immediate: XOR cu valoare imediata
- **SLTI** rt, rs, immediate: Set less than immediate (signed)
- **SLTIU** rt, rs, immediate: Set less than immediate (unsigned)

**Shift:**
- **SLLI** rd, rs, shamt: Shift logic left immediate
- **SRLI** rd, rs, shamt: Shift logic right immediate
- **SRAI** rd, rs, shamt: Shift aritmetic right immediate

**Load:**
- **LW** rt, offset(rs): Incarcare word din memorie

### S-Type (Store):
- **SW** rt, offset(rs): Salvare word in memorie

### B-Type (Branch):
- **BEQ** rs1, rs2, offset: Branch if equal
- **BNE** rs1, rs2, offset: Branch if not equal
- **BLT** rs1, rs2, offset: Branch if less than (signed)
- **BGE** rs1, rs2, offset: Branch if greater or equal (signed)
- **BLTU** rs1, rs2, offset: Branch if less than (unsigned)
- **BGEU** rs1, rs2, offset: Branch if greater or equal (unsigned)

## Gestionarea Hazard-urilor

### 1. Data Hazards (Dependente de Date):

**Forwarding Unit (`forwarding.v`):**
- Detecteaza dependentele RAW (Read After Write)
- Redirectioneaza datele de la EX/MEM sau MEM/WB direct la intrarile ALU
- Evita stall-urile pentru majoritatea cazurilor

**Cazuri de Forwarding:**
```
EX Hazard:  EX/MEM.RegWrite && (EX/MEM.RD == ID/EX.RS1 sau RS2)
           → Forward de la ALU_OUT_MEM

MEM Hazard: MEM/WB.RegWrite && (MEM/WB.RD == ID/EX.RS1 sau RS2)
           → Forward de la ALU_DATA_WB
```

**Hazard Detection (`hazard_detection.v`):**
- Detecteaza hazard-urile load-use (cand instructiunea urmatoare foloseste rezultatul unui load)
- Insereaza bubble (NOP) prin freeze IF/ID si flush ID/EX
- Semnale: `PC_write = 0`, `IF_ID_write = 0`, `Control_sel = 0`

### 2. Control Hazards (Branch):

**Branch Control (`branch_control.v`):**
- Rezolva branch-urile in etapa MEM
- Calculeaza PCSrc bazat pe:
  - Zero flag din ALU
  - Funct3 (tipul de branch)
  - Semnalul Branch din control

**Penalizare:**
- 3 cicluri la branch taken (flush pipeline IF/ID/EX)

## Mediul de Verificare UVM

### Structura Testbench-ului:

#### Componente UVM:

**`risc_agent.svh`**: Agent UVM pentru controlul testului
- Contine driver, monitor si sequencer
- Gestioneaza comunicarea intre componente

**`risc_driver.svh`**: Driver pentru stimuli
- Primeste secvente de instructiuni
- Genereaza fisierul `instructions.mem`
- Controleaza semnalele de reset
- Monitorizeaza executia programului

**`risc_monitor.svh`**: Monitor pentru colectarea raspunsurilor
- Monitorizeaza instructiunile executate
- Colecteaza starea memoriei la final
- Decodeaza si afiseaza instructiunile in format assembly
- Trimite tranzactii catre coverage si scoreboard

**`risc_scoreboard.svh`**: Verificarea corectitudinii functionale
- Compara memoria DUT cu modelul golden
- Raporteaza mismatch-uri
- Valideaza executia corecta a programelor

**`risc_coverage.svh`**: Colectarea acoperirii functionale
- **Instruction Type Coverage**: Toate tipurile de instructiuni (R, I, S, B)
- **Register Usage Coverage**: Utilizarea tuturor registrelor
- **R-Type Coverage**: Toate operatiile R-type (ADD, SUB, AND, etc.)
- **I-Type Coverage**: Toate operatiile I-type (ADDI, ORI, etc.)
- **Branch Coverage**: Toate tipurile de branch și taken/not taken

**`risc_env.svh`**: Environment UVM
- Integreaza agent, coverage si scoreboard
- Gestioneaza conexiunile intre componente

#### Modele de Referinta:

**`risc_golden_model.svh`**: Model software de referinta pentru RISC-V
- Executa instructiunile in software
- Mentine registre si memorie de referinta
- Permite comparatie cu DUT

**`risc_instruction_generator.svh`**: Generator de instructiuni aleatorii
- Genereaza instructiuni bazate pe probabilitati adaptative
- Registrele folosite frecvent primesc probabilitate mai mare
- Instructiunile executate des sunt generate mai mult
- Asigura teste diverse si realiste
- **Branch offset alignment**: Genereaza offset-uri word-aligned (multipli de 4) prin `$urandom_range(-2, 2) << 2`

**`risc_parser.svh`**: Parser pentru decodare
- Decodeaza machine code in assembly
- Afiseaza nume ABI pentru registre (x0/zero, x1/ra, etc.)
- Formatare human-readable pentru debugging

#### Tranzactii:

**`risc_instruction_transaction.svh`**: Tranzactie pentru instructiune individuala
- Contine instructiunea si flag-ul pc_src

**`risc_program_transaction.svh`**: Tranzactie pentru program complet
- Array de instructiuni pentru executie

**`risc_memory_transaction.svh`**: Tranzactie pentru starea memoriei
- Snapshot complet al memoriei de date

#### Tipuri de Teste:

**1. Test Random (`risc_test_random.svh`):**
- Genereaza 20 de programe aleatorii
- Fiecare program are intre 8-15 instructiuni
- Verifica functionalitatea generala
- Testeaza corner cases prin randomizare
- Acoperire functionala completa
