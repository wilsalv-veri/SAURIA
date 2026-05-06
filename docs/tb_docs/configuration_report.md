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

## 4. Configuration Derivation: How a Valid System Configuration Is Arrived At

### 4.1 The Root Parameters and Why They Matter

All configuration values across every CR group ultimately derive from a small set of randomized root parameters that are resolved first by the DMA base sequence. Understanding these roots makes the entire programming model coherent.

The root parameters are:

| Parameter | Source constraint | Meaning |
|---|---|---|
| `rows_multiple` | `[MIN_MULTIPLE..MAX_MULTIPLE]` = `[1..16]` | Scale factor controlling the total `X*Y` spatial window size relative to the array row count |
| `cols_multiple` | `[MIN_MULTIPLE..MAX_MULTIPLE]` = `[1..16]` | Scale factor controlling `K` (output channels) relative to the array column count |
| `X` | Multiple of `sauria_pkg::Y`; `X*Y == sauria_pkg::Y * rows_multiple` | Spatial width of the input tile (must be a whole multiple of the hardware row count to keep row alignment) |
| `Y` | Multiple of `sauria_pkg::Y`; `X*Y == sauria_pkg::Y * rows_multiple` | Spatial height of the input tile |
| `C` | `[MIN_COMP_LEN..MAX_COMP_LEN]` = `[4..32]` | Reduction dimension length (input channels per tile) |
| `K` | `== sauria_pkg::X * cols_multiple` | Output channel dimension; always a whole multiple of the hardware column count |

`MIN_COMP_LEN = 4` reflects a hardware minimum: the inner compute loop requires a nonzero reduction depth, and values below 4 have historically produced edge-case scheduling behavior. The lower bound of 4 is a conservative architectural assumption, not a tightly characterized hardware limit.

`rows_multiple` and `cols_multiple` are solved before their dependent dimensions (`X`, `Y`, `K`) to guarantee the solver explores dimension scales before specific values, producing a more diverse configuration space.

#### Additional constraints on the root parameters

- `X * Y == sauria_pkg::Y * rows_multiple` — the total input spatial window must exactly equal the hardware row count times the chosen row scale. This ensures the systolic array is always covered with a legally aligned input pattern.
- `K == sauria_pkg::X * cols_multiple` — `K` must be an exact multiple of the hardware column count so weight columns map uniformly.
- `K <= (2**(PSUMS_TILE_DIM_SIZE-1)) / (X * Y)` — keeps `K` within the bit-width of partial-sum addressing.
- `(K % sauria_pkg::Y) == 0` — K must be divisible by the hardware row count; this keeps PSUMs row indexing regular.
- `(DATA_AXI_BYTE_NUM % K) == 0` — K must divide evenly into the AXI data bus byte count, keeping DMA burst alignment consistent.

These divisibility requirements are the primary reason dimensions cannot be chosen freely; violating them produces misaligned DMA bursts, irregular loop termination, or unsatisfiable step-limit arithmetic.

---

### 4.2 Single-Tile Baseline Assumption

The base sequence enforces a **single-tile** execution model by constraining:

```
dma_tile_x_lim = dma_tile_y_lim = dma_tile_c_lim = dma_tile_k_lim = 0
```

Setting all tile limit registers to 0 means the tiling loop iterates exactly once in every dimension — there is no outer tile stride. All inter-tile step fields are still computed and programmed, but they are never exercised in this baseline. This assumption allows the single-tile sequence library to be correct without requiring verified multi-tile traversal logic in the testbench.

Multi-tile tests extend the base sequences by overriding one or more tile limit fields to non-zero values, and then the corresponding tile step fields become meaningful.

---

### 4.3 DMA Geometry Derivation Chain

Once the root parameters are resolved, the DMA step/limit fields are computed as a dependency-ordered chain — the SV constraint solver's `solve ... before` directives enforce this order explicitly.

**IFMAPs DMA geometry (constraint `dma_ifmaps_c`)**

