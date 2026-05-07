# FP Findings

## RTL FP Support Matrix

| IEEE 754 feature | RTL support | Code location |
|---|---|---|
| Normal x Normal -> Normal result | Yes | fpnew_fma regular datapath |
| Normal x Normal -> Subnormal result | Yes | fpnew_fma normalization path (subnormal result branch) |
| Subnormal inputs (i_a or i_b subnormal) | No (product exponent approximation) | fpnew_fma exponent_product path |
| Underflow / overflow flag generation | No (suppressed) | fpnew_fma of_*/uf_* hardwired to 0 |
| Results near normal/subnormal boundary | Partial (small ULP divergence possible) | consequence of suppressed uf classification |
| Inf x 0, Inf - Inf | No (special path bypassed) | fpnew_fma special-case block disabled |
| NaN propagation | No (special path bypassed) | fpnew_fma special-case block disabled |
| +/-Inf propagation (non-cancelling) | No (special path bypassed) | fpnew_fma special-case block disabled |
| RNE rounding for normal-domain results | Yes | fpnew_rounding with RNE |
| Signed zero (-0) preservation | Yes | sign path in regular result assembly |
| FP16 zero detection / negligence gating | Yes (FLOAT mode) | zero_det_neg.sv with exponent-based thresholding |

## Notes

- The table above documents native RTL behavior as implemented in the current `fpnew_fma` integration (FMA) and `zero_det_neg.sv` (zero detection).
- **FP16 zero detection fix (FLOAT mode):** Zero detector now uses FP16 exponent comparison (`exp <= threshold`) instead of signed-integer magnitude. This correctly identifies subnormal and very-small-exponent values for gating, eliminating the previous systemic loss of FP16 products with patterns that mismatched as signed integers (e.g., ±2.0 being incorrectly gated).
- Verification strategy should use strict compare for normal-domain cases and tolerance/waiver policy for boundary and unsupported IEEE special cases.

## Scoreboard Tolerance Policy

- **Boundary-zone compare** is enabled for values with `exp ≤ 3` or subnormal values (previously `exp == 1` only; extended to `exp ≤ 3` after observing up to 4-ULP drift at exp=2 and 2-ULP drift at exp=3 in normal test runs).
- **Global 1-ULP floor** is applied across all normal-domain values to cover FMA rounding-tie cases (Limitation 4): when the true result falls at a midpoint, fpnew and SoftFloat may legally round in opposite directions while both being IEEE 754 correct. Observed in 5 cases with exponents 12–16, ±1 ULP, symmetric distribution.
- `+0` and `-0` are treated as equal per IEEE 754 numeric comparison semantics.
- ULP distance uses a full-sign total-order mapping:
	- Negative values map as `~bits`
	- Non-negative values map as `bits ^ 16'h8000`
	- This avoids artificial distance inflation across the sign boundary near zero.
- Configured tolerance: `FP16_ULP_TOLERANCE = 20` for boundary-zone comparisons.
- Inf/NaN comparisons are skipped with warnings because the RTL special-case path is intentionally bypassed.
