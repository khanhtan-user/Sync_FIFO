# PROJECT_SYNCHRONOUS FIFO
- Đây là Synchronous FIFO (First-In-First-Out) tiêu chuẩn, có thể tùy chỉnh tham số độ rộng dữ liệu (W) và độ sâu (L), hỗ trợ cờ Full/Empty và cờ cảnh báo sớm Almost-Full/Almost-Empty (AF/AE) với ngưỡng cấu hình được.

## 1. Project Overview & Status
* **Design Specification:** Kiến trúc hệ thống và đặc tả chi tiết tại: `docs/Design_Spec/FIFO_Design_Spec.docx/`.
* **Debugging process:** Được lưu trữ chi tiết tại: `docx/Debug_log.md/`.

### Repository Structure

<img width="283" height="165" alt="image" src="https://github.com/user-attachments/assets/59446f10-69ea-4609-b3f3-a7b9297da18d" />



```text

PROJECT_IP-Sync_FIFO/
├── src/
│   ├── rtl/                  (fifo.v — single-file RTL)
│   │   └── fifo.v
│   ├── tb/                   (Testbench top-level)
│   │   └── test_bench.v
│   ├── sim/                  (Makefile và script chạy simulation)
│   │   ├── Makefile
│   │   ├── tb.f
│   │   ├── rtl.f
│   │   ├── run.csh
│   │   ├── compile.f
│   │   ├── pat.list
│   │   └── report.csh
│   │
│   └── testcases/            (3 file testcase, tổng cộng 12 test items)
│       ├── write_chk.v
│       ├── read_chk.v
│       └── all_chk.v
├── docx/
│   ├── Design_Spec/           (FIFO_Design_Spec.docx)
│   ├── Verification_Plan/     (FIFO_Verification_Plan.docx)
│   └── Debug_log.md
├── report/
│   ├── Coverage/               (summary_report.txt & detail_report.txt)
└── README.md
```

### 2. Cấu trúc thiết kế (Design Structure)

 `fifo.v` được thiết kế gọn trong **1 file RTL duy nhất** (single-module), tích hợp trực tiếp Memory Array, pointer logic và flag logic — phù hợp với quy mô của 1 sync FIFO cơ bản:

```text
fifo.v (Top-level & only Module)
├── Memory Array          (reg array W x L, tích hợp trực tiếp — không tách submodule)
├── Write/Read Pointer    (wr_ptr, rd_ptr — binary, wrap-around tại L-1 → 0)
├── Element Counter       (r_count — đếm số phần tử hiện có trong FIFO)
└── Flag Logic            (full, empty, af_flag, ae_flag — combinational, dựa trên r_count)
```

### 3. Khối chức năng chính (Functional Blocks)

* **Write Interface:**
  * Nhận `wr_en` và `wdata`, kết hợp với `full` để tạo tín hiệu ghi hợp lệ `wr = wr_en && !full`.
  * Ghi dữ liệu vào `mem[wr_ptr]` khi `wr` hợp lệ, cập nhật `wr_ptr` sang giá trị kế tiếp (có wrap-around).

* **Read Interface:**
  * Nhận `rd_en`, kết hợp với `empty` để tạo tín hiệu đọc hợp lệ `rd = rd_en && !empty`.
  * Đọc dữ liệu từ `mem[rd_ptr]` ra `rdata` (registered read — trễ 1 chu kỳ clock so với `rd_en`), cập nhật `rd_ptr` sang giá trị kế tiếp (có wrap-around).

* **Element Counter (`r_count`):**
  * Theo dõi số phần tử hiện có trong FIFO, độc lập với `wr_ptr`/`rd_ptr` (vốn chỉ dùng để địa chỉ hóa RAM).
  * Tăng khi chỉ ghi, giảm khi chỉ đọc, giữ nguyên khi đọc-ghi đồng thời hoặc không thao tác nào.

* **Flag Logic:**
  * Sinh 4 cờ trạng thái hoàn toàn tổ hợp (combinational), dựa trên so sánh `r_count`:
    `full = (r_count == L)`, `empty = (r_count == 0)`, `af_flag = (r_count >= af_level)`, `ae_flag = (r_count <= ae_level)`.
  * `af_level`/`ae_level` là input threshold cấu hình được, set tĩnh 1 lần lúc bắt đầu mô phỏng (mặc định `af_level = L-2`, `ae_level = 2`).

