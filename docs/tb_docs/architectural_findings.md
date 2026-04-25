# Architectural Findings

This document captures architectural issues found during functional verification of the Sauria subsystem.
These findings are kept separate from the main bug report because they describe behavior that breaks the intended GEMM semantics rather than a localized RTL implementation bug.

Scope: this document tracks design-level semantic issues. Localized RTL implementation bugs and known configuration hazards remain in bug_report.md.

## Summary

| ID | Area | File(s) | Title |
|---|---|---|---|
| ARCH_ID1 | IFMAPS Feeders, Weights Feeder | ifmap_idxcnt.sv, wei_idxcnt.sv | Feeders Stream Across Non-Reduction Dimensions |
| ARCH_ID2 | Partial-Sums Manager | psm_idxcnt.sv | Partial-Sums Manager Preloads and Writes Across Incorrect Dimension |

## Sauria Core

#### ARCH_ID1 - Feeders Stream Across Non-Reduction Dimensions

- Area: IFMAPS Feeders, Weights Feeder
- File(s): ifmap_idxcnt.sv, wei_idxcnt.sv

**Issue**

Both feeders count the non-reduction dimension first. That means the SRAM access pattern and the data fed into the array do not line up with the ordering needed for a dot product, so GEMM correctness breaks.

The only case where this does not fail is when the non-reduction dimension matches a single SRAM access and also matches the array column width for IFMAPS and row width for weights. That case is too restrictive and does not match the intended flexibility of the subsystem.

**Proposed Fix**

Update the IFMAPS and weights index counters so the reduction dimension counts first. This keeps the tiling behavior aligned with the intended dataflow and allows broader use of SRAM and array capacity.

---

#### ARCH_ID2 - Partial-Sums Manager Preloads and Writes Across Incorrect Dimension

- Area: Partial-Sums Manager
- File(s): psm_idxcnt.sv

**Issue**

The partial-sums manager preloads and writes one column at a time. Each column therefore keeps the same IFMAPS x and y coordinates while spanning different weights k values. Because of that, the k counter should move fastest, but the current implementation moves x first. That breaks GEMM correctness.

**Proposed Fix**

Change the counter ordering so k moves fastest within a tile, followed by x.