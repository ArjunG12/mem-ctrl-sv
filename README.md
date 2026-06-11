# Memory Controller Verification Environment

This repository contains the SystemVerilog RTL design and a custom-layered verification environment for a generic Memory Controller. The testbench architecture mimics standard UVM methodologies by utilizing separate objects for stimulus generation, driving, and monitoring.

## Design Specifications (DUT)

The Memory Controller (`memctr`) handles synchronous read and write accesses to a generic memory array. 

**Basic Signal Information:**
* **Address Width:** 8 bits (256 addressable registers)
* **Data Width:** 16 bits
* **Reset Value:** `16'hABCD`
* **Clocking:** Operations are synchronous to the positive edge of `clk`, and reset is an active-low asynchronous signal (`rstn`).

**Core Functionality:**
1. **Reset State:** Upon driving the reset low, the predefined RESET value (`16'hABCD`) is driven to all 256 memory registers. During reset, the `ready` signal asserts HIGH.
2. **Access Condition:** The design is ready to accept a transaction if both Chip Select (`CS`) and `ready` are `1`.
    * **Write (`wr = 1`):** Writes `wdata` to the specified `addr`.
    * **Read (`wr = 0`):** Reads data from the specified `addr` and drives it onto `RDATA`.
3. **Invalid Access:** If `CS` and `ready` are not both `1`, `RDATA` defaults to `0`.
4. **Ready Handshake:** Once a read or write access is initiated, the `ready` signal drives LOW for at least one clock cycle to mimic access latency.

## Testbench Architecture

The verification environment is designed with a layered approach:

* **Transaction (Txn Item):** Contains randomized properties of all signals to be driven to the DUT and includes a `display` method for tracking packet data.
* **Generator:** Generates stimulus by randomizing the transaction packets for $N$ iterations and feeds them into a mailbox connected to the Driver.
* **Driver:** Receives transaction packets from the Generator via a mailbox and drives the signals into the DUT through a virtual interface.
* **Monitor (WIP):** Captures functional data from the DUT's interface using a run task. Once a transaction concludes, it packages the captured info and sends it to the Scoreboard via a mailbox.
* **Scoreboard (WIP):** Responsible for data integrity verification. It stores the expected data sent to the memory elements and compares the actual output `RDATA` against the expected values, throwing errors on mismatches.
* **Environment (Env):** A container object that encapsulates and connects the generator, driver, monitor, and scoreboard.
* **Test:** Instantiates the environment and applies different scenarios/constraints for randomization.
* **Top Module (`simple_tb`):** Contains the DUT instance, clock generation, reset logic, interface instantiation, and testcase execution.

## File Structure
* `design.sv`: Contains the `mem_intf` interface and the RTL `memctr` module.
* `testbench.sv`: Contains the OOP testbench components and top-level simulation module.

## How to Run
This code is written in standard IEEE 1800 SystemVerilog and can be compiled and simulated using any standard EDA tool (e.g., Synopsys VCS, Cadence Xcelium, Mentor Questa) or directly on EDA Playground.

## Simulation Results

The verification environment was compiled and simulated using **Cadence Xcelium**. The results confirm successful transaction randomization, proper stimulus driving, and correct operation of the `ready` handshake protocol.

### Console Output

The simulation logs demonstrate the Generator creating randomized transactions and the Driver successfully applying them to the DUT interface.

```text
xcelium> source /xcelium25.03/tools/xcelium/files/xmsimrc
xcelium> run
=== Simple Testbench ===
[GEN] 5 | wr=0 addr=0xb8 wdata=0xd002 rdata=0x0000
[GEN] 5 | wr=1 addr=0x77 wdata=0xd963 rdata=0x0000
[GEN] 5 | wr=1 addr=0xd9 wdata=0x3313 rdata=0x0000
[GEN] 5 | wr=0 addr=0x53 wdata=0x2abd rdata=0x0000
[GEN] 5 | wr=0 addr=0xfb wdata=0x08ab rdata=0x0000
[GEN] 5 | wr=0 addr=0x23 wdata=0x1cc4 rdata=0x0000
[GEN] 5 | wr=0 addr=0xe1 wdata=0x6bcc rdata=0x0000
[GEN] 5 | wr=0 addr=0xd7 wdata=0xa2f3 rdata=0x0000
[GEN] 5 | wr=1 addr=0x6d wdata=0xea78 rdata=0x0000
[GEN] 5 | wr=1 addr=0x32 wdata=0x0654 rdata=0x0000
[GEN] 5 | wr=0 addr=0xb7 wdata=0x5cf2 rdata=0x0000
[GEN] 5 | wr=1 addr=0xf8 wdata=0x60e6 rdata=0x0000
[GEN] 5 | wr=1 addr=0x33 wdata=0xd2cf rdata=0x0000
[GEN] 5 | wr=0 addr=0xbd wdata=0x2581 rdata=0x0000
[GEN] 5 | wr=0 addr=0xa4 wdata=0x8677 rdata=0x0000
[GEN] 5 | wr=0 addr=0xbe wdata=0x4a54 rdata=0x0000
[GEN] 5 | wr=0 addr=0xd2 wdata=0x0fa2 rdata=0x0000
[GEN] 5 | wr=0 addr=0x78 wdata=0x22aa rdata=0x0000
[GEN] 5 | wr=0 addr=0x78 wdata=0x683d rdata=0x0000
[GEN] 5 | wr=1 addr=0xb4 wdata=0xec0e rdata=0x0000
[DRIVER] 15 | wr=0 addr=0xb8 wdata=0xd002 rdata=0x0000
[DRIVER] 45 | wr=1 addr=0x77 wdata=0xd963 rdata=0x0000
[DRIVER] 95 | wr=1 addr=0xd9 wdata=0x3313 rdata=0x0000
[DRIVER] 145 | wr=0 addr=0x53 wdata=0x2abd rdata=0x0000
[DRIVER] 175 | wr=0 addr=0xfb wdata=0x08ab rdata=0x0000
[DRIVER] 205 | wr=0 addr=0x23 wdata=0x1cc4 rdata=0x0000
[DRIVER] 235 | wr=0 addr=0xe1 wdata=0x6bcc rdata=0x0000
[DRIVER] 265 | wr=0 addr=0xd7 wdata=0xa2f3 rdata=0x0000
[DRIVER] 295 | wr=1 addr=0x6d wdata=0xea78 rdata=0x0000
[DRIVER] 345 | wr=1 addr=0x32 wdata=0x0654 rdata=0x0000
[DRIVER] 395 | wr=0 addr=0xb7 wdata=0x5cf2 rdata=0x0000
[DRIVER] 425 | wr=1 addr=0xf8 wdata=0x60e6 rdata=0x0000
[DRIVER] 475 | wr=1 addr=0x33 wdata=0xd2cf rdata=0x0000
[DRIVER] 525 | wr=0 addr=0xbd wdata=0x2581 rdata=0x0000
[DRIVER] 555 | wr=0 addr=0xa4 wdata=0x8677 rdata=0x0000
[DRIVER] 585 | wr=0 addr=0xbe wdata=0x4a54 rdata=0x0000
[DRIVER] 615 | wr=0 addr=0xd2 wdata=0x0fa2 rdata=0x0000
[DRIVER] 645 | wr=0 addr=0x78 wdata=0x22aa rdata=0x0000
[DRIVER] 675 | wr=0 addr=0x78 wdata=0x683d rdata=0x0000
=== Complete ===
Simulation complete via $finish(1) at time 705 NS + 0

<img width="2382" height="249" alt="image" src="https://github.com/user-attachments/assets/16bedeef-2d2e-4896-9673-dee8202679f3" />

