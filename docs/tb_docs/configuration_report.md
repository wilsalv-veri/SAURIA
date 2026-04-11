# SAURIA Systolic Array Accelerator – Configuration Report

---

## 1. Purpose

This document provides a practical configuration guide for SAURIA control registers (CRs), with emphasis on:

- What each major CR group controls
- Which values are legal at an architectural level
- How configuration values affect execution behavior

The goal is to explain the big picture and safe programming model for subsystem bring-up and verification use, without enumerating every individual bit field.

---

## 2. Configuration Model Overview

SAURIA configuration is organized in a staged pipeline:

1. Program DMA/tensor movement geometry
2. Program dataflow controller behavior and tensor base addresses
3. Program core execution units (main controller, IFMAPs feeder, weights feeder, PSUMs manager)
4. Enable completion interrupt (optional but recommended)
5. Start execution

SAURIA supports **two valid methods** to configure the SAURIA CORE units:

1. **Direct CORE programming path**: write AXI4-Lite transactions directly to each CORE CR address space.
2. **Dataflow-mediated CORE programming path**: write to CRs `22..41`, then the dataflow/control path propagates those values into CORE configuration writes.

This report assumes and recommends the second path (dataflow-mediated programming of CRs `22..41`), which is also the path used in the current verification baseline.

In the testbench model, this appears as AXI4-Lite programming of grouped CR ranges:

- DMA controller CRs: `0..17`
- Dataflow controller CRs: `18..21`
- Core main controller CRs: `22..23`
- Core IFMAPs CRs: `24..32`
- Core weights CRs: `33..36`
- Core PSUMs CRs: `37..41`
- Control/status CRs: start + status/interrupt control

### 2.1 GEMM_BYPASS Configuration Knob

The SAURIA dataflow controller and IFMAPs feeder are **convolution-native** by architecture. In verification, this can introduce convolution-specific semantics into address generation and feeder behavior even when the test intent is GEMM-style execution.

To avoid hybrid behavior, verification introduces the `SAURIA_DV_GEMM_BYPASS` knob (exposed through `sauria_cfg_pkg`).

- When enabled, convolution-specific semantics in the dataflow/IFMAP path are bypassed for verification intent.
- With the knob enabled, the subsystem behaves as a **GEMM-native architecture** end to end, rather than a hybrid convolution+GEMM compute approach.
- This keeps configuration semantics and expected data traversal aligned with GEMM-oriented scoreboarding and tiled GEMM reasoning.

In the current verification baseline, this GEMM-bypass mode is intentionally used.

---

## 3. Register Group Summary

### 3.1 DMA Controller CRs (0..17)

**Role**  
Defines tile dimensions and memory strides used by DMA request generation.

**Representative fields**

- Tile limits: `dma_tile_x_lim`, `dma_tile_y_lim`, `dma_tile_c_lim`, `dma_tile_k_lim`
- IFMAPs geometry: `dma_ifmaps_y_lim`, `dma_ifmaps_c_lim`, `dma_ifmaps_y_step`, `dma_ifmaps_c_step`, `dma_ifmaps_ett`
- Weights geometry: `dma_weights_w_step`
- PSUMs geometry: `dma_psums_y_step`, `dma_psums_k_step`
- Tile-wide DMA steps: `dma_tile_ifmaps_*`, `dma_tile_weights_*`, `dma_tile_psums_*`

**Legal-value big picture (verification baseline constraints)**

- `rows_multiple` and `cols_multiple` are constrained to `1..8`
- `C` is constrained to `1..32`
- `K = sauria_pkg::X * cols_multiple`
- `X * Y = sauria_pkg::Y * rows_multiple`
- Single-tile baseline uses:
  - `dma_tile_x_lim = dma_tile_y_lim = dma_tile_c_lim = dma_tile_k_lim = 0`
- Derived step fields must be internally consistent products of dimension terms (not independent random values)

**Behavior impact**

- Incorrect DMA steps/limits create misaligned read/write bursts, data re-use errors, or wrong tile progression.
- `dma_ifmaps_ett` drives the X-span of IFMAP transfers and propagates into PSUMs stepping, so bad values can corrupt both ingest and accumulation paths.

---

### 3.2 Dataflow Controller CRs (18..21)

**Role**  
Defines execution mode flags, SRAM base addresses, and top-level traversal modifiers.

**Representative fields**

