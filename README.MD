# IEC 61131-3 Algorithm Optimization: Circular Buffer vs. Linear Shift

![Platform](https://img.shields.io/badge/Platform-OpenPLC-blue)
![Language](https://img.shields.io/badge/Language-IEC%2061131--3%20ST-orange)
![Optimization](https://img.shields.io/badge/Complexity-O(1)-brightgreen)
![Status](https://img.shields.io/badge/Status-Validated-success)

## ⚡ Executive Summary
This project demonstrates a high-performance memory management strategy for Industrial Control Systems (ICS). By replacing standard Linear Shift FIFO logic ($O(N)$) with a pointer-based Circular Buffer ($O(1)$), **memory write operations were reduced by >99.9%** in high-volume datasets.

This optimization ensures deterministic scan times and prevents watchdog faults in critical data logging applications.

---

## 📉 The Problem: Arithmetic Progression of Cost
In standard PLC instructions (like Rockwell's `FFU`), removing an item from a queue requires physically shifting every remaining element in memory to fill the void.
* **Complexity:** $O(N)$ (Linear time).
* **Impact:** As the buffer grows, the CPU load increases proportionally.
* **Risk:** Large buffers ($N > 1000$) can cause scan time spikes, potentially tripping the PLC Watchdog Timer.

## 🚀 The Solution: Circular Buffer (Ring Topology)
Instead of moving data, this implementation moves the **pointers**. Using a Head/Tail pointer architecture with wrap-around logic, data remains stationary in memory.
* **Complexity:** $O(1)$ (Constant time).
* **Impact:** Execution time is decoupled from dataset size.
* **Result:** Zero memory shifts, regardless of queue capacity.

---

## 📊 Performance Benchmarks
**Stress Test Parameters:**
* **Buffer Size:** 5,000 Integers
* **Platform:** OpenPLC Runtime (v3)
* **Test Case:** Sequential Dequeue of 3 items from a full buffer.

| Metric | Linear Shift (Standard) | Circular Buffer (Optimized) | Outcome |
| :--- | :---: | :---: | :---: |
| **Queue Integrity** | Valid | Valid | Pass |
| **Op Cost (Pop #1)** | 4,999 Writes | **0 Writes** | 🚀 |
| **Op Cost (Pop #2)** | 4,998 Writes | **0 Writes** | 🚀 |
| **Op Cost (Pop #3)** | 4,997 Writes | **0 Writes** | 🚀 |
| **Total CPU Operations** | **14,994** | **0** | **Pass** |

> *Verification proof available in `/docs/Stress_Test_Proof.png`*

---

## 📂 Repository Structure

```text
/PLC-Algorithm-Optimization
│
├── /docs
│   ├── FIFO_Analysis_Report.pdf   # Full IEEE-style engineering report (LaTeX)
│   └── Stress_Test_Proof.png      # Debugger screenshot verifying metrics
│
├── /src
│   ├── main.st                    # Main program with Stress Test Logic
│   ├── FB_FIFO.st                 # The inefficient Linear Shift Function Block
│   ├── FB_CircularQueue.st        # The optimized Circular Function Block
│   └── Linear_vs_Circular.xml     # PLCOpen XML Export (Importable to other IDEs)
│
└── README.md