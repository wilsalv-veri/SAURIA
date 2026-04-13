# Sauria Systolic Array Accelerator – Verification Environment

UVM-based verification of a multi-unit systolic-array accelerator, targeting correctness of cross-unit dataflow, timing-sensitive execution, and forward progress under realistic workload conditions.

This verification environment uses the original Sauria architecture and RTL strictly as the design under test. All other components of the upstream repository, including any software stack, testing framework, or system-level integration harness, are intentionally excluded.

The goal is to develop a reusable, IP-level verification environment for validating tiled execution behavior and control-driven compute sequencing, while remaining focused on the architectural blocks that define correct operation.

The environment is structured around production-quality UVM practices, including modular agents, targeted stimulus, functional coverage, and assertion-based checking.

The verification architecture is intentionally modular, enabling incremental expansion or integration without structural redesign.

---
## System Characteristics

Sauria is a multi-unit accelerator subsystem composed of independently operating blocks that interact through streaming dataflow and control-driven execution.

Key characteristics include:

- Concurrent execution across DMA, feeders, systolic array, and partial-sum manager
- Backpressure-driven dataflow where stalls in one unit can propagate system-wide
- Independently stalling units where local backpressure can impact global forward progress
- Stateful execution across tiles and reduction dimensions
- Timing-sensitive streaming inputs affecting correctness and forward progress
- Cross-unit dependencies where correct operation emerges from coordinated behavior, not isolated unit correctness

---
## Verification Impact

- Identified and resolved 20+ RTL defects arising from cross-unit interaction, timing misalignment, and control sequencing issues
- Established architectural correctness of tiled execution behavior in the absence of a complete formal specification

---

## Failure Modes Considered

Verification targets system-level failure scenarios and forward-progress violations that arise from cross-unit interaction:

- Deadlock caused by circular backpressure across feeder, array, and partial-sum paths
- Starvation where one or more units fail to make forward progress under specific configurations
- Data corruption due to misaligned streaming or incorrect accumulation ordering
- Loss or overwrite of partial sums across tile boundaries and reduction phases
- Incorrect synchronization between DMA transfers and compute execution leading to invalid inputs or outputs

These failure modes guide stimulus generation, assertion development, and architectural checking throughout the verification effort.

---

## Verification Highlights

Key aspects of the verification effort include:
- Model-driven verification using domain-specific architectural models for control sequencing, dataflow interactions, and array-level execution correctness
- Assertion-based verification of control-path invariants and execution completion guarantees
- Directed and constrained-random stimulus targeting tile geometry, boundary conditions, and control transitions
- Functional coverage tracking tile progression scenarios and execution corner cases
- Full subsystem instantiation enabling validation of cross-unit interactions, backpressure, and system-level execution behavior

---

## Design Feedback and RTL Corrections

The verification environment is used not only to detect defects, but to drive design corrections and validate architectural intent.

For each defect identified:
- Root cause analysis is performed at both RTL and architectural levels
- Corrective fixes are proposed and implemented directly in the RTL
- Fixes are validated through targeted stimulus and full regression to ensure behavioral correctness

This establishes a closed-loop workflow from bug detection to design correction, ensuring that verification directly improves RTL quality.

Representative defects and fixes are documented in the [bug report](docs/tb_docs/bug_report.md).

---
## Verification Strategy

The verification strategy decomposes accelerator execution risk into independent architectural concerns, enabling focused validation while preserving overall correctness.

**Stimulus** generation combines directed and constrained-random sequences targeting specific tile management scenarios, control transitions, and compute behaviors. Configuration transactions describe tensor dimensions, tile geometry, and tiling progression, and are delivered to the dataflow controller to initiate execution.

**Checking** is distributed across domain-specific scoreboards covering tile sequencing, compute-core control behavior, and array-level execution results. Assertion-based checks are used to enforce temporal invariants, control handshakes, and completion conditions.

Where memory interaction is required for stimulus or observability, abstracted interfaces are used to provide deterministic data delivery and visibility, without modeling a full memory subsystem.

**Functional coverage** is intent-driven and used to measure exploration of tile boundaries, configuration combinations, control state transitions, and compute completion scenarios. Coverage is used to guide stimulus refinement rather than as a standalone metric.

External interfaces (AXI4-Lite for configuration and AXI4 for data movement) are implemented using reusable, externally sourced components that are treated as known-good infrastructure. These components are instantiated to enable realistic control and data movement but are not primary targets of verification in this environment.

Architectural intent is inferred from RTL structure and observable behavior. In the absence of a complete standalone specification, verification correctness is established through consistent interpretation of control semantics, tiling behavior, and compute outcomes.

The environment is modular by construction, allowing verification scope to scale through configuration and composition.

For a complete description of validation scope, architectural risks, and completion criteria, see the [Validation Plan](docs/tb_docs/val_plan.md).

---

## Architecture