- Base addresses: `start_srama_addr`, `start_sramb_addr`, `start_sramc_addr`
- Mode/flags in cfg reg 21: `loop_order`, `stand_alone`, `stand_alone_keep_a/b/c`, `cw_eq`, `ch_eq`, `ck_eq`, `wxfer_op`

**Legal-value big picture (current constrained baseline)**

- `stand_alone = 1`, `stand_alone_keep_a = 1`, `stand_alone_keep_b = 1`, `stand_alone_keep_c = 1`
- `loop_order = 0`
- `cw_eq = 0`, `ch_eq = 0`, `ck_eq = 0`
- `wxfer_op = 0`
- Start addresses set to default memory map:
  - SRAMA: `0x7000_0000`
  - SRAMB: `0x8000_0000`
  - SRAMC: `0x9000_0000`

**Behavior impact**

- Base addresses select source/sink memory regions; invalid alignment or wrong region mapping causes corrupted tensor streams.
- Equality/modifier flags (`cw_eq/ch_eq/ck_eq`) alter effective looping behavior; using them without coherent dimension programming can produce premature loop termination or incomplete tile coverage.
- `wxfer_op` changes weights transfer semantics and is kept disabled in baseline flows to avoid inconsistent read decomposition.

---

### 3.3 Core Main Controller CRs (22..23)

**Role**  
Controls compute repetition counts and top-level MAC looping behavior.

**Representative fields**

- `total_macs`
- `act_reps`
- `weight_reps` (split lower/upper)
- `zero_negligence_threshold`

**Legal-value big picture (baseline)**

- Values are derived from DMA/dataflow shared tile parameters, not programmed arbitrarily.
- `zero_negligence_threshold` is constrained to `0x0` in baseline verification.

**Behavior impact**

- `total_macs`, `act_reps`, and `weight_reps` define how many inner compute rounds execute.
- Undersized repetition fields under-compute; oversized values can overrun expected data windows or stall waiting for unavailable inputs.

---

### 3.4 Core IFMAPs CRs (24..32)

**Role**  
Defines IFMAP tile limits, address/step progression, and local input mapping controls.

**Representative fields**

- Spatial/channel limits and steps: `ifmaps_x_lim`, `ifmaps_y_lim`, `ifmaps_ch_lim`, corresponding `*_step`
- Tile step/limit fields: `ifmaps_tile_x_*`, `ifmaps_tile_y_*`
- Mapping controls: `dilation_pattern`, `ifmaps_rows_active`, `ifmaps_loc_woffs_0..7`

**Legal-value big picture (baseline constraints)**

- `ifmaps_rows_active = 0xFF`
- `ifmaps_loc_woffs_0..7 = 0,1,2,3,4,5,6,7`
- `dilation_pattern`:
  - `0x8000_0000_0000_0000` when `SAURIA_DV_GEMM_BYPASS=1`
  - `0x0` otherwise
- Core IFMAP values are derived from dataflow-side IFMAP tensor parameters and must remain mutually consistent.

**Behavior impact**

- IFMAP step/limit mismatch typically manifests as wrong row/channel sequencing into the array.
- Active-row and offset fields affect how local windows are interpreted; inconsistent offsets can shift data lanes and break MAC alignment.

---

### 3.5 Core Weights CRs (33..36)

**Role**  
Defines weights traversal and feeder alignment behavior.

**Representative fields**

- `weights_w_lim`, `weights_w_step`
- `weights_k_lim`, `weights_k_step`
- `weights_tile_k_lim`, `weights_tile_k_step`
- `weights_cols_active`, `weights_aligned_flag`

**Legal-value big picture (baseline constraints)**

- `weights_aligned_flag = 1`
- `weights_cols_active = 0xFFFF` (effective width depends on arithmetic/config)
- Step/limit fields are derived from dataflow-side weights tile parameters.

**Behavior impact**

- `weights_w_step` and K/tile-K stepping determine how quickly the feeder advances through reduction/output features.
- Misconfiguration usually appears as repeated or skipped weight rows, causing systematic output drift.

---

### 3.6 Core PSUMs CRs (37..41)

**Role**  
Controls accumulation traversal and preload behavior in the partial-sum manager.

**Representative fields**

- `psums_reps`
- `psums_cx_lim/step`, `psums_ck_lim/step`
- `psums_tile_cy_lim/step`, `psums_tile_ck_lim/step`
- `psums_inactive_cols`
- `psums_preload_en`

**Legal-value big picture (baseline constraints)**

