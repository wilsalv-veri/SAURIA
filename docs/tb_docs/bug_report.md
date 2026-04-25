# Bug Report

This document summarizes the main findings from functional verification of the Sauria subsystem.
The format is meant to stay easy to scan and easy to maintain without needing extra metadata.

Scope: this document tracks RTL implementation bugs and known configuration hazards. Architectural or semantic mismatches are tracked separately in architectural_findings.md.

## Report Structure

- Architectural findings cover behavior that breaks the intended GEMM semantics.
- RTL logic findings cover implementation bugs in the current design.
- Known configuration hazards cover unsupported or deadlock-prone cases that currently rely on constraints or software awareness.

## Architectural Findings

Architectural findings have been moved to a separate document so this file stays focused on RTL bugs and known hazards.

See `architectural_findings.md` for the architecture-specific issues.

## RTL Logic Findings

### Sauria Core Summary

| ID | Area | File(s) | Title |
|---|---|---|---|
| CORE_BUGID1 | Main Controller | context_fsm.sv | Context Switch FSM Hangs Waiting For Data Feeders Completion |
| CORE_BUGID2 | Partial-Sums Manager | psm_shift_fsm.sv | Partial Sums Shift FSM Can Start After All Contexts Complete |
| CORE_BUGID3 | Partial-Sums Manager | psm_idxcnt.sv | Incorrect Formula For Last Tile Element SRAMC Read/Write Mask |
| CORE_BUGID4 | Main Controller | feeders_fsm.sv | Pipeline Infinitely Stalled When One Feeder Finishes Earlier |
| CORE_BUGID5 | Main Controller | context_controller.sv | Computation Fails To Complete, Deadlocking Context FSM |
| CORE_BUGID6 | Main Controller | context_controller.sv | Extra Cycle (+1) Of Computation Leads To Incorrect Partial Sums |
| CORE_BUGID7 | Main Controller | context_controller.sv | Extra Cycle (+1) Of Computation From Subsequent Contexts |
| CORE_BUGID8 | Partial-Sums Manager | psm_top.sv | Partial Sums Manager Does Not Guarantee Zero Data For Inactive Columns |
| CORE_BUGID9 | Partial-Sums Manager | psm_idxcnt.sv | Partial Sums Tile Reading and Writing Overflow Shift Register |
| COMMON_BUGID1 | Generic Counter | cnt_generic.sv | Generic Counter Sets Overflow Flag at Zero |

### Sauria Core

#### CORE_BUGID1 - Context Switch FSM Hangs Waiting For Data Feeders Completion

- Area: Main Controller
- File(s): context_fsm.sv

**Issue**

If the partial-sums tile is smaller than the IFMAPS tile, the partial-sums manager can finish before the feeders are done loading data. The feeders cannot keep going if their FIFOs are full, so they need more pop operations. At the same time, the context controller and context FSM wait for both the feeders and the partial-sums manager to finish before allowing the context switch.

That creates a circular dependency: the feeders need pops to keep moving, but the FSM will not move on until the feeders are already done.

**Proposed Fix**

Remove feeder completion from the context-switch condition and rely only on the partial-sums manager completion indication.

---

#### CORE_BUGID2 - Partial Sums Shift FSM Can Start After All Contexts Complete

- Area: Partial-Sums Manager
- File(s): psm_shift_fsm.sv

**Issue**

The idle-state next-state logic lets the partial-sums shift FSM start even after all contexts are complete. That can leave the FSM waiting on inputs from the rest of the core when no more activity should happen.

**Proposed Fix**

Check completion_flag first in the idle state so the FSM ignores any new activity once processing is done.

---

#### CORE_BUGID3 - Incorrect Formula For Last Tile Element SRAMC Read/Write Mask

- Area: Partial-Sums Manager
- File(s): psm_idxcnt.sv

**Issue**

The partial-sums index counter computes the first and last elements touched by each SRAMC read or write. The current last-index formula,
idx_end = kk_idx + i_cxlim - (SRAMC_N + 1),
fails when x step = i_cxlim = SRAMC_N.

**Proposed Fix**

Remove the SRAMC_N term from the last-index calculation so the formula works across all cases.

---

#### CORE_BUGID4 - Pipeline Infinitely Stalled When One Feeder Finishes Earlier

- Area: Main Controller
- File(s): feeders_fsm.sv

**Issue**

The feeders FSM handles the case where a feeder finishes before the feeding state starts. It does not handle the case where one feeder finishes earlier while already in the feeding state. In that case, the pipeline stays disabled, the other feeder cannot continue, and the computation cannot drain cleanly.