## 4. Signal Descriptions

<details>
<summary><b> FIFO Interface (fifo.v)</b></summary>

```text
+----------------+--------+------------------+---------------------------------------------------------+
| Tên tín hiệu   | Hướng  | Độ rộng          | Mô tả chức năng                                          |
+----------------+--------+------------------+---------------------------------------------------------+
| clk            | Input  | 1-bit            | Xung clock hệ thống                                      |
| rst_n          | Input  | 1-bit            | Reset bất đồng bộ, tích cực mức thấp                     |
| wr_en          | Input  | 1-bit            | Cho phép ghi                                             |
| wdata          | Input  | W-bit            | Dữ liệu cần ghi vào FIFO                                 |
| rd_en          | Input  | 1-bit            | Cho phép đọc                                             |
| af_level       | Input  | $clog2(L+1)-bit  | Ngưỡng cảnh báo Almost-Full (mặc định L-2)               |
| ae_level       | Input  | $clog2(L+1)-bit  | Ngưỡng cảnh báo Almost-Empty (mặc định 2)                |
| rdata          | Output | W-bit            | Dữ liệu đọc ra từ FIFO (registered, trễ 1 clock)         |
| full           | Output | 1-bit            | Cờ báo FIFO đầy                                          |
| empty          | Output | 1-bit            | Cờ báo FIFO rỗng                                         |
| af_flag        | Output | 1-bit            | Cờ cảnh báo gần đầy (Almost-Full)                        |
| ae_flag        | Output | 1-bit            | Cờ cảnh báo gần rỗng (Almost-Empty)                      |
+----------------+--------+------------------+---------------------------------------------------------+
```

</details>

## 5. Parameter

```text
+---------------+-----------------+---------------------------------------------------------+
| Tên parameter | Giá trị mặc định| Mô tả tóm tắt chức năng                                  |
+---------------+-----------------+---------------------------------------------------------+
| W             | 8               | Độ rộng dữ liệu (data width), tùy chỉnh được             |
| L             | 8               | Độ sâu FIFO (depth), tùy chỉnh được                      |
+---------------+-----------------+---------------------------------------------------------+
```

> **Lưu ý:** Ràng buộc thiết kế tối thiểu `L >= 2`; với `L` nhỏ (< 4), cần tự kiểm tra lại `0 <= ae_level < af_level <= L` để tránh 2 ngưỡng AF/AE chồng lấn.

## 6. Verification Strategy

Hệ thống được kiểm thử dựa trên môi trường mô phỏng (Testbench), tập trung vào tính đúng đắn của luồng dữ liệu (ghi/đọc theo đúng thứ tự FIFO), tính chính xác của bộ đếm `r_count`, và thời điểm phát cờ trạng thái đúng theo chu kỳ clock.

### 6.1. Mục tiêu kiểm thử
* **Tính toàn vẹn dữ liệu:** Đảm bảo dữ liệu đọc ra đúng thứ tự đã ghi vào (First-In-First-Out), không mất/trùng dữ liệu qua các lần wrap-around.
* **Bảo vệ biên:** Đảm bảo không ghi khi `full`, không đọc khi `empty`.
* **Độ trễ tín hiệu:** Kiểm chứng đúng độ trễ 1 chu kỳ clock giữa sự kiện ghi/đọc và các cờ (`full`, `empty`, `af_flag`, `ae_flag`, `rdata`) do bản chất thanh ghi đồng bộ.

### 6.2. Nhóm các kịch bản kiểm thử (Test Case Suites)
> * Lưu ý: Danh sách chi tiết các kịch bản kiểm thử (Test Case Plan) và kết quả chạy các test cases được lưu trữ chi tiết tại: `/docx/Verification_Plan/FIFO_Verification_Plan.docx`

### 6.3. Môi trường mô phỏng
* **Simulator:** ModelSim / QuestaSim.
* **Phương pháp:** Direct Test (task-based, dùng chung task `fifo_write`/`fifo_read`/`fifo_write_read`/`checker` khai báo tại `test_bench.v`, mỗi testcase chỉ định nghĩa `task run_test`).
* **Kết quả:** Toàn bộ 12 testcases (trong 3 file testcase) đều đạt kết quả PASS với log mô phỏng sạch (Clean Log).

## 7. Verification Metrics & Coverage

### 7.1. Code Coverage (Độ bao phủ mã nguồn)
* **Statement Coverage:** 100% (19/19) trên `fifo.v`.
* **Branch Coverage:** 100% (14/14) trên `fifo.v`.
* **Condition Coverage:** 75% (6/8) trên `fifo.v` — 2 bin còn lại (`wr=1,rd=0` và `rd=1,wr=0` tại nhánh `else if (!wr && !rd)`) là **unreachable có chủ đích** do cấu trúc `if/else-if` loại trừ lẫn nhau; đã waive, xem mục 7.3.
* **Toggle Coverage:** 100% (68/68) trên `fifo.v`.

### 7.2. Kết quả báo cáo
Mọi số liệu về Coverage được tổng hợp tự động sau mỗi lần chạy Simulation:
> *Chi tiết báo cáo độ bao phủ (Coverage Report) xem tại: `/report/Coverage/summary_report.txt` và `/report/Coverage/detail_report.txt`.*

### 7.3. Coverage Exclusion Justification
Một số hạng mục coverage được loại trừ (exclude) dựa trên lý do logic thiết kế hoặc do đặc điểm bài kiểm thử tự-kiểm-tra (self-checking testbench):

| Tín hiệu / Dòng code | Lý do loại trừ |
|---|---|
| `fifo.v` dòng `else if (!wr && !rd)` — 2 FEC bin (`wr=1~rd`, `rd=1~wr`) | Unreachable — khi thực thi tới nhánh này, `wr` luôn bằng `rd` do 2 nhánh trước đã loại trừ mọi trường hợp khác |
| `testbench.v` nhánh `if (actual !== expected)` (FAIL) | Chưa từng hit vì toàn bộ regression PASS — không phải lỗ hổng verify |
| `testbench.v` nhánh `else` của `if (error_count == 0)` (FAILED) | Tương tự — `error_count` luôn = 0 trong 1 lần chạy sạch |
| `ae_level`, `af_level` (toggle) | Static threshold, cấu hình 1 lần lúc đầu mô phỏng, không đổi theo thiết kế |
| `error_count` (toggle) | Luôn giữ giá trị 0 trong suốt regression sạch |


---
## 8. How to Run

### Yêu cầu
* **Simulator:** ModelSim / QuestaSim
* **OS:** Linux / Unix

### Các bước chạy simulation

**8.1. Di chuyển vào thư mục sim:**
```bash
cd src/sim
```

**8.2. Chạy toàn bộ testcase:**
```bash
Bước 1 : Chạy toàn bộ
./run.csh
Bước 2 : kiểm tra kết quả Passed/Fail của các cases
./report.csh
```

**8.3. Chạy từng testcase riêng lẻ:**
```bash
make TESTNAME=write_chk all
make TESTNAME=read_chk all
make TESTNAME=all_chk all
```

**8.4. Chạy với tham số W/L tùy chỉnh (ví dụ 32-bit, depth 32):**
```bash
make TESTNAME=write_chk W=32 L=32 all
```

**8.5. Xuất báo cáo coverage:**
```bash
rm -f *.ucdb
make TESTNAME=write_chk all_cov
make TESTNAME=read_chk all_cov
make TESTNAME=all_chk all_cov
make gen_cov
vi coverage/summary_report.txt
hoặc
vi coverage/detail_report.txt
```

> **Lưu ý:** Kết quả log sau mỗi lần chạy được lưu tự động vào `src/sim/log/`.

## 9. Author

| Thông tin | Chi tiết                                             |
|-----------|-------------------------------------------------------|
| **Họ và tên** | Trần Hồ Khánh Tân                                |
| **Trường**    | Đại Học FPT                                      |
| **Chuyên ngành** | Thiết kế vi mạch bán dẫn                      |
| **Khóa** | 2024 – 2028                                           |
| **Hình thức** | Cá nhân (Individual Project)                     |
