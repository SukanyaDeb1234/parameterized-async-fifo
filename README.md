# Parameterized Asynchronous FIFO with Gray-Code CDC and Self-Checking Verification

## Overview

This project implements a **parameterized asynchronous FIFO** in Verilog for reliable data transfer between two independent clock domains.

The design uses:

* Separate read and write clocks
* Binary read/write pointers
* Binary-to-Gray code conversion
* Two-stage flip-flop synchronizers for clock-domain crossing (CDC)
* Full and empty flag generation
* Dual-clock FIFO memory
* Self-checking functional verification
* Corner-case verification
* Randomized verification
* Xilinx Vivado synthesis, implementation, and timing analysis

The demonstrated configuration is:

```text
FIFO Depth  : 8
Data Width  : 16 bits
Write Clock : 60 ns period
Read Clock  : 50 ns period
```

---

## Architecture

The asynchronous FIFO is divided into two independent clock domains:

```text
                 ASYNCHRONOUS FIFO

        WRITE CLOCK DOMAIN          READ CLOCK DOMAIN
        -------------------         ------------------

             w_clk                       r_clk
               |                           |
               v                           v
       +----------------+          +----------------+
       | Write Pointer  |          |  Read Pointer  |
       |                |          |                |
       | Binary Pointer |          | Binary Pointer |
       | Gray Pointer   |          | Gray Pointer   |
       +-------+--------+          +-------+--------+
               |                           |
               | Gray Write Pointer        | Gray Read Pointer
               |                           |
               v                           v
       +----------------+          +----------------+
       | 2-FF CDC       |          | 2-FF CDC       |
       | Synchronizer   |          | Synchronizer   |
       +-------+--------+          +-------+--------+
               |                           |
               +------------+  +-----------+
                            |  |
                            v  v
                         FIFO Memory
                              |
                              v
                           data_out
```

### RTL modules

| Module                | Purpose                                            |
| --------------------- | -------------------------------------------------- |
| `async_fifo.v`        | Top-level FIFO module                              |
| `write_pointer.v`     | Write pointer, Gray conversion, and full detection |
| `read_pointer.v`      | Read pointer, Gray conversion, and empty detection |
| `fifo_mem.v`          | Dual-clock FIFO memory                             |
| `flop_synchronizer.v` | Two-stage clock-domain synchronizer                |

---

## Why an Asynchronous FIFO?

An asynchronous FIFO is useful when data must pass between two logic blocks operating at **different or unrelated clock frequencies**.

Unlike a synchronous FIFO, the read and write sides do not share the same clock.

In this design:

```text
Write clock = 60 ns period
Read clock  = 50 ns period
```

The independent clocks require safe clock-domain crossing of the FIFO pointers.

---

## Gray-Code Pointer Synchronization

Binary pointers are converted to Gray code using:

```text
Gray = Binary XOR (Binary >> 1)
```

Gray code is useful for CDC because only one bit changes between consecutive pointer values.

The Gray-coded pointer is passed through a **two-stage flip-flop synchronizer** before being used in the opposite clock domain.

### Write pointer crossing

```text
Write Domain
    |
    v
Gray Write Pointer
    |
    v
2-FF Synchronizer
    |
    v
Read Domain
```

### Read pointer crossing

```text
Read Domain
    |
    v
Gray Read Pointer
    |
    v
2-FF Synchronizer
    |
    v
Write Domain
```

---

## Full and Empty Detection

### Empty

The FIFO is considered empty when the next read Gray pointer matches the synchronized write Gray pointer.

```text
next_read_gray == synchronized_write_gray
```

When this condition is true:

```text
empty = 1
```

### Full

The write side compares the next Gray-coded write pointer with the appropriately transformed synchronized read pointer.

When the FIFO reaches its configured capacity:

```text
full = 1
```

The design prevents:

```text
Write when full
Read when empty
```

---

## FIFO Operation

For the demonstrated 8-entry FIFO:

```text
Address    Data
-------    ----
   0       16-bit
   1       16-bit
   2       16-bit
   3       16-bit
   4       16-bit
   5       16-bit
   6       16-bit
   7       16-bit
```

The FIFO follows the **First-In, First-Out (FIFO)** principle.

For example:

```text
Write:  1 → 2 → 3 → 4 → 5

Read:   1 → 2 → 3 → 4 → 5
```

The data order is preserved across the independent clock domains.

---

# Verification

The design was verified using multiple simulation environments.

## 1. Basic Functional Testbench

File:

```text
tb/async_fifo_tb.v
```

This testbench was used for visual waveform verification of:

* Independent clocks
* Reset behavior
* Write enable
* Read enable
* Data transfer
* Full and empty flags

The waveform demonstrated correct FIFO ordering.

---

## 2. Self-Checking Verification

File:

```text
tb/async_fifo_selfcheck_tb.v
```

