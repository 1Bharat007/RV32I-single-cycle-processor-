# RV32I Single-Cycle Processor

A clean, readable Verilog implementation of the **RISC-V RV32I** base integer ISA as a single-cycle processor — built for the Computer Organisation & Architecture (COA) assignment.

---

## Module Descriptions

| File | Module | Description |
|------|--------|-------------|
| `pc.v` | `pc` | 32-bit program counter register. Resets to 0x00000000. |
| `instruction_memory.v` | `instruction_memory` | 256-word word-addressed ROM. |
| `control_unit.v` | `control_unit` | Decodes opcode to all datapath control signals. |
| `register_file.v` | `register_file` | 32x32 register file. x0 hardwired to 0. |
| `immediate_generator.v` | `immediate_generator` | Sign-extends immediates for I/S/B/U/J types. |
| `alu_control.v` | `alu_control` | Maps alu_op + funct3 + funct7 to 4-bit ALU op. |
| `alu.v` | `alu` | All RV32I arithmetic/logic operations + zero flag. |
| `muxes.v` | `muxes` | ALU-A, ALU-B, and writeback multiplexers. |
| `data_memory.v` | `data_memory` | 1024-byte byte-addressable little-endian RAM. |
| `branch_unit.v` | `branch_unit` | Evaluates BEQ/BNE/BLT/BGE/BLTU/BGEU conditions. |
| `next_pc.v` | `next_pc` | Selects PC+4 / branch target / JAL / JALR next PC. |
| `riscv_cpu.v` | `riscv_cpu` | **Top-level**: wires all modules together. |

---

## Supported Instructions

### R-type
ADD SUB SLL SLT SLTU XOR SRL SRA OR AND

### I-type Arithmetic
ADDI SLTI SLTIU XORI ORI ANDI SLLI SRLI SRAI

### Loads
LB LH LW LBU LHU

### Stores
SB SH SW

### Branches
BEQ BNE BLT BGE BLTU BGEU

### Jumps
JAL JALR

### Upper Immediate
LUI AUIPC

---

## How to Simulate (Icarus Verilog)

```bash
iverilog -o riscv_cpu.vvp riscv_cpu.v pc.v instruction_memory.v \
    control_unit.v register_file.v immediate_generator.v \
    alu_control.v alu.v muxes.v data_memory.v branch_unit.v next_pc.v
vvp riscv_cpu.vvp
```

---

## Project Info

- **Subject**: Computer Organisation & Architecture (COA)
- **ISA**: RISC-V RV32I Base Integer
- **Design style**: Single-cycle (no pipeline, no cache)
- **Language**: Verilog HDL
