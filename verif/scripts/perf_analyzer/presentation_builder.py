from __future__ import annotations

from perf_analyzer.constants import PALETTE
from perf_analyzer.models import DmaBufferMetrics, TensorSummary, TileSummary
from perf_analyzer.reporting.formatting import format_percent_display, safe_percent
from perf_analyzer.reporting.models import (
    BarValue,
    ChartGroup,
    ChartSegment,
    PresentationChart,
    PresentationPayload,
    PresentationTable,
    SummaryCard,
)


def build_presentation_payload(
    tensor_summaries: list[TensorSummary],
    tile_summaries: list[TileSummary],
    dma_buffer_metrics: dict[str, DmaBufferMetrics],
) -> PresentationPayload:
    total_core_cycles = sum(item.core_cycle_counter_sum for item in tensor_summaries)
    total_stalls = sum(item.core_stall_counter_sum for item in tensor_summaries)
    total_active = sum(item.core_active_counter_sum for item in tensor_summaries)
    total_observed_unit_active = sum(item.observed_unit_active_cycles for item in tensor_summaries)
    total_observed_unit_idle = sum(item.observed_unit_idle_cycles for item in tensor_summaries)
    total_observed_stall_only = sum(item.observed_stall_only_cycles for item in tensor_summaries)
    total_observed_cycles = total_observed_unit_active + total_observed_unit_idle + total_observed_stall_only
    total_dma_reads_core_eq = sum(item.dma_read_cycles_core_eq for item in tensor_summaries)
    total_dma_writes_core_eq = sum(item.dma_write_cycles_core_eq for item in tensor_summaries)
    total_ifmaps_feed = sum(item.ifmaps_feed_cycles for item in tensor_summaries)
    total_ifmaps_feed_and_sram = sum(item.ifmaps_feed_and_sram_cycles for item in tensor_summaries)
    total_ifmaps_feed_only = sum(item.ifmaps_feed_only_cycles for item in tensor_summaries)
    total_ifmaps_sram_only = sum(item.ifmaps_sram_only_cycles for item in tensor_summaries)
    total_ifmaps_sram_rden = sum(item.ifmaps_sram_rden_cycles for item in tensor_summaries)
    total_ifmaps_sram = sum(item.ifmaps_sram_cycles for item in tensor_summaries)
    total_weights_feed = sum(item.weights_feed_cycles for item in tensor_summaries)
    total_weights_feed_and_sram = sum(item.weights_feed_and_sram_cycles for item in tensor_summaries)
    total_weights_feed_only = sum(item.weights_feed_only_cycles for item in tensor_summaries)
    total_weights_sram_only = sum(item.weights_sram_only_cycles for item in tensor_summaries)
    total_weights_sram_rden = sum(item.weights_sram_rden_cycles for item in tensor_summaries)
    total_weights_sram = sum(item.weights_sram_cycles for item in tensor_summaries)
    total_psums_scan = sum(item.psums_scan_cycles for item in tensor_summaries)
    total_psums_scan_with_feeding = sum(item.psums_scan_with_feeding_cycles for item in tensor_summaries)
    total_psums_scan_without_feeding = sum(item.psums_scan_without_feeding_cycles for item in tensor_summaries)
    total_psums_scan_read = sum(item.psums_scan_read_cycles for item in tensor_summaries)
    total_psums_scan_write = sum(item.psums_scan_write_cycles for item in tensor_summaries)
    total_psums_scan_only = sum(item.psums_scan_only_cycles for item in tensor_summaries)
    total_psums_read_only = sum(item.psums_read_only_cycles for item in tensor_summaries)
    total_psums_write_only = sum(item.psums_write_only_cycles for item in tensor_summaries)
    total_psums_sram_read = sum(item.psums_sram_read_cycles for item in tensor_summaries)
    total_psums_sram_write = sum(item.psums_sram_write_cycles for item in tensor_summaries)
    total_context_switch = sum(item.systolic_context_switch_cycles for item in tensor_summaries)
    total_context_switch_with_feeding = sum(
        item.systolic_context_switch_with_feeding_cycles for item in tensor_summaries
    )
    total_context_switch_without_feeding = sum(
        item.systolic_context_switch_without_feeding_cycles for item in tensor_summaries
    )
    total_valid_tiles = sum(item.valid_tile_count for item in tensor_summaries)
    total_outlier_tiles = sum(item.outlier_tile_count for item in tensor_summaries)
    total_ifmaps_reads_pipe_disabled = sum(item.ifmaps_reads_pipe_disabled for item in tensor_summaries)
    total_ifmaps_reads_fifo_prefill = sum(item.ifmaps_reads_fifo_prefill for item in tensor_summaries)
    total_weights_reads_pipe_disabled = sum(item.weights_reads_pipe_disabled for item in tensor_summaries)
    total_weights_reads_fifo_prefill = sum(item.weights_reads_fifo_prefill for item in tensor_summaries)
    total_ifmaps_invalid_reads = total_ifmaps_reads_pipe_disabled + total_ifmaps_reads_fifo_prefill
    total_weights_invalid_reads = total_weights_reads_pipe_disabled + total_weights_reads_fifo_prefill
    total_ifmaps_valid_reads_breakdown = max(total_ifmaps_sram_rden - total_ifmaps_invalid_reads, 0)
    total_weights_valid_reads_breakdown = max(total_weights_sram_rden - total_weights_invalid_reads, 0)

    ifmaps_dma_metrics = dma_buffer_metrics["ifmaps"]
    weights_dma_metrics = dma_buffer_metrics["weights"]
    psums_dma_metrics = dma_buffer_metrics["psums"]

    summary_cards = [
        SummaryCard("Tensor computations", len(tensor_summaries)),
        SummaryCard("Tiles analyzed", len(tile_summaries)),
        SummaryCard("Valid tiles", total_valid_tiles),
        SummaryCard("Outlier tiles", total_outlier_tiles),
        SummaryCard("Core cycles", total_core_cycles),
        SummaryCard("Core stalls", total_stalls),
        SummaryCard("Core utilization", safe_percent(total_active, total_core_cycles)),
        SummaryCard("Observed unit-active cycles", total_observed_unit_active),
        SummaryCard("Observed utilization", safe_percent(total_observed_unit_active, total_observed_cycles)),
    ]

    unit_coverage_items = [
        BarValue("DMA rd window (core-eq)", total_dma_reads_core_eq),
        BarValue("DMA wr window (core-eq)", total_dma_writes_core_eq),
        BarValue("Ifmaps feed", float(total_ifmaps_feed)),
        BarValue("Ifmaps valid SRAM", float(total_ifmaps_sram)),
        BarValue("Weights feed", float(total_weights_feed)),
        BarValue("Weights valid SRAM", float(total_weights_sram)),
        BarValue("Psums scan", float(total_psums_scan)),
        BarValue("Psums scan + feed", float(total_psums_scan_with_feeding)),
        BarValue("Psums scan no feed", float(total_psums_scan_without_feeding)),
        BarValue("Psums SRAM rd", float(total_psums_sram_read)),
        BarValue("Psums SRAM wr", float(total_psums_sram_write)),
        BarValue("Ctx switch", float(total_context_switch)),
        BarValue("Ctx switch + feed", float(total_context_switch_with_feeding)),
        BarValue("Ctx switch no feed", float(total_context_switch_without_feeding)),
    ]

    subsystem_breakdown_groups: list[ChartGroup] = []
    subsystem_share_groups: list[ChartGroup] = []
    tensor_breakdown_groups: list[ChartGroup] = []
    observed_breakdown_groups: list[ChartGroup] = []
    observed_overlap_groups: list[ChartGroup] = []

    for tensor in tensor_summaries:
        subsystem_breakdown_groups.append(
            ChartGroup(
                f"Tensor {tensor.tensor_id}",
                [
                    ChartSegment("DF orchestration only", float(tensor.subsystem_df_only_cycles_core_eq), PALETTE["charcoal"]),
                    ChartSegment("Core tile-active only", float(tensor.subsystem_core_only_cycles_core_eq), PALETTE["teal"]),
                    ChartSegment("DF + Core overlap", float(tensor.subsystem_df_core_overlap_cycles_core_eq), PALETTE["blue"]),
                    ChartSegment("DMA transfer only", float(tensor.subsystem_dma_only_cycles_core_eq), PALETTE["orange"]),
                    ChartSegment("DF + DMA overlap", float(tensor.subsystem_df_dma_overlap_cycles_core_eq), PALETTE["gold"]),
                    ChartSegment("Core + DMA", float(tensor.subsystem_core_dma_overlap_cycles_core_eq), PALETTE["purple"]),
                    ChartSegment("DF + Core + DMA", float(tensor.subsystem_all_units_overlap_cycles_core_eq), PALETTE["red"]),
                ],
            )
        )
        subsystem_share_groups.append(
            ChartGroup(
                f"Tensor {tensor.tensor_id}",
                [
                    ChartSegment("DF orchestration only share", safe_percent(tensor.subsystem_df_only_cycles_core_eq, tensor.subsystem_window_core_eq_cycles), PALETTE["charcoal"]),
                    ChartSegment("Core tile-active only share", safe_percent(tensor.subsystem_core_only_cycles_core_eq, tensor.subsystem_window_core_eq_cycles), PALETTE["teal"]),
                    ChartSegment("DF + Core overlap share", safe_percent(tensor.subsystem_df_core_overlap_cycles_core_eq, tensor.subsystem_window_core_eq_cycles), PALETTE["blue"]),
                    ChartSegment("DMA transfer only share", safe_percent(tensor.subsystem_dma_only_cycles_core_eq, tensor.subsystem_window_core_eq_cycles), PALETTE["orange"]),
                    ChartSegment("DF + DMA overlap share", safe_percent(tensor.subsystem_df_dma_overlap_cycles_core_eq, tensor.subsystem_window_core_eq_cycles), PALETTE["gold"]),
                    ChartSegment("Core + DMA overlap share", safe_percent(tensor.subsystem_core_dma_overlap_cycles_core_eq, tensor.subsystem_window_core_eq_cycles), PALETTE["purple"]),
                    ChartSegment("DF + Core + DMA share", safe_percent(tensor.subsystem_all_units_overlap_cycles_core_eq, tensor.subsystem_window_core_eq_cycles), PALETTE["red"]),
                ],
            )
        )
        tensor_breakdown_groups.append(
            ChartGroup(
                f"Tensor {tensor.tensor_id}",
                [
                    ChartSegment("Core computing", float(tensor.core_active_counter_sum), PALETTE["teal"]),
                    ChartSegment("Core stalls", float(tensor.core_stall_counter_sum), PALETTE["red"]),
                ],
            )
        )
        observed_breakdown_groups.append(
            ChartGroup(
                f"Tensor {tensor.tensor_id}",
                [
                    ChartSegment("Core computing", float(tensor.observed_unit_active_cycles), PALETTE["teal"]),
                    ChartSegment("Other activities", float(tensor.observed_unit_idle_cycles), PALETTE["gold"]),
                    ChartSegment("Stalls", float(tensor.observed_stall_only_cycles), PALETTE["red"]),
                ],
            )
        )
        observed_overlap_groups.append(
            ChartGroup(
                f"Tensor {tensor.tensor_id}",
                [
                    ChartSegment("Feeders only", float(tensor.observed_feeders_only_cycles), PALETTE["green"]),
                    ChartSegment("Psums only", float(tensor.observed_psums_only_cycles), PALETTE["purple"]),
                    ChartSegment("Systolic only", float(tensor.observed_systolic_only_cycles), PALETTE["blue"]),
                    ChartSegment("Feeders + Psums", float(tensor.observed_feeders_psums_cycles), PALETTE["gold"]),
                    ChartSegment("Feeders + Systolic", float(tensor.observed_feeders_systolic_cycles), PALETTE["teal"]),
                    ChartSegment("Psums + Systolic", float(tensor.observed_psums_systolic_cycles), PALETTE["slate"]),
                    ChartSegment("Feeders + Psums + Systolic", float(tensor.observed_all_units_cycles), PALETTE["charcoal"]),
                    ChartSegment("Stalls", float(tensor.observed_stall_only_cycles), PALETTE["red"]),
                    ChartSegment("Main controller", float(tensor.observed_main_controller_cycles), "#8a5cf6"),
                    ChartSegment("No tracked unit active", float(tensor.no_tracked_unit_active_cycles), "#b56576"),
                ],
            )
        )

    tile_utilization_groups = [
        ChartGroup(
            f"T{tile.tile_id}",
            [
                ChartSegment("Status CR", tile.utilization * 100.0, PALETTE["teal"]),
                ChartSegment("Observed", tile.observed_utilization * 100.0, PALETTE["orange"]),
            ],
        )
        for tile in tile_summaries
        if not tile.is_outlier
    ]

    feeder_activity_groups = [
        ChartGroup(
            "Ifmaps feeder",
            [
                ChartSegment("Feed + valid SRAM read", float(total_ifmaps_feed_and_sram), PALETTE["teal"]),
                ChartSegment("Feed only", float(total_ifmaps_feed_only), PALETTE["green"]),
                ChartSegment("Valid SRAM read only", float(total_ifmaps_sram_only), PALETTE["orange"]),
                ChartSegment("Stall", float(sum(item.ifmaps_stall_cycles for item in tensor_summaries)), PALETTE["red"]),
            ],
        ),
        ChartGroup(
            "Weights feeder",
            [
                ChartSegment("Feed + valid SRAM read", float(total_weights_feed_and_sram), PALETTE["teal"]),
                ChartSegment("Feed only", float(total_weights_feed_only), PALETTE["green"]),
                ChartSegment("Valid SRAM read only", float(total_weights_sram_only), PALETTE["orange"]),
                ChartSegment("Stall", float(sum(item.weights_stall_cycles for item in tensor_summaries)), PALETTE["red"]),
            ],
        ),
    ]

    invalid_read_groups = [
        ChartGroup(
            "Ifmaps feeder",
            [
                ChartSegment("Valid SRAM read", float(total_ifmaps_valid_reads_breakdown), PALETTE["teal"]),
                ChartSegment("Read with pipe=0,en=0", float(total_ifmaps_reads_pipe_disabled), PALETTE["red"]),
                ChartSegment("Read with valid=0", float(total_ifmaps_reads_fifo_prefill), PALETTE["gold"]),
            ],
        ),
        ChartGroup(
            "Weights feeder",
            [
                ChartSegment("Valid SRAM read", float(total_weights_valid_reads_breakdown), PALETTE["teal"]),
                ChartSegment("Read with pipe=0,en=0", float(total_weights_reads_pipe_disabled), PALETTE["red"]),
                ChartSegment("Read with valid=0", float(total_weights_reads_fifo_prefill), PALETTE["gold"]),
            ],
        ),
    ]

    charts = [
        PresentationChart(
            title="Subsystem Time Breakdown Shares",
            kind="grouped_bar",
            groups=subsystem_share_groups,
            x_label="Percent",
            value_format="percent",
        ),
        PresentationChart(
            title="Subsystem Time Breakdown",
            kind="stacked_bar",
            groups=subsystem_breakdown_groups,
        ),
        PresentationChart(
            title="Per-Tensor Core Time Breakdown (Status CRs)",
            kind="stacked_bar",
            groups=tensor_breakdown_groups,
        ),
        PresentationChart(
            title="Per-Tensor Observed Compute vs Other/Stall Breakdown",
            kind="stacked_bar",
            groups=observed_breakdown_groups,
        ),
        PresentationChart(
            title="Per-Tensor Observed Unit Activity Breakdown",
            kind="stacked_bar",
            groups=observed_overlap_groups,
        ),
        PresentationChart(
            title="Unit Activity Coverage",
            kind="bar",
            items=unit_coverage_items,
            x_label="Core-clock-equivalent cycles",
            bar_color=PALETTE["charcoal"],
        ),
        PresentationChart(
            title="DMA Buffer Utilization Breakdown",
            kind="stacked_bar",
            groups=[
                ChartGroup(
                    "Ifmaps DMA",
                    [
                        ChartSegment("Read", ifmaps_dma_metrics.read_cycles_core_eq, PALETTE["teal"]),
                        ChartSegment("Write", ifmaps_dma_metrics.write_cycles_core_eq, PALETTE["orange"]),
                    ],
                ),
                ChartGroup(
                    "Weights DMA",
                    [
                        ChartSegment("Read", weights_dma_metrics.read_cycles_core_eq, PALETTE["teal"]),
                        ChartSegment("Write", weights_dma_metrics.write_cycles_core_eq, PALETTE["orange"]),
                    ],
                ),
                ChartGroup(
                    "Psums DMA",
                    [
                        ChartSegment("Read", psums_dma_metrics.read_cycles_core_eq, PALETTE["teal"]),
                        ChartSegment("Write", psums_dma_metrics.write_cycles_core_eq, PALETTE["orange"]),
                    ],
                ),
            ],
        ),
        PresentationChart(
            title="Per-Tile Core Utilization Comparison",
            kind="grouped_bar",
            groups=tile_utilization_groups,
            x_label="Utilization (%)",
        ),
        PresentationChart(
            title="Feeder Activity Breakdown",
            kind="stacked_bar",
            groups=feeder_activity_groups,
        ),
        PresentationChart(
            title="Invalid SRAM Read Breakdown",
            kind="stacked_bar",
            groups=invalid_read_groups,
        ),
        PresentationChart(
            title="Context-Switch Breakdown",
            kind="stacked_bar",
            groups=[
                ChartGroup(
                    "Context switch",
                    [
                        ChartSegment("With active feeding", float(total_context_switch_with_feeding), PALETTE["teal"]),
                        ChartSegment("Without active feeding", float(total_context_switch_without_feeding), PALETTE["orange"]),
                    ],
                )
            ],
        ),
        PresentationChart(
            title="Scan-Chain Breakdown",
            kind="stacked_bar",
            groups=[
                ChartGroup(
                    "Scan chain",
                    [
                        ChartSegment("With active feeding", float(total_psums_scan_with_feeding), PALETTE["teal"]),
                        ChartSegment("Without active feeding", float(total_psums_scan_without_feeding), PALETTE["orange"]),
                    ],
                )
            ],
        ),
        PresentationChart(
            title="Psums Manager Activity Breakdown",
            kind="stacked_bar",
            groups=[
                ChartGroup(
                    "Psums manager",
                    [
                        ChartSegment("Scan + SRAM read", float(total_psums_scan_read), PALETTE["purple"]),
                        ChartSegment("Scan + SRAM write", float(total_psums_scan_write), PALETTE["teal"]),
                        ChartSegment("Scan only", float(total_psums_scan_only), PALETTE["green"]),
                        ChartSegment("SRAM read only", float(total_psums_read_only), PALETTE["gold"]),
                        ChartSegment("SRAM write only", float(total_psums_write_only), PALETTE["orange"]),
                    ],
                )
            ],
        ),
    ]

    tables = [
        PresentationTable(
            title="Invalid SRAM Read Summary",
            columns=[
                "Feeder",
                "Raw SRAM Read-Enable Cycles",
                "Valid SRAM Read Chunk",
                "Total Invalid SRAM Reads",
                "Reads with pipeline_en=0 and feeder_en=0",
                "Reads with pipeline_en=1, feeder_en=1, valid=0",
            ],
            rows=[
                [
                    "Ifmaps feeder",
                    total_ifmaps_sram_rden,
                    total_ifmaps_valid_reads_breakdown,
                    total_ifmaps_invalid_reads,
                    total_ifmaps_reads_pipe_disabled,
                    total_ifmaps_reads_fifo_prefill,
                ],
                [
                    "Weights feeder",
                    total_weights_sram_rden,
                    total_weights_valid_reads_breakdown,
                    total_weights_invalid_reads,
                    total_weights_reads_pipe_disabled,
                    total_weights_reads_fifo_prefill,
                ],
            ],
        ),
        PresentationTable(
            title="Tensor Summary",
            columns=[
                "Tensor",
                "Loop Order",
                "Loop Order Label",
                "Start Time",
                "End Time",
                "Subsystem End Time",
                "Tiles",
                "Valid Tiles",
                "Outlier Tiles",
                "Core Cycles",
                "Core Stalls",
                "Core Computing",
                "Core Utilization",
                "Subsystem Window Core-Eq",
                "Observed Unit-Active Cycles",
                "Observed Other Activity Cycles",
                "Observed Stall Cycles",
                "Observed Utilization",
                "DMA Read Window Cycles Raw",
                "DMA Write Window Cycles Raw",
                "DMA Read Window Cycles Core-Eq",
                "DMA Write Window Cycles Core-Eq",
                "Scan-Chain Cycles",
                "Scan-Chain with Feeding",
                "Scan-Chain without Feeding",
                "Context-Switch Cycles",
                "Context-Switch with Feeding",
                "Context-Switch without Feeding",
            ],
            rows=[
                [
                    tensor.tensor_id,
                    tensor.loop_order if tensor.loop_order is not None else "unknown",
                    tensor.loop_order_label,
                    tensor.start_time,
                    tensor.end_time,
                    tensor.subsystem_end_time,
                    tensor.tile_count,
                    tensor.valid_tile_count,
                    tensor.outlier_tile_count,
                    tensor.core_cycle_counter_sum,
                    tensor.core_stall_counter_sum,
                    tensor.core_active_counter_sum,
                    f"{tensor.core_utilization * 100.0:.2f}%",
                    f"{tensor.subsystem_window_core_eq_cycles:.2f}",
                    tensor.observed_unit_active_cycles,
                    tensor.observed_unit_idle_cycles,
                    tensor.observed_stall_only_cycles,
                    f"{tensor.observed_utilization * 100.0:.2f}%",
                    tensor.dma_read_cycles_raw,
                    tensor.dma_write_cycles_raw,
                    f"{tensor.dma_read_cycles_core_eq:.2f}",
                    f"{tensor.dma_write_cycles_core_eq:.2f}",
                    tensor.psums_scan_cycles,
                    tensor.psums_scan_with_feeding_cycles,
                    tensor.psums_scan_without_feeding_cycles,
                    tensor.systolic_context_switch_cycles,
                    tensor.systolic_context_switch_with_feeding_cycles,
                    tensor.systolic_context_switch_without_feeding_cycles,
                ]
                for tensor in tensor_summaries
            ],
        ),
        PresentationTable(
            title="Subsystem Time Breakdown",
            columns=[
                "Tensor",
                "Start Time",
                "Subsystem End Time",
                "Window Core-Eq",
                "DF Orchestration Only Share",
                "Core Tile-Active Only Share",
                "DF + Core Overlap Share",
                "DMA Transfer Only Share",
                "DF + DMA Overlap Share",
                "Core + DMA Overlap Share",
                "DF + Core + DMA Share",
                "DF Orchestration Only",
                "Core Tile-Active Only",
                "DF + Core Overlap",
                "DMA Transfer Only",
                "DF + DMA Overlap",
                "Core + DMA Overlap",
                "DF + Core + DMA",
            ],
            rows=[
                [
                    tensor.tensor_id,
                    tensor.start_time,
                    tensor.subsystem_end_time,
                    f"{tensor.subsystem_window_core_eq_cycles:.2f}",
                    format_percent_display(safe_percent(tensor.subsystem_df_only_cycles_core_eq, tensor.subsystem_window_core_eq_cycles)),
                    format_percent_display(safe_percent(tensor.subsystem_core_only_cycles_core_eq, tensor.subsystem_window_core_eq_cycles)),
                    format_percent_display(safe_percent(tensor.subsystem_df_core_overlap_cycles_core_eq, tensor.subsystem_window_core_eq_cycles)),
                    format_percent_display(safe_percent(tensor.subsystem_dma_only_cycles_core_eq, tensor.subsystem_window_core_eq_cycles)),
                    format_percent_display(safe_percent(tensor.subsystem_df_dma_overlap_cycles_core_eq, tensor.subsystem_window_core_eq_cycles)),
                    format_percent_display(safe_percent(tensor.subsystem_core_dma_overlap_cycles_core_eq, tensor.subsystem_window_core_eq_cycles)),
                    format_percent_display(safe_percent(tensor.subsystem_all_units_overlap_cycles_core_eq, tensor.subsystem_window_core_eq_cycles)),
                    f"{tensor.subsystem_df_only_cycles_core_eq:.2f}",
                    f"{tensor.subsystem_core_only_cycles_core_eq:.2f}",
                    f"{tensor.subsystem_df_core_overlap_cycles_core_eq:.2f}",
                    f"{tensor.subsystem_dma_only_cycles_core_eq:.2f}",
                    f"{tensor.subsystem_df_dma_overlap_cycles_core_eq:.2f}",
                    f"{tensor.subsystem_core_dma_overlap_cycles_core_eq:.2f}",
                    f"{tensor.subsystem_all_units_overlap_cycles_core_eq:.2f}",
                ]
                for tensor in tensor_summaries
            ],
        ),
        PresentationTable(
            title="Per-Tile Summary",
            columns=[
                "Tensor",
                "Tile",
                "Cycle Counter",
                "Stall Counter",
                "Active Counter",
                "Status CR Utilization",
                "Observed Active Cycles",
                "Observed Other Activity Cycles",
                "Observed Stall Cycles",
                "Observed Utilization",
                "Outlier",
                "Cycle Counter Read Time",
                "Stall Counter Read Time",
            ],
            rows=[
                [
                    tile.tensor_id,
                    tile.tile_id,
                    tile.cycle_counter,
                    tile.stall_counter,
                    tile.active_counter,
                    f"{tile.utilization * 100.0:.2f}%",
                    tile.observed_active_cycles,
                    tile.observed_other_cycles,
                    tile.observed_stall_cycles,
                    f"{tile.observed_utilization * 100.0:.2f}%",
                    "yes" if tile.is_outlier else "no",
                    tile.cycle_read_time,
                    tile.stall_read_time,
                ]
                for tile in tile_summaries
            ],
        ),
        PresentationTable(
            title="DMA Buffer Summary",
            columns=[
                "Buffer",
                "Read Cycles Raw",
                "Write Cycles Raw",
                "Total Cycles Raw",
                "Read Cycles Core-Eq",
                "Write Cycles Core-Eq",
                "Total Cycles Core-Eq",
                "Read DMA Transactions",
                "Unique Read Base Addresses",
                "Reused Read Transactions",
                "Read Reuse Ratio",
            ],
            rows=[
                [
                    metrics.buffer_name,
                    metrics.read_cycles_raw,
                    metrics.write_cycles_raw,
                    metrics.total_cycles_raw,
                    f"{metrics.read_cycles_core_eq:.2f}",
                    f"{metrics.write_cycles_core_eq:.2f}",
                    f"{metrics.total_cycles_core_eq:.2f}",
                    metrics.read_transaction_count,
                    metrics.unique_read_base_addresses,
                    metrics.reused_read_transactions,
                    f"{metrics.read_reuse_ratio:.2f}",
                ]
                for metrics in [ifmaps_dma_metrics, weights_dma_metrics, psums_dma_metrics]
            ],
        ),
    ]

    return PresentationPayload(
        summary_cards=summary_cards,
        charts=charts,
        tables=tables,
    )
