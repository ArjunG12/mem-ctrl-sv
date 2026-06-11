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