```
dma_ifmaps_ett      = X                              // x-span of one IFMAP row transfer
dma_ifmaps_y_lim    = Y - 1                          // row count limit (Y rows, 0-based)
dma_ifmaps_c_lim    = C - 1                          // channel count limit

dma_ifmaps_y_step   = dma_ifmaps_ett                 // stride between IFMAP rows
dma_ifmaps_c_step   = dma_ifmaps_y_step * Y          // stride between channel planes

dma_tile_ifmaps_x_step = ett * Y * C                 // whole-tile IFMAP stride in x
dma_tile_ifmaps_y_step = dma_tile_ifmaps_x_step * (tile_x_lim + 1)
dma_tile_ifmaps_c_step = dma_tile_ifmaps_y_step * (tile_y_lim + 1)
```

`dma_ifmaps_ett` (effective transfer thickness) equals `X` because in GEMM-bypass mode each activation row is `X` elements wide with no convolution padding. This value propagates directly into PSUMs geometry, so any error here has compound effects.

**Weights DMA geometry (constraint `dma_weights_c`)**

```
dma_weights_w_step        = K          // one kernel row spans K output channels
dma_weights_w_lim         = (C-1) * K // address of the last weight element (C reductions * K cols)

dma_tile_weights_c_step   = dma_weights_w_lim + K   // one full weight tile in C dimension
dma_tile_weights_k_step   = dma_tile_weights_c_step * (tile_c_lim + 1)
```

The assumption `dma_weights_w_step = K` reflects the GEMM interpretation: the weight matrix is stored in row-major order where each row has `K` elements.

**PSUMs DMA geometry (constraint `dma_psums_c`)**

```
dma_psums_y_step        = dma_ifmaps_ett   // PSUMs spatial stride mirrors IFMAP x-span
dma_psums_k_step        = dma_psums_y_step * Y

dma_tile_psums_x_step   = dma_psums_k_step * K
dma_tile_psums_y_step   = dma_tile_psums_x_step * (tile_x_lim + 1)
dma_tile_psums_k_step   = dma_tile_psums_y_step * (tile_y_lim + 1)
```

PSUMs spatial stepping reuses the IFMAP spatial geometry because in the GEMM model the output `O[x,y,k]` is indexed over the same `(x,y)` spatial domain as the input `I[x,y,c]`.

---

### 4.4 Core Configuration Derivation — Propagation from DMA Parameters

After the DMA sequence shares the resolved tile dimensions via `computation_params`, the remaining unit sequences derive their CR values without further randomization. This is a deliberate assumption: once DMA geometry is fixed, no other sequence should introduce independent dimensional choices that could break consistency.

**Core IFMAPS feeder (base seq `sauria_axi4_lite_core_ifmaps_cfg_base_seq`)**

The IFMAPS feeder receives the shared `ifmaps_X`, `ifmaps_Y`, `ifmaps_C`, and step fields from `computation_params` and computes:

```
ifmaps_x_step  = SRAMA_N          // fixed to SRAM word width — one bus word per feeder advance
ifmaps_x_lim   = X                // spatial limit in x

ifmaps_y_step  = dma_ifmaps_y_step
ifmaps_y_lim   = ifmaps_y_step * Y   // y limit expressed as a byte offset

ifmaps_ch_step = ifmaps_c_step
ifmaps_ch_lim  = ifmaps_ch_step * C  // channel limit as byte offset

// Single-tile defaults:
ifmaps_tile_x_step = ifmaps_ch_lim
ifmaps_tile_x_lim  = ifmaps_ch_lim
ifmaps_tile_y_step = ifmaps_ch_lim
ifmaps_tile_y_lim  = ifmaps_ch_lim
```

The critical assumption here is `ifmaps_x_step = SRAMA_N`. This fixes the feeder's word advance to the SRAM bus width and is the source of the feeder-step floor constraint stated in Section 4 — the feeder FSM cannot advance by less than one SRAM word.