Even if one feeder no longer has valid data, the rest of the system should still be able to finish cleanly.

**Proposed Fix**

Set pre_feeding_flag = 1 in the feeding state. This changes the original meaning of the flag, but it is the least intrusive way to release the count_hold path that gates pipeline enable.

---

#### CORE_BUGID5 - Computation Fails To Complete, Deadlocking Context FSM

- Area: Main Controller
- File(s): context_controller.sv

**Issue**

After feeders stop sending new data, feeders_pop_en stays high while the FIFOs drain so the remaining computation can finish. The context controller currently requires the feeders to still be popping when it generates the outward-facing computation-done signal. Because there is a one-cycle delay between the internal done condition and the output signal, the feeder pop condition has already dropped by then.

That prevents computation_done from asserting and leaves the context FSM stuck in ARRAY_BUSY.

**Proposed Fix**

Remove the requirement that feeders must still be popping when the computation-done output is generated. That condition is already used earlier to qualify the internal done state.

---

#### CORE_BUGID6 - Extra Cycle (+1) Of Computation Leads To Incorrect Partial Sums

- Area: Main Controller
- File(s): context_controller.sv

**Issue**

For computations longer than one cycle, the computation-done signal is generated too late relative to incntlim. By the time that indication makes it through the context-switch FSM and feeder pops are disabled, the computation counter has already reached incntlim.

That causes one extra IFMAPS column and one extra weights row to be popped, which corrupts the partial sums.

**Proposed Fix**

Start the computation-done indication one cycle earlier so feeder popping stops when comp_count = incntlim - 1.

---

#### CORE_BUGID7 - Extra Cycle (+1) Of Computation From Subsequent Contexts

- Area: Main Controller
- File(s): context_controller.sv

**Issue**

For later contexts, the latency between feeder pop_en and data arriving at the array is one cycle shorter because the feeder FIFOs are already primed. The current computation-done timing does not account for that shorter path, so later contexts also run one extra cycle and corrupt the MAC results.

**Proposed Fix**

Assert the computation-done indication one cycle earlier for contexts after the first.

---

#### CORE_BUGID8 - Partial Sums Manager Does Not Guarantee Zero Data For Inactive Columns

- Area: Partial-Sums Manager
- File(s): psm_top.sv

**Issue**

The partial-sums manager shifts in data from either SRAMC or the systolic array output. When inactive columns are present, the shift FSM runs extra cycles to replace those columns. The current logic assumes the selected input source already carries zero data, but that is not guaranteed.

That can leave inactive columns filled with non-zero values.

**Proposed Fix**

Add a source-selection case for POSTREAD_SHIFT so explicit zero data is shifted in during the inactive-column cleanup phase.

---

#### CORE_BUGID9 - Partial Sums Tile Reading and Writing Overflow Shift Register

- Area: Partial-Sums Manager
- File(s): psm_idxcnt.sv

**Issue**

The partial-sums SRAM read and write sequence is driven by configurable index counters. Those counters can request more SRAM accesses than fit into the partial-sums shift register, even though the shift register is sized to match the systolic array one-to-one. When that happens, partial sums overflow the register and data is lost.

**Proposed Fix**

Introduce a new fastest-running counter whose limit matches the number of array columns. Use it to bound each context to a full-array chunk of partial sums, and adjust the original k-step handling so the remaining iteration space still advances correctly.

---

#### COMMON_BUGID1 - Generic Counter Sets Overflow Flag at Zero

- Area: Generic Counter
- File(s): cnt_generic.sv

**Issue**

The generic counter used by IFMAPS, weights, and partial sums asserts overflow immediately at zero when the limit fits within a single iteration. That creates false limit-reached indications and breaks core dataflow correctness.

**Proposed Fix**

Update the counter so overflow only changes when the counter is enabled.

---

### Dataflow Controller Summary

