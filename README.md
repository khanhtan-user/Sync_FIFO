# PROJECT_SYNCHRONOUS FIFO
- This is a standard Synchronous FIFO (First-In-First-Out) with configurable data width (W) and depth (L). It supports the Full/Empty flags and the early-warning Almost-Full/Almost-Empty (AF/AE) flags with configurable thresholds.

## 1. Project Overview & Status
* **Design Specification:** System architecture and detailed specification are available at: `docs/Design_Spec/FIFO_Design_Spec.docx/`.
* **Debugging process:** Stored in detail at: `docx/Debug_log.md/`.

### Repository Structure

<img width="283" height="165" alt="image" src="https://github.com/user-attachments/assets/59446f10-69ea-4609-b3f3-a7b9297da18d" />



```text

PROJECT_IP-Sync_FIFO/
├── src/
│   ├── rtl/                  (fifo.v — single-file RTL)
│   │   └── fifo.v
│   ├── tb/                   (Top-level testbench)
│   │   └── test_bench.v
│   │   └── waveform.md
│   ├── sim/                  (Makefile and simulation run scripts)
│   │   ├── Makefile
│   │   ├── tb.f
│   │   ├── rtl.f
│   │   ├── run.csh
│   │   ├── compile.f
│   │   ├── pat.list
│   │   └── report.csh
│   │
│   └── testcases/            (3 testcase files, 12 test items in total)
│       ├── write_chk.v
│       ├── read_chk.v
│       └── all_chk.v
├── docx/
│   ├── Design_Spec/           (FIFO_Design_Spec.docx)
│   ├── Verification_Plan/     (FIFO_Verification_Plan.docx)
├── report/
│   ├── Coverage/               (summary_report.txt & detail_report.txt & Readme.md)
|       ├── Readme.md
|       ├── summary_report.txt
|       ├── detail_report.txt
└── README.md
```

### 2. Design Structure

`fifo.v` is designed compactly in **a single RTL file** (single-module), directly integrating the Memory Array, pointer logic, and flag logic — suitable for the scale of a basic sync FIFO:

```text
fifo.v (Top-level & only Module)
├── Memory Array          (reg array W x L, integrated directly — no submodule split)
├── Write/Read Pointer    (wr_ptr, rd_ptr — binary, wrap-around at L-1 → 0)
├── Element Counter       (r_count — counts the number of elements currently in the FIFO)
└── Flag Logic            (full, empty, af_flag, ae_flag — combinational, based on r_count)
```

### 3. Functional Blocks

* **Write Interface:**
  * Receives `wr_en` and `wdata`, and combines them with `full` to create the valid write signal `wr = wr_en && !full`.
  * Writes data into `mem[wr_ptr]` when `wr` is valid, then updates `wr_ptr` to the next value (with wrap-around).

* **Read Interface:**
  * Receives `rd_en`, and combines it with `empty` to create the valid read signal `rd = rd_en && !empty`.
  * Reads data from `mem[rd_ptr]` to `rdata` (registered read — delayed by 1 clock cycle relative to `rd_en`), then updates `rd_ptr` to the next value (with wrap-around).

* **Element Counter (`r_count`):**
  * Tracks the number of elements currently in the FIFO, independently of `wr_ptr`/`rd_ptr` (which are only used to address the RAM).
  * Increments on write only, decrements on read only, and holds its value on simultaneous read-write or when no operation occurs.

* **Flag Logic:**
  * Generates 4 fully combinational status flags based on comparisons of `r_count`:
    `full = (r_count == L)`, `empty = (r_count == 0)`, `af_flag = (r_count >= af_level)`, `ae_flag = (r_count <= ae_level)`.
  * `af_level`/`ae_level` are configurable threshold inputs, set statically once at the start of simulation (default `af_level = L-2`, `ae_level = 2`).

## 4. Signal Descriptions

<details>
<summary><b> FIFO Interface (fifo.v)</b></summary>

```text
+----------------+--------+------------------+---------------------------------------------------------+
| Signal name    | Dir.   | Width            | Description                                              |
+----------------+--------+------------------+---------------------------------------------------------+
| clk            | Input  | 1-bit            | System clock                                             |
| rst_n          | Input  | 1-bit            | Asynchronous reset, active low                           |
| wr_en          | Input  | 1-bit            | Write enable                                             |
| wdata          | Input  | W-bit            | Data to write into the FIFO                              |
| rd_en          | Input  | 1-bit            | Read enable                                              |
| af_level       | Input  | $clog2(L+1)-bit  | Almost-Full threshold (default L-2)                      |
| ae_level       | Input  | $clog2(L+1)-bit  | Almost-Empty threshold (default 2)                       |
| rdata          | Output | W-bit            | Data read out of the FIFO (registered, 1-clock delay)    |
| full           | Output | 1-bit            | FIFO full flag                                           |
| empty          | Output | 1-bit            | FIFO empty flag                                          |
| af_flag        | Output | 1-bit            | Almost-Full warning flag                                 |
| ae_flag        | Output | 1-bit            | Almost-Empty warning flag                                |
+----------------+--------+------------------+---------------------------------------------------------+
```

</details>

## 5. Parameter