This testbench automatically compared expected FIFO data with the actual `data_out`.

Verified:

* Data integrity
* FIFO ordering
* Full detection
* Empty detection
* Overflow protection
* Underflow protection

### Result

```text
PASS COUNT  = 28
ERROR COUNT = 0
```

---

## 3. Extended Functional Verification

File:

```text
tb/async_fifo_check_tb.v
```

Additional directed tests were performed for:

* Reset
* Basic writes and reads
* Empty flag
* Filling the FIFO
* Full flag
* Overflow protection
* Reading all stored data
* Underflow protection

### Result

```text
PASS COUNT  = 32
ERROR COUNT = 0
```

---

## 4. Randomized Verification

File:

```text
tb/async_fifo_random_tb.v
```

Randomized read/write traffic was generated using independent clock domains.

A reference model was used to compare the expected data with the FIFO output.

### Result

```text
PASS COUNT  = 162
ERROR COUNT = 0
REFERENCE FIFO COUNT = 5
```

The remaining reference FIFO count indicates that five valid entries were still present when the randomized simulation ended; it is not a verification error.

---

# Synthesis Results

The design was synthesized and implemented using **Xilinx Vivado**.

### Post-implementation utilization

| Resource        | Used | Utilization |
| --------------- | ---: | ----------: |
| Slice LUTs      |   30 |       0.14% |
| LUT as Logic    |   18 |       0.09% |
| LUT as Memory   |   12 |       0.13% |
| Slice Registers |   48 |       0.12% |
| Block RAM       |    0 |       0.00% |
| DSP             |    0 |       0.00% |
| BUFG            |    2 |       6.25% |

The small 8 × 16 FIFO was implemented using **distributed memory** rather than block RAM.

The FIFO memory contains:

```text
8 × 16 = 128 bits
```

which is small enough for distributed-memory implementation.

---

# Timing Analysis

The design was constrained using two independent clocks:

```text
Write clock period = 60 ns
Read clock period  = 50 ns
```

The clock domains were specified as asynchronous using an XDC constraint file.

### Final post-implementation timing

| Metric                 |     Result |
| ---------------------- | ---------: |
| WNS                    | +46.645 ns |
| TNS                    |       0 ns |
| WHS                    |  +0.124 ns |
| THS                    |       0 ns |
| Failing endpoints      |          0 |
| Pulse-width violations |          0 |

Vivado reported:

```text
All user specified timing constraints are met.
```

The reported WNS reflects the specified timing constraints and should not be interpreted as the maximum operating frequency of the FIFO.

---

# Constraints

The two clock domains are defined in:

```text
constraints/async_fifo.xdc
```

The clocks are constrained as:

```tcl
create_clock -name w_clk -period 60.000 [get_ports w_clk]

create_clock -name r_clk -period 50.000 [get_ports r_clk]

set_clock_groups -asynchronous \
    -group [get_clocks w_clk] \
    -group [get_clocks r_clk]
```

This tells Vivado that the read and write clocks are unrelated asynchronous clock domains.

---

# Project Structure

```text
parameterized-async-fifo/
│
├── rtl/
│   ├── async_fifo.v
│   ├── write_pointer.v
│   ├── read_pointer.v
│   ├── fifo_mem.v
│   └── flop_synchronizer.v
│
├── tb/
│   ├── async_fifo_tb.v
│   ├── async_fifo_selfcheck_tb.v
│   ├── async_fifo_check_tb.v
│   └── async_fifo_random_tb.v
│
├── constraints/
│   └── async_fifo.xdc
│
├── results/
│   ├── waveform.png
│   ├── utilization.png
│   └── timing_summary.png
│
└── README.md
```

---

# Tools Used

* **Verilog HDL**
* **Xilinx Vivado**
* **XSim**
* RTL synthesis
* FPGA implementation
* Timing analysis

---

# Key Learning Outcomes

This project demonstrates practical experience with:

* RTL design
* Asynchronous FIFO architecture
* Clock-domain crossing
* Gray-code encoding
* Two-flop synchronizers
* Metastability mitigation
* FIFO full/empty generation
* Dual-clock memory design
* Self-checking testbenches
* Randomized verification
* FPGA synthesis
* Resource utilization analysis
* Timing constraints
* Post-implementation timing analysis

---

# Results Summary

```text
Directed verification      : 32 PASS / 0 ERROR
Randomized verification    : 162 PASS / 0 ERROR

LUTs                       : 30
Flip-Flops                 : 48
BRAM                       : 0
DSP                        : 0

WNS                        : +46.645 ns
TNS                        : 0 ns
WHS                        : +0.124 ns
Timing violations          : 0
```

The project demonstrates a complete RTL-to-implementation workflow for a parameterized asynchronous FIFO with CDC-safe pointer synchronization and automated verification.