| ID | Area | File(s) | Title |
|---|---|---|---|
| DF_BUGID1 | Dataflow Controller | sauria_dma_controller.sv | Incorrect awaddr Is Sent in SEND_CMD |
| DF_BUGID2 | Dataflow Controller | sauria_dma_controller.sv | SEND_CMD State Deadlocked |
| DF_BUGID3 | Dataflow Controller | sauria_dma_controller.sv | Incorrect Data Sent To DMA CSRs |
| DF_BUGID4 | Dataflow Controller | sauria_dma_controller.sv | DMA Controller FSM Fails To Start DMA Engine After First Iteration |
| DF_BUGID5 | Dataflow Controller | sauria_dma_controller.sv | Divergent Paths After Write Response |
| DF_BUGID6 | Dataflow Controller | sauria_dma_controller.sv | Write Interrupt Failed To Be Cleared |
| DF_BUGID7 | Dataflow Controller | sauria_dma_controller.sv | Extra Start DMA Reader/Writer Engine Sent After Completion |
| DF_BUGID8 | Dataflow Controller | sauria_dma_controller.sv | Tile Pointer Fails To Advance After Tile Read |
| DF_BUGID9 | Dataflow Controller | sauria_dma_controller.sv | Last Two Tensor-Loop Iterations Deadlock FSM |
| DF_BUGID10 | Dataflow Controller | sauria_interface.sv | Partial Sum K Lim Formula Uses Tile K Step Instead of W Step |
| DF_BUGID11 | Dataflow Controller | sauria_interface.sv | Partial Sum Y Lim Formula Uses Tile Partial Sum Y Step |
| DF_BUGID12 | Dataflow Controller | sauria_interface.sv | Incorrect Number of Elements Sent Per Weights DMA Read Request |
| DF_BUGID13 | Dataflow Controller | sauria_interface.sv | Incorrect Number of Elements Sent Per Partial Sum DMA Read Request |
| DF_BUGID14 | Dataflow Controller | sauria_interface.sv | Incorrect Partial Sum DMA Read Request Size When Y Lim = 0 |
| DF_BUGID15 | Dataflow Controller | sauria_interface.sv | Incorrect Partial Sum DMA Read Request Size When Z Lim = 0 |
| DF_BUGID16 | Dataflow Controller | sauria_interface.sv | Weights W Lim Incorrectly Set When WXfer_op Is On |
| DF_BUGID17 | Dataflow Controller | sauria_dma_controller.sv | Flattening Y and K Psums Dimensions Deadlocks FSM |
| DF_BUGID18 | Dataflow Controller | sauria_dma_controller.sv | Incorrect Tensor Read On Second Iteration When loop_order = 2 |

### Dataflow Controller

#### DF_BUGID1 - Incorrect awaddr Is Sent in SEND_CMD

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

The RTL looks like it was meant to assert wvalid one cycle after awvalid so the address can be latched first. Instead, awvalid and wvalid assert in the same cycle, which causes the wrong awaddr to be written.

**Proposed Fix**

Use awvalid and wvalid to drive addr_sent and data_sent state tracking instead of awready and wready.

---

#### DF_BUGID2 - SEND_CMD State Deadlocked

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

SEND_CMD is supposed to issue multiple CSR writes to start a DMA read from memory. After the first CSR write, the state deadlocks because the condition for issuing the next write is wrong.

**Proposed Fix**

Simplify the write-entry condition so it depends only on address-sent and data-sent indications.

---

#### DF_BUGID3 - Incorrect Data Sent To DMA CSRs

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

Some DMA CSRs contain only single-bit fields while others use the full CSR width. After a full-width write, the leftover bits are not cleared before writing the single-bit CSRs, so stale bits stay set.

**Proposed Fix**

Start each single-bit CSR write from an all-zero value so previous bits are cleared.

---

#### DF_BUGID4 - DMA Controller FSM Fails To Start DMA Engine After First Iteration

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

In SYNC_WRESP, the start-read or start-write DMA CSR is only sent on the first iteration. Later iterations wait for a reader interrupt that never arrives because the engine was never started.

**Proposed Fix**

Remove the first-iteration special case so every iteration transitions to SEND_START_ADDR.

---

#### DF_BUGID5 - Divergent Paths After Write Response

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

WAIT_START_WRESP is meant to wait for SRAM writes to finish without adding extra delay. In practice, it takes different next-state paths depending on whether it sees the AXI4-Lite write response or the DMA write interrupt first. Those paths do not converge correctly.

**Proposed Fix**

Once bvalid has been seen, always wait for the DMA write interrupt before advancing.

---

#### DF_BUGID6 - Write Interrupt Failed To Be Cleared

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

WAIT_DMA_INTR_READER clears only the reader interrupt and assumes WAIT_DMA_INTR_WRITER will clear the writer interrupt. Because the FSM can leave the reader-wait state through multiple paths, the writer interrupt can be left uncleared.

**Proposed Fix**

Clear both reader and writer interrupts regardless of which one triggered the wait state.

---

#### DF_BUGID7 - Extra Start DMA Reader/Writer Engine Sent After Completion

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

After a tile has been read from memory and written to SRAM, the controller should decide what to do next, such as advancing the tile pointer. Instead, it sends another start command to the DMA reader or writer.

**Proposed Fix**

Transition from WAIT_CLR_INTR_WRESP directly to CHECK_NEXT_ACTION.

---