- `psums_preload_en = 1`
- `psums_inactive_cols = 0`
- `psums_reps` derived from act/weight repetition factors
- Step/limit fields are computed from dataflow PSUM dimensions and SRAM vectorization constants

**Behavior impact**

- `psums_preload_en` controls whether prior partial sums are loaded for accumulation continuity.
- Incorrect CK/CX/tile stepping can break accumulation continuity across reduction loops, producing under-accumulated or mis-indexed outputs.

---

### 3.7 Control/Status CRs

**Role**  
Provides launch and completion signaling.

**Representative fields used in baseline flow**

- `done_interrupt_en = 1`
- `start = 1`

**Legal-value big picture**

- `start` is a control pulse/bit write to begin execution after configuration is complete.
- `done_interrupt_en` can be `0/1`; baseline enables it.

**Behavior impact**

- Starting before all dependent CR groups are coherent is a common source of hangs or false completion.
- Enabling done interrupt improves deterministic completion handling in testbench-driven runs.

---

## 4. Practical Legal-Value Rules (Big Picture)

For robust configuration, treat the following as mandatory invariants:

1. **Dimension coherence**: IFMAPs, WEIGHTS, and PSUMs dimensions must satisfy shared GEMM/tiled relationships.
2. **Step-limit coherence**: `step` fields must represent address/element increments consistent with corresponding `lim` fields.
3. **Flag coherence**: dataflow modifier flags (`cw_eq/ch_eq/ck_eq/wxfer_op`) should only be enabled with matching dimension formulas.
4. **Address coherence**: SRAM base addresses must match actual mapped regions and expected tensor placement.
5. **Launch order**: program all CR groups first, then assert `start`.
6. **Execution-semantics coherence**: keep `SAURIA_DV_GEMM_BYPASS` aligned with the intended workload model (GEMM-centric verification should run with bypass enabled).
7. **Feeder step floor constraints (must not be undersized)**:
  - In the CORE IFMAPs feeder, the effective `(x*y)` step must be **greater than or equal to SRAMA data width**.
  - In the CORE weights feeder, `k_step` must be **greater than or equal to SRAMB data width**.
  - Using step values smaller than the corresponding SRAM width can deadlock feeder progress; this condition is observable through CORE status flags (for example `ctrl_status_reg_4.status_flags`).

---

## 5. Recommended Programming Order

1. Program DMA controller CRs (`0..17`) to establish movement geometry.
2. Program dataflow controller CRs (`18..21`) for start addresses and mode flags.
3. Program CORE configuration via the **dataflow-mediated path** by writing CRs (`22..41`) for main/IFMAPs/weights/PSUMs behavior.
4. Enable completion interrupt in control/status CRs.
5. Assert `start` in control/status CRs.

This order mirrors the verification sequence library, matches the chosen configuration method for this project, and minimizes inconsistent intermediate states.

---

## 6. Common Misconfiguration Patterns and Effects

- **Mismatch between DMA geometry and core feeder geometry**  
  Causes feeder/compute desynchronization and output corruption.

- **Incorrect repetition counts (`act_reps`, `weight_reps`, `psums_reps`)**  
  Causes incomplete accumulation or extra accumulation iterations.

- **Unsafe modifier-flag combinations (`cw_eq/ch_eq/ck_eq/wxfer_op`)**  
  Can alter loop bounds unexpectedly and skip portions of tensors.

- **Wrong base SRAM addresses**  
  Routes traffic to incorrect tensors or invalid memory ranges.

- **Undersized feeder step programming (invalid configuration)**  
  Setting weights feeder `k_step < SRAMB` data width, or IFMAPs feeder effective `(x*y)` step `< SRAMA` data width, can deadlock feeder FSM progress and is surfaced through CORE status flags (for example `ctrl_status_reg_4.status_flags`).

---

## 7. Notes on Arithmetic Variant Dependence

Some field packing and active-column handling differ between INT and FP configurations (for example, split fields marked FP-only or INT-only in register definitions). Keep programming consistent with the active arithmetic build-time configuration.

---

## 8. Relationship to Other Artifacts

This document complements:

- Validation strategy and scope in `docs/tb_docs/val_plan.md`
- Environment setup and execution flow in `docs/tb_docs/setup_guide.md`
- Register field definitions in `tb/reg_models/reg_params/sauria_cfg_regs_params.sv`
- Baseline legality constraints in `tb/seqs/base_seqs/*_cfg_base_seq.sv`
- GEMM-bypass knob definition in `configuration/sauria_cfg_pkg.sv` and `configuration/cfg_macros.txt`
