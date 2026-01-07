# SAURIA Systolic Array Accelerator – Validation Plan

---

## 1. Purpose

This document defines the validation plan for the SAURIA systolic array accelerator verification effort. It captures the verification intent, scope boundaries, assumptions, and completion criteria used to guide and evaluate the work.

The purpose of this document is to communicate what is being validated, why those areas matter, and how validation completeness is judged at an architectural level. It is not intended to be a task-tracking or work-management artifact.

---

## 2. Design Under Test Overview

The design under test is the SAURIA systolic array accelerator, a programmable compute engine designed to execute tiled dot-product–based tensor operations. SAURIA is organized around a systolic array compute core, with execution orchestrated through a hierarchical control structure.

At a high level, SAURIA consists of:

- A top-level **dataflow controller** responsible for tensor-level configuration, tile management, and operation launch
- A **compute-core controller** responsible for sequencing compute phases within the core
- A **systolic array datapath** that performs array-level multiply–accumulate operations

SAURIA supports general matrix multiplication (GEMM) and convolutional workloads through control-driven tiling and sequencing. Convolution-specific data transformations (e.g., im2col-style lowering) are performed outside the scope of this validation effort.

The architectural execution model can be summarized as repeated execution of fixed-size compute tiles under control of the dataflow and compute-core controllers, with correctness determined by proper sequencing, completion, and array-visible compute behavior.

Verification focuses on **tile management, control sequencing, and array-level execution correctness**, rather than data transformation or memory subsystem behavior.

---

## 3. Validation Scope

The validation effort targets correctness of **control-driven tiled execution**, with emphasis on behaviors that are architecturally complex, sequencing-sensitive, or prone to silent failure.

### In-Scope Areas

- Tile management and progression driven by the dataflow controller
- Correct sequencing of compute phases within the compute core
- Proper initiation, execution, and completion of array-level compute operations
- Correct handling of tile boundaries and completion signaling
- Control-path interactions between the dataflow controller and compute-core controller
- Array-visible execution behavior (e.g., expected compute results for provided inputs)
- Forward progress and completion guarantees for valid configurations

### Explicitly Out of Scope

The following areas are intentionally excluded to maintain a focused and achievable scope:

- DMA engine implementation, correctness, or performance
- Memory hierarchy behavior or protocol-level correctness
- Data feeder functionality, including convolution lowering or input data transformation
- Weight fetcher behavior and weight buffering semantics
- Partial sums manager behavior outside the systolic array datapath
- Local SRAM internal behavior or arbitration logic
- Performance characterization or power modeling
- Software stack, compiler, or runtime integration

Blocks listed as out of scope may be instantiated to preserve realistic connectivity, but are treated as functionally abstracted or assumed-correct components.

---

## 4. Validation Objectives

The validation objectives are:

- Confirm correct control-driven execution of tiled compute operations
- Validate architectural intent of tile sequencing and compute-core control behavior
- Ensure the systolic array executes the correct operations for a given tile configuration
- Detect corner-case failures related to tile boundaries, control transitions, or completion signaling
- Build confidence in forward progress guarantees, ensuring operations complete correctly under valid configurations

The objective is not exhaustive configuration coverage, but confidence that architecturally meaningful tiled execution scenarios behave as intended.

---

## 5. Key Risk Areas

The following areas are considered high risk and receive focused validation attention:

- Incorrect tile sequencing or progression across multi-tile operations
- Control-state transitions that may lead to deadlock or premature termination
- Mismatches between programmed tile configuration and compute-core execution
- Incorrect handling of tile completion and handshaking between control blocks
- Boundary conditions involving minimal or degenerate tile configurations
- Silent failures where compute appears to complete but produces incorrect array-level results

These risks are informed by the architectural complexity of control-driven execution rather than datapath arithmetic.

---

## 6. Verification Approach

Verification is implemented using a UVM-based functional verification environment designed around architectural observability and controllability.

### Key aspects of the approach include:

**Stimulus**  
Directed and constrained-random sequences generate valid tensor configurations and tile parameters. Configuration transactions are delivered through the AXI4-Lite control interface to program the dataflow controller and initiate execution. Stimulus emphasizes tile geometry variation, control transitions, and compute sequencing scenarios.

**Checking**  
Domain-specific scoreboards track expected tile execution behavior, control sequencing, and array-visible compute results. Checking focuses on validating that each tile executes as intended, completes correctly, and produces expected outputs given the provided inputs. Assertion-based checks enforce control-path invariants, handshakes, and completion conditions.

**Memory and Interface Abstraction**  
Where memory interaction is required for stimulus or observability, abstracted interfaces are used to provide deterministic data delivery and visibility. External interfaces (AXI4-Lite and AXI4) are implemented using reusable, known-good components and are not primary targets of verification.

The environment is modular by construction, allowing incremental expansion or integration without structural redesign.

---

## 7. Coverage Intent

Coverage is used as a qualitative feedback mechanism rather than a sign-off metric.

Coverage intent includes:

- Exercising representative tile configurations and geometries
- Covering tile boundary and completion scenarios
- Observing control-state transitions across execution phases
- Exercising minimal, maximal, and degenerate tile cases
- Stressing forward progress and completion behavior

Coverage results are reviewed alongside functional outcomes to guide stimulus refinement rather than to enforce absolute completeness.

---

## 8. Assumptions and Limitations

This validation effort assumes:

- Configuration and control registers are programmed with architecturally valid values
- Data feeder, weight fetcher, DMA engine, PSUM manager, and local SRAMs behave correctly by construction
- Reset and configuration sequences place the accelerator into a known-good state
- External system components are not required for correctness validation at this level

In the absence of a complete standalone architectural specification, correctness is established through consistent interpretation of control semantics, tiling behavior, and observable compute outcomes.

---

## 9. Completion Criteria

Validation is considered complete when:

- All in-scope architectural behaviors have been exercised with meaningful stimulus and checking
- No known functional correctness bugs remain open within the defined scope
- Identified risk areas have been explicitly addressed through testing or analysis

Completion is judged by demonstrated confidence in control-driven tiled execution correctness, not by absolute coverage percentages.

---

## 10. Relationship to Other Artifacts

This document complements:

- Project README and architectural notes
- Source code and inline documentation
- Bug reports and debug analyses
- Coverage observations and summaries