```text
+---------------+-----------------+---------------------------------------------------------+
| Parameter     | Default value   | Brief description                                        |
+---------------+-----------------+---------------------------------------------------------+
| W             | 8               | Data width, configurable                                 |
| L             | 8               | FIFO depth, configurable                                 |
+---------------+-----------------+---------------------------------------------------------+
```

> **Note:** The minimum design constraint is `L >= 2`; for small `L` (< 4), check `0 <= ae_level < af_level <= L` yourself to avoid the AF/AE thresholds overlapping.

## 6. Verification Strategy

The system is verified in a simulation environment (Testbench), focusing on the correctness of the data flow (writes/reads in correct FIFO order), the accuracy of the `r_count` counter, and the correct timing of the status flags relative to the clock cycle.

### 6.1. Verification Goals
* **Data integrity:** Ensure data is read out in the same order it was written (First-In-First-Out), with no lost or duplicated data across wrap-arounds.
* **Boundary protection:** Ensure no write occurs when `full` and no read occurs when `empty`.
* **Signal latency:** Verify the 1-clock-cycle delay between a write/read event and the flags (`full`, `empty`, `af_flag`, `ae_flag`, `rdata`) due to the nature of synchronous registers.

### 6.2. Test Case Suites
> * Note: The detailed list of test scenarios (Test Case Plan) and the test run results are stored at: `/docx/Verification_Plan/FIFO_Verification_Plan.docx`

### 6.3. Simulation Environment
* **Simulator:** ModelSim / QuestaSim.
* **Methodology:** Direct Test (task-based, using shared tasks `fifo_write`/`fifo_read`/`fifo_write_read`/`checker` declared in `test_bench.v`; each testcase only defines `task run_test`).
* **Result:** All 12 testcases (in 3 testcase files) PASS with a clean simulation log.
* Test case:
* + all_chk.v
* <img width="537" height="324" alt="image" src="https://github.com/user-attachments/assets/c72a5da2-ab90-4844-94c5-f463c0b295ef" />
* + write_chk.v
* <img width="653" height="373" alt="image" src="https://github.com/user-attachments/assets/5662ec3a-0037-4f26-ace1-896ab845fe3c" />
* + read_chk.v
* <img width="634" height="361" alt="image" src="https://github.com/user-attachments/assets/6371265e-7355-4b4d-8db2-01be7279fcd9" />

## 7. Verification Metrics & Coverage

### 7.1. Code Coverage
* **Statement Coverage:** 100% (19/19) on `fifo.v`.
* **Branch Coverage:** 100% (14/14) on `fifo.v`.
* **Condition Coverage:** 75% (6/8) on `fifo.v` — the 2 remaining bins (`wr=1,rd=0` and `rd=1,wr=0` at the `else if (!wr && !rd)` branch) are **intentionally unreachable** because the `if/else-if` structure is mutually exclusive; they have been waived, see section 7.3.
* **Toggle Coverage:** 100% (68/68) on `fifo.v`.

### 7.2. Coverage Reports
All coverage data is automatically compiled after each simulation run:
> *For the detailed coverage reports, see: `/report/Coverage/summary_report.txt` and `/report/Coverage/detail_report.txt`.*

### 7.3. Coverage Exclusion Justification
Some coverage items are excluded based on design logic or on the characteristics of the self-checking testbench:

| Signal / Code line | Reason for exclusion |
|---|---|
| `fifo.v` line `else if (!wr && !rd)` — 2 FEC bins (`wr=1~rd`, `rd=1~wr`) | Unreachable — when execution reaches this branch, `wr` always equals `rd`, because the 2 previous branches already exclude every other case |
| `testbench.v` branch `if (actual !== expected)` (FAIL) | Never hit because the entire regression PASSes — not a verification hole |
| `testbench.v` `else` branch of `if (error_count == 0)` (FAILED) | Same — `error_count` is always 0 in a clean run |
| `ae_level`, `af_level` (toggle) | Static thresholds, configured once at the start of simulation, do not change during the design's operation |
| `error_count` (toggle) | Always holds the value 0 throughout a clean regression |


---
## 8. How to Run

### Requirements
* **Simulator:** ModelSim / QuestaSim
* **OS:** Linux / Unix

### Simulation Steps

**8.1. Change into the sim directory:**
```bash
cd src/sim
```

**8.2. Run all testcases:**
```bash
Step 1: Run everything
./run.csh
Step 2: Check the Passed/Fail results of the cases
./report.csh
```

**8.3. Run individual testcases:**
```bash
make TESTNAME=write_chk all
make TESTNAME=read_chk all
make TESTNAME=all_chk all
```

**8.4. Run with custom W/L parameters (e.g. 32-bit width, depth 32):**
```bash
make TESTNAME=write_chk W=32 L=32 all
```

**8.5. Generate the coverage report:**
```bash
rm -f *.ucdb
make TESTNAME=write_chk all_cov
make TESTNAME=read_chk all_cov
make TESTNAME=all_chk all_cov
make gen_cov
vi coverage/summary_report.txt
or
vi coverage/detail_report.txt
```

> **Note:** The log from each run is saved automatically to `src/sim/log/`.

## 9. Author

| Information | Details                                               |
|-------------|-------------------------------------------------------|
| **Full name**  | Trần Hồ Khánh Tân                                  |
| **University** | FPT University                                     |
| **Major**      | Semiconductor IC Design                            |
| **Cohort**     | 2024 – 2028                                        |
| **Type**       | Individual Project                                 |