#### DF_BUGID8 - Tile Pointer Fails To Advance After Tile Read

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

Once the current tile has been fully read into SRAM, the dataflow controller should sync with the tensor core, wait for computation to finish, and then transfer partial sums. Instead, the DMA controller waits for another read interrupt that will never arrive because the tile read has already finished.

**Proposed Fix**

Update CHECK_NEXT_ACTION so it goes directly to SAURIA_SYNC after IFMAPS, weights if applicable, and psums have all been read.

---

#### DF_BUGID9 - Last Two Tensor-Loop Iterations Deadlock FSM

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

After computation finishes and partial sums are written back to memory, the dataflow and DMA controller FSMs go through two extra sync iterations. During that sequence, the DMA controller enters a state that waits for a reader interrupt even though no reads are still pending.

**Proposed Fix**

At the point where partial sums have finished writing to memory, make CHECK_NEXT_ACTION transition directly to SAURIA_SYNC.

---

#### DF_BUGID10 - Partial Sum K Lim Formula Uses Tile K Step Instead of W Step

- Area: Dataflow Controller
- File(s): sauria_interface.sv

**Issue**

When WXfer_op is not set, the partial-sum k limit is based on the tile partial-sum k step, which represents multiple tiles instead of the actual K dimension length. The correct quantity is the weights-tile w limit.

**Proposed Fix**

Always derive the partial-sum k limit from weights w_step.

---

#### DF_BUGID11 - Partial Sum Y Lim Formula Uses Tile Partial Sum Y Step

- Area: Dataflow Controller
- File(s): sauria_interface.sv

**Issue**

X is the fastest-running tile dimension, so using tile partial-sum y step to compute the Y limit of a single partial-sum tile makes the span larger than intended. Tile partial-sum y step is already a multiple of tile partial-sum x step.

**Proposed Fix**

Replace tile partial-sum y step with tile partial-sum x step in the Y-limit formula.

---

#### DF_BUGID12 - Incorrect Number of Elements Sent Per Weights DMA Read Request

- Area: Dataflow Controller
- File(s): sauria_interface.sv

**Issue**

Each DMA read request for a weights tile should cover the K dimension. The current implementation uses the tile weights k step, which spans C weights tiles instead of one.

**Proposed Fix**

Use weights w_step as the number of elements per weights DMA read request.

---

#### DF_BUGID13 - Incorrect Number of Elements Sent Per Partial Sum DMA Read Request

- Area: Dataflow Controller
- File(s): sauria_interface.sv

**Issue**

Each partial-sum DMA read request should cover one X dimension of a tile. The current implementation uses tile partial-sum x step, which corresponds to an entire partial-sum tile.

**Proposed Fix**

Use the IFMAPS-tile X dimension as the partial-sum tile X dimension.

---

#### DF_BUGID14 - Incorrect Partial Sum DMA Read Request Size When Y Lim = 0

- Area: Dataflow Controller
- File(s): sauria_interface.sv

**Issue**

When Cw_eq is set, the partial-sum intra-tile Y limit becomes zero. If Ch_eq is not set, ett falls back to tile partial-sum y step, which is still larger than a single-tile X span.

**Proposed Fix**

Use the IFMAPS-tile X dimension for the partial-sum request size even when the Y limit is zero.

---

#### DF_BUGID15 - Incorrect Partial Sum DMA Read Request Size When Z Lim = 0

- Area: Dataflow Controller
- File(s): sauria_interface.sv

**Issue**

When both Cw_eq and Ch_eq are set, the partial-sum intra-tile Z limit also becomes zero. In that case, ett becomes tile partial-sum k step, which still reflects multiple larger dimensions instead of a single partial-sum tile.

**Proposed Fix**

Set partial-sum ett to tile partial-sum x step when both Cw_eq and Ch_eq are set.

---

#### DF_BUGID16 - Weights W Lim Incorrectly Set When WXfer_op Is On

- Area: Dataflow Controller
- File(s): sauria_interface.sv

**Issue**

When WXfer_op is set, the intra-tile weights W limit is forced to 1, which gives only two iterations for a full weights tile. If C is greater than 2, the remaining k-wide rows are never read from memory.

**Proposed Fix**

Drop the WXfer_op special case and always derive weights w lim from tile weights c step and weights w step.

---

#### DF_BUGID17 - Flattening Y and K Psums Dimensions Deadlocks FSM

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

When the partial-sum Y and K dimensions are flattened and weights have finished reading, the next step should be to start computation, wait for it to finish, and then write partial sums back to memory. Instead, the DMA controller jumps to a state that waits for another DMA read interrupt even though the next DMA traffic will be writes, not reads.