### Sauria Subsystem
<p align="center">
  <img src="docs/rtl_docs/diagram.svg" width="500" >
</p>

###### Author: Jordi Fornt Mas (jordi.fornt@bsc.es)

### UVM Testbench

![Image of TB Architecture](/docs/tb_docs/Sauria_TB.png)
###### Author: Wilfredo Salvador (wilsalv@gmail.com)

### Control Overview

Sauria is configured, controlled, and exchanges data primarily through AXI-based interfaces. AXI4-Lite is used for configuration and control register access, while AXI4 is used for bulk data movement. These interfaces form the primary mechanism for communication both into the Sauria subsystem and between major architectural blocks within the design.

Sauria is organized around a systolic array compute core controlled through a two-level control hierarchy:

* A **top-level dataflow controller** responsible for tensor-level configuration, tile management, and operation launch
* A **compute-core controller** responsible for sequencing compute phases within the core

At the architectural level, Sauria follows a hybrid model: a convolution-native memory/traversal view managed by the dataflow side, and GEMM-style tiled multiply–accumulate execution in the compute core.

The dataflow controller holds tensor dimensions, tile geometry, and tiling parameters, and generates per-tile metadata that is provided to the DMA engine for loading data into on-chip memories.

The compute-core controller sequences array execution for each tile. Upon completion of the programmed operation, the compute core signals completion back to the dataflow controller.

### Verification Configuration (Instantiated Blocks)

The verification environment instantiates a complete Sauria subsystem, including all RTL blocks that form part of the accelerator architecture. While the full subsystem is present to preserve realistic control and dataflow interactions, verification remains focused on correctness of the accelerator IP rather than system-level integration or external interfaces.

For a detailed explanation of control-register programming, legal configuration values, and behavior impact, see the [Configuration Report](docs/tb_docs/configuration_report.md).

Because the full subsystem is instantiated, verification requires reasoning across control, data movement, and partial-sum flow rather than isolated block-level checking.

At a high level, the instantiated blocks include:

* Top-level dataflow controller
* DMA engine
* Compute core, including:

  * Systolic array
  * Compute-core controller
  * Data feeder
  * Weight fetcher
  * Partial sums manager
  * Local SRAMs and associated local control logic

Blocks listed as out of scope are instantiated but treated as functionally abstracted or assumed-correct components, providing stimulus delivery and observability without being the primary targets of verification.

### Out of Scope Verification

- **DMA Engine and Memory Subsystem**
Verification of the DMA engine implementation, memory hierarchy behavior, and external memory interfaces is excluded. The DMA is treated as a consumer of tile-level metadata generated by the dataflow controller, and as a producer of data visible to the compute core, without attempting to validate memory correctness, performance, or protocol 
behavior.

- **Local SRAMs**
On-chip SRAM structures used for buffering activations, weights, or partial results are excluded from verification. These memories are treated as ideal storage elements without attempting to validate internal memory behavior or arbitration logic.

- **Convolution Lowering**
The IFMAPS feeder performs on-the-fly convolution lowering (e.g., im2col-style transformation) to generate streamed input data for the systolic array. This reflects Sauria's native hybrid approach (convolution-native memory semantics with GEMM-style core compute). Verification of convolution-specific data transformation is excluded. Instead, a verification configuration knob (`SAURIA_DV_GEMM_BYPASS`) bypasses convolution semantics in the dataflow controller/IFMAPS feeder path, treating inputs as pre-lowered and GEMM-compatible.
This enables the verification effort to focus on control sequencing, tile management, and array execution correctness without dependence on convolution data layout behavior.

---

## Execution Mental Model

Although Sauria is natively a hybrid architecture (convolution-native memory/traversal semantics with GEMM-style compute), the verification environment focuses on validating tiled execution behavior under a GEMM-equivalent interpretation.

Conceptually, accelerator execution proceeds as repeated tiled dot-product operations:

$$
I[x,y,c] \times W[c,k] \rightarrow O[x,y,k]
$$

The dataflow controller operates at the tensor-tile level, while the Sauria core executes the per-tile compute sequence once data has been loaded into local storage.

#### Dataflow Controller Execution Sequence

1. Commands the DMA engine to fetch the next activation, weight, and partial-sum tiles from memory and place them into the corresponding local SRAMs.
2. Configures the Sauria core and initiates computation.
3. After computation completes, commands the DMA engine to read the resulting partial-sum tile from SRAMC and write it back to memory.
4. Repeats this process until all tiles have been computed and written back.

#### Sauria Core Execution Sequence

1. Optionally preloads partial sums into the systolic array.
2. Feeds activation and weight tile data from local SRAMs into the array.
3. Performs multiply–accumulate operations across the programmed tile.
4. Collects the updated partial sums and writes them back to SRAM.
5. Repeats this process for each tile until execution completes.

Execution correctness depends on maintaining alignment across these stages under dynamic stall and backpressure conditions.

This execution model drives both stimulus construction and architectural checking within the verification environment.