**Fixed fields by assumption:**
- `ifmaps_rows_active = 0xFF` — all rows in the array are considered live. Deactivating rows is not explored in the baseline, as non-rectangular array utilization requires separate scoreboarding logic.
- `ifmaps_loc_woffs_0..7 = {0,1,2,3,4,5,6,7}` — sequential identity offsets assume no convolution window remapping. This is consistent with GEMM-bypass mode where there is no im2col to perform.
- `dilation_pattern = 0x8000_0000_0000_0000` when `DV_GEMM_BYPASS=1` — this specific bit pattern activates the feeder's bypass path for dilated convolution and requires this exact value in GEMM mode; any other non-zero value would enable partial convolution semantics.

**Core Weights feeder**

```
weights_w_step      = K (from dma_weights_w_step, i.e. the weight row width)
weights_w_lim       = C-total element offset (from dma_weights tile C step)

weights_k_step      = SRAMB_N   if K >= SRAMB_N, else K
                                 // clamped to SRAM bus word width; cannot be smaller
weights_k_lim       = K

// Single-tile defaults:
weights_tile_k_step = weights_w_lim
weights_tile_k_lim  = weights_w_lim
```

`weights_k_step` is clamped at `SRAMB_N` (the weight SRAM bus width) because the hardware feeder advances in SRAM-word increments. Setting `k_step < SRAMB_N` would represent a sub-word stride that the hardware cannot satisfy and would deadlock the feeder. This is the floor constraint for the weights path.

**Fixed fields by assumption:**
- `weights_aligned_flag = 1` — weight data is assumed to be pre-aligned to SRAMB word boundaries in all baseline tests. Unaligned weights require a different DMA burst decomposition and different feeder phasing, which is out of scope for baseline verification.
- `weights_cols_active = 0xFFFF` — all weight columns are assumed active; this is consistent with the full `K` columns being valid for every test.

**Core Main Controller**

```
total_macs  = C                              // inner MAC loop count equals reduction dimension
act_reps    = K / SRAMB_N                    // number of weight SRAM words to load per MAC
weight_reps = (X * Y) / SRAMA_N             // number of activation SRAM words to load per MAC
```

These three values are derived purely from the root parameters; they are not randomized. The assumption is that the main controller always executes exactly one pass through the `C` reduction dimension for the current tile dimensions. Partial reduction scheduling is not exercised in the baseline.

`zero_negligence_threshold = 0` — this optimization field can skip MAC operations when inputs are below threshold; constraining it to zero ensures all MACs execute, maximizing observability and scoreboard determinism.

**Core PSUMs Manager**

```
psums_cx_step = SRAMC_N                      // PSUMs advance by one SRAMC word per step
psums_cx_lim  = psums_CX = X * Y            // total spatial positions in the output tile

psums_ck_step = psums_cx_lim                 // outer PSUMs loop step spans the full CX range
psums_ck_lim  = psums_ck_step * K           // total partial-sum elements for the tile

// Single-tile defaults (all collapse to psums_ck_lim):
psums_tile_cy_step = psums_tile_cy_lim = psums_tile_ck_step = psums_tile_ck_lim = psums_ck_lim

act_reps    = max(K / SRAMB_N, 1)
wei_reps    = max(X*Y / SRAMA_N, 1)
psums_reps  = act_reps * wei_reps
```

`psums_cx_step = SRAMC_N` mirrors the IFMAPS floor: the PSUMs manager also operates in SRAMC bus-word increments. Setting this smaller would violate the hardware's minimum addressable unit.

**Fixed fields by assumption:**
- `psums_preload_en = 0` in the base sequence. Preload controls whether prior partial sums are loaded before a tile's accumulation begins. The base class constrains this to 0; subclasses that test multi-tile accumulation continuity override it to 1.
- `psums_inactive_cols = 0` — all output columns are active, consistent with `K` being a full multiple of the column count.

---

### 4.5 Dataflow Controller Assumptions

The dataflow controller sequence (`sauria_axi4_lite_df_controller_cfg_base_seq`) programs operational mode flags by constraint, not by derivation:

- `stand_alone = 1` — the subsystem executes as a self-contained unit without external handshakes from an upstream processor. This allows verification to fully control execution timing using only AXI4-Lite register writes and status checks.
- `stand_alone_keep_A/B/C = 1` — these flags prevent the dataflow controller from autonomously re-fetching SRAM contents after each tile. In verification, tensor data is pre-loaded by the testbench and must not be overwritten between tile sequences.
- `loop_order = 0` — selects the default dimension traversal order. Alternative loop orders are available in the hardware but not exercised in the baseline, as they alter the sequence in which tile-relative parameters are consumed.
- `Cw_eq / Ch_eq / Ck_eq = 0` — dimension equality shortcuts are disabled. These flags allow the controller to skip re-programming when consecutive tiles share a dimension value. Disabling them ensures the full configuration write sequence executes every time, which is the safest baseline choice.
- `WXfer_op = 0` — disables the alternate weights transfer mode. This field changes how the weights DMA burst is decomposed and is left at the default to keep the DMA geometry straightforward.
- SRAM base addresses are fixed to the package-constant memory map: `SRAMA = 0x7000_0000`, `SRAMB = 0x8000_0000`, `SRAMC = 0x9000_0000`. These correspond to the DMA engine's address routing for the three local SRAMs and must match the physical address map configured in the AXI4 infrastructure.

---

### 4.6 Configuration Flow Summary

The derivation chain can be summarized as a one-way dependency graph:

```
[rows_multiple, cols_multiple]
        │
        ▼
[X, Y, C, K]   ←── DMA base seq randomizes and constrains these
        │
        ▼
DMA step/limit fields (ett, y_step, c_step, tile steps) ── shared via computation_params
        │
        ├──► Core IFMAPS seq: x_step=SRAMA_N, derives lim fields from shared params
        │
        ├──► Core Weights seq: k_step=SRAMB_N (floor), derives w_step/lim from shared params
        │
        ├──► Core Main Controller seq: total_macs=C, act_reps=K/SRAMB_N, weight_reps=X*Y/SRAMA_N
        │
        └──► Core PSUMs seq: cx_step=SRAMC_N, derives cx/ck lim and tile fields
```

No downstream sequence introduces new random variables that are independent of the root parameters. The DMA base sequence's `computation_params.shared` flag acts as a synchronization barrier — all other sequences wait on this flag before deriving their fields.

---

## 5. Practical Legal-Value Rules (Big Picture)

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

## 6. Recommended Programming Order

1. Program DMA controller CRs (`0..17`) to establish movement geometry.
2. Program dataflow controller CRs (`18..21`) for start addresses and mode flags.
3. Program CORE configuration via the **dataflow-mediated path** by writing CRs (`22..41`) for main/IFMAPs/weights/PSUMs behavior.
4. Enable completion interrupt in control/status CRs.
5. Assert `start` in control/status CRs.

This order mirrors the verification sequence library, matches the chosen configuration method for this project, and minimizes inconsistent intermediate states.

---

## 7. Common Misconfiguration Patterns and Effects

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

## 8. Notes on Arithmetic Variant Dependence

Some field packing and active-column handling differ between INT and FP configurations (for example, split fields marked FP-only or INT-only in register definitions). Keep programming consistent with the active arithmetic build-time configuration.

---

## 9. Relationship to Other Artifacts

This document complements:

- Validation strategy and scope in `docs/tb_docs/val_plan.md`
- Environment setup and execution flow in `docs/tb_docs/setup_guide.md`
- Register field definitions in `tb/reg_models/reg_params/sauria_cfg_regs_params.sv`
- Baseline legality constraints in `tb/seqs/base_seqs/*_cfg_base_seq.sv`
- GEMM-bypass knob definition in `configuration/sauria_cfg_pkg.sv` and `configuration/cfg_macros.txt`