**Proposed Fix**

Change the next-state condition so it transitions to SAURIA_SYNC and waits for the core to finish the tile computation.

---

#### DF_BUGID18 - Incorrect Tensor Read On Second Iteration When loop_order = 2

- Area: Dataflow Controller
- File(s): sauria_dma_controller.sv

**Issue**

After the first full tile iteration completes, the controller starts reading the next IFMAPS tile. That order is only correct when loop_order is not 2. When loop_order = 2, K is the fastest-moving dimension, so reading IFMAPS again causes an unnecessary reread of the same IFMAPS tile.

**Proposed Fix**

Add a loop_order = 2 condition so the DMA controller prepares to read the next weights tile instead.

---

### DMA Engine Summary

| ID | Area | File(s) | Title |
|---|---|---|---|
| DMA_BUGID1 | DMA Engine | axi_demux.sv | Response Ready Not Propagated For DMA Demux When FIFO Is Empty |
| DMA_BUGID2 | DMA Engine | fifo_v3.sv | Incorrect Demux Selection When FIFO Is Empty |
| DMA_BUGID4 | DMA Engine | data_fifo.sv | Incorrect First Chunk Data Sent To SRAMs |
| DMA_BUGID5 | DMA Engine | aw_engine.sv, w_engine.sv | AW and W Channel Deadlock |

### DMA Engine

#### DMA_BUGID1 - Response Ready Not Propagated For DMA Demux When FIFO Is Empty

- Area: DMA Engine
- File(s): axi_demux.sv

**Issue**

The DMA demux selects whether traffic goes to memory or SRAM interfaces. The response-ready logic between masters and slaves currently depends on the write FIFO being non-empty. If the FIFO is empty, DMA response-ready never asserts and the transaction cannot complete.

**Proposed Fix**

Remove the FIFO-not-empty condition from the master response logic.

---

#### DMA_BUGID2 - Incorrect Demux Selection When FIFO Is Empty

- Area: DMA Engine
- File(s): fifo_v3.sv

**Issue**

When the FIFO is empty, the last stored FIFO value is still used as the demux select. That can route the next interaction to the wrong port, such as memory instead of SRAM, and block subsystem progress.

**Proposed Fix**

Make sure the select logic does not reuse stale FIFO contents once the FIFO is empty.

---

#### DMA_BUGID4 - Incorrect First Chunk Data Sent To SRAMs

- Area: DMA Engine
- File(s): data_fifo.sv

**Issue**

The DMA reads external memory into internal DMA storage and, in the same cycle, reads that internal storage back out to write into SRAM. That means the SRAM side can see old data instead of the newly written chunk.

**Proposed Fix**

Extend the internal DMA memory read path by two cycles so the SRAM write path reads the newly written data. Make the change selectable through a data_fifo parameter so it only applies to the writer FIFO path.

---

#### DMA_BUGID5 - AW and W Channel Deadlock

- Area: DMA Engine
- File(s): aw_engine.sv, w_engine.sv

**Issue**

DMA_BUGID4 also affects the AW and W engine timing because writer-FIFO empty indications are used to generate aw_valid and w_valid pulses. Once the pulse count becomes wrong, the address and write-data channels can deadlock.

**Proposed Fix**

Delay the writer-FIFO empty indication by two cycles in the AW and W engines and set AW_W_SYNC = 1 so both engines stay synchronized.

## Known Configuration Hazards

### Summary

| ID | Area | File(s) | Title |
|---|---|---|---|
| BAD_CONFIG1 | IFMAPS Feeder, Weights Feeder | feed_data_manager.sv | Smaller Than SRAM Width Feeder Address Limit Leads To Deadlock |

#### BAD_CONFIG1 - Smaller Than SRAM Width Feeder Address Limit Leads To Deadlock

- Area: IFMAPS Feeder, Weights Feeder
- File(s): feed_data_manager.sv

**Issue**

The global word offset defines the zeroth byte in a feeder SRAM read access and is combined with the local word offset and dilation pattern to compute the value emitted by each feeder lane. If the IFMAPS combined x/y limit is smaller than SRAMA width, or the weights k limit is smaller than SRAMB width, lane push indications become misaligned.

That can leave some lane FIFOs full while others are not. Since full is asserted if any FIFO is full and pop removes entries from all FIFOs, the design can eventually reach a state where some FIFOs are full while others are empty. At that point, full and empty can assert at the same time and the pipeline deadlocks.

**Current Handling**

No RTL fix is currently proposed. The architecture detects the condition and reports deadlock through a status register. The current workaround is to block the configuration through stimulus constraints.

---