#### Verification Abstraction of Convolution Semantics

While Sauria is architecturally designed as a hybrid accelerator (convolution-native memory view plus GEMM compute), the verification environment intentionally abstracts execution into a GEMM-equivalent model.

At the architectural level:
- The dataflow controller assumes convolution semantics in memory, including tensor traversal consistent with convolutional workloads
- The IFMAPS feeder performs on-the-fly convolution lowering (im2col-style transformation), converting spatial activation windows into streamed data aligned with the reduction dimension

To decouple verification of control-driven execution from convolution-specific data transformation:

- A minimally intrusive verification knob (`SAURIA_DV_GEMM_BYPASS`) in the dataflow controller and IFMAPS feeder bypasses RTL convolution semantics
- Inputs are treated as pre-lowered, enabling GEMM-compatible execution and verification under a pure GEMM interpretation

With this knob enabled, verification treats the subsystem as GEMM-native end to end, rather than as a hybrid convolution+GEMM execution flow.

This approach allows the verification environment to:
- Focus on correctness of tile sequencing, control orchestration, and accumulation behavior
- Avoid introducing ambiguity from convolution-specific data layout transformations
- Preserve fidelity of the RTL architecture while simplifying verification modeling

As a result, all architectural models, scoreboards, and reference computations operate under GEMM-equivalent semantics, while preserving the underlying RTL architecture and control structure.

#### GEMM Interpretation

![Image of Tiling Mental Model](/docs/tb_docs/tiling_mental_model.png)
###### Author: Wilfredo Salvador (wilsalv@gmail.com)

At a high level, **Sauria execution** can be viewed as tiled GEMM-style accumulation across the reduction dimension.

Industry-standard GEMM

$$
C[m,n] = \sum_{k} A[m,k] \cdot B[k,n]
$$

Tiled GEMM with partial-sum accumulation

$$
C_t[m,n] = C_{t-1}[m,n] + \sum_{k \in \text{tile } t} A_t[m,k] \cdot B_t[k,n]
$$

Sauria-oriented formulation

$$
O_t[x,y,k] = O_{t-1}[x,y,k] + \sum_{c \in \text{tile } t} I_t[x,y,c] \cdot W_t[c,k]
$$

Where:

- $I_t[x,y,c]$: activation tile for reduction tile $t$  
- $W_t[c,k]$: weight tile for reduction tile $t$  
- $O_t[x,y,k]$: accumulated output / partial-sum tile after tile $t$

Mapping to generic GEMM

- $m \leftrightarrow$ flattened spatial position $(x, y)$  
- $n \leftrightarrow$ output-channel dimension $k$  
- $k \leftrightarrow$ reduction dimension $c$

#### Tile Computation

![Image of Tile MAC Compute](/docs/tb_docs/systolic_array_compute.png)
###### Author: Wilfredo Salvador (wilsalv@gmail.com)

---
## Verification Challenges

Verification of systolic-array accelerators is inherently complex due to the architectural properties of the system:

- Correctness depends on coordinated behavior across multiple control and dataflow blocks rather than isolated unit functionality
- Execution proceeds through tiled operations requiring correct sequencing across configuration, spatial, and reduction dimensions
- Independent unit execution introduces backpressure, synchronization, and timing-sensitive interactions
- Stateful execution across tiles and partial-sum accumulation creates dependencies that span multiple execution phases
- Large configuration space increases the likelihood of subtle control and sequencing issues

These characteristics make verification primarily a system-level problem, where correctness emerges from coordinated interaction rather than local behavior.

---
## Repository Structure
- `/pulp-platform` : Externally sourced reusable infrastructure and interface components
- `/RTL`           : Snapshot of Sauria RTL used as the design under test
- `/tb`            : UVM environment, agents, scoreboards, models, and assertion infrastructure
- `/tests`         : Directed and constrained-random tests targeting tiled execution scenarios
- `/docs`          : Architecture diagrams, validation plan, setup guide, and debug findings
- `/output`        : Compilation logs
- `/test_runs`     : Test execution logs

---
## Quick Start

### Pre-Requisites

- Altair DSIM simulator installed
- Valid Altair DSIM license
- Repository submodules initialized

For full setup instructions, see the [Setup and Usage Guide](docs/tb_docs/setup_guide.md).

### Build and Run

1. Source the DSIM environment:
  ```bash
   source /verif/scripts/dsim_env.sh
  ```
2. Compile the RTL, testbench, and DPI library:
  ```bash
   compile_sauria
  ```
3. Run a test:
  ```bash
   run_sauria testname
  ```
   Optional data mode override examples:
  ```bash
   run_sauria testname IFMAPS_DATA_MODE=ALL_TWOS
   run_sauria testname IFMAPS_DATA_MODE=6
  ```
---
## Sauria Repository

This verification environment is based on a fork of the original [Sauria repository](https://github.com/bsc-loca/sauria).
