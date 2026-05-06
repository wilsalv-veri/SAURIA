# GEMM Tensor Model Plan

This note defines the shadow generic GEMM layer in standard matrix terms while leaving the current SAURIA DMA address model unchanged.

## Intent

- Keep the existing [tb/golden_models/sauria_dataflow_model.sv](tb/golden_models/sauria_dataflow_model.sv) as the reference SAURIA-specific backend.
- Add a generic GEMM schedule model in `(M,K,N)` terms.
- Delay any scoreboard switch-over until the generic schedule and the current SAURIA backend have been compared in parallel.

## Dimension Mapping

Under GEMM-bypass semantics, the intended matrix mapping is:

- `A = (M,K)`
- `B = (K,N)`
- `C = (M,N)`

Current SAURIA dimensions map to GEMM terms as follows:

- `M` is the flattened spatial output domain: `M = (tile_X * tile_Y) * (psums_X * psums_Y)`
- `K` is the reduction domain: `K = tile_C * ifmap_C`
- `N` is the output-channel domain: `N = tile_K * psums_K`

The SAURIA-specific `X` and `Y` decomposition remains an adapter concern and should not leak into the generic event API.

## Event Boundary

The generic shadow model emits logical tensor-access events rather than addresses.

Each event carries:

- operand: `A`, `B`, or `C`
- access direction: read or write
- tile coordinates in `(M,K,N)` tile space
- transfer indices within the tile
- contiguous span for the implementation-local vector width
- flags for `requires_existing_c` and `final_c_write`

## Next Step

Build a SAURIA adapter that converts the generic GEMM access events into concrete DMA addresses and then compare that adapter against the current tensor_ptr model in shadow mode before changing the scoreboard path.