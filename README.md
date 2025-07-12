# Verilog-Sync-RAM

This project implements a **synchronous single-port RAM** in Verilog HDL with read and write access, controlled by chip select, reset, and enable signals. The memory supports configurable depth and width via parameters and is verified using a robust testbench on EDA Playground or any Verilog simulator.

---

## 📌 Key Features

- Synchronous read/write memory
- Parameterized `WIDTH` and `DEPTH`
- Controlled by:
  - `CS` (Chip Select)
  - `RE` (Read Enable)
  - `WE` (Write Enable)
  - `RESET` (Active High)
- Supports simultaneous read/write testing
- Verilog testbench with multiple scenarios

---

## 📘 Design Overview

This RAM module is designed for use in custom processors, controllers, or test benches. All operations are clock-synchronized. A single port is used for both read and write, with independent read and write addresses.

### 🧠 Core Concepts

- **Read and Write Behavior**: Controlled via `RE`, `WE`, and `CS`. No read or write occurs without chip select.
- **Reset Logic**: On assertion of `RESET` and `CS`, all memory locations and output are cleared.
- **Output Register**: `RDATA` holds the data read from memory.

---

## 📂 File Structure

```text
├── memory.v        # Main Verilog RAM module
├── tb.v            # Testbench with multiple scenario coverage
