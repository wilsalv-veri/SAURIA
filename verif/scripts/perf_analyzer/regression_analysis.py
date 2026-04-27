from __future__ import annotations

from dataclasses import asdict, dataclass
from pathlib import Path

from perf_analyzer.constants import (
    DF_CH_EQ_BIT,
    DF_CK_EQ_BIT,
    DF_CW_EQ_BIT,
    DF_LOOP_ORDER_LSB,
    DF_LOOP_ORDER_WIDTH,
    DF_START_ADDR,
    PALETTE,
    PSUMS_PRELOAD_EN_BIT,
)
from perf_analyzer.models import PerfRow, TensorSummary
from perf_analyzer.reporting.models import (
    BarValue,
    ChartGroup,
    ChartSegment,
    PresentationChart,
    PresentationPayload,
    PresentationTable,
    SummaryCard,
)

CFG_REG_BASE_ADDR = 0x40000010
DMA_TILE_REG0_ADDR = CFG_REG_BASE_ADDR + 0 * 4
DMA_TILE_REG1_ADDR = CFG_REG_BASE_ADDR + 1 * 4
PSUMS_CFG_REG41_ADDR = CFG_REG_BASE_ADDR + 41 * 4

CONFIG_GROUP_FIELDS = [
    "loop_order",
    "tile_dim_x",
    "tile_dim_y",
    "tile_dim_c",
    "tile_dim_k",
    "num_tiles_x",
    "num_tiles_y",
    "num_tiles_c",
    "num_tiles_k",
    "psums_preload_en",
    "cw_eq",
    "ch_eq",
    "ck_eq",
]


@dataclass(frozen=True)
class RegressionRunConfig:
    loop_order: int | None
    tile_dim_x: int | None
    tile_dim_y: int | None
    tile_dim_c: int | None
    tile_dim_k: int | None
    num_tiles_x: int | None
    num_tiles_y: int | None
    num_tiles_c: int | None
    num_tiles_k: int | None
    psums_preload_en: int | None
    cw_eq: int | None
    ch_eq: int | None
    ck_eq: int | None


def _decode_low16(value: int | None) -> int | None:
    if value is None:
        return None
    return int(value & 0xFFFF)


def _decode_high16(value: int | None) -> int | None:
    if value is None:
        return None
    return int((value >> 16) & 0xFFFF)


def _decode_flag(value: int | None, bit: int) -> int | None:
    if value is None:
        return None
    return int((value >> bit) & 0x1)


def _decode_loop_order(value: int | None) -> int | None:
    if value is None:
        return None
    mask = (1 << DF_LOOP_ORDER_WIDTH) - 1
    return int((value >> DF_LOOP_ORDER_LSB) & mask)


def extract_run_config(rows: list[PerfRow]) -> RegressionRunConfig:
    cfg_values: dict[int, int] = {}

    for row in rows:
        if row.source != "cfg" or row.txn_type != "wr" or row.addr is None or row.data is None:
            continue
        cfg_values[row.addr] = row.data

    reg0 = cfg_values.get(DMA_TILE_REG0_ADDR)
    reg1 = cfg_values.get(DMA_TILE_REG1_ADDR)
    reg21 = cfg_values.get(DF_START_ADDR)
    reg41 = cfg_values.get(PSUMS_CFG_REG41_ADDR)

    tile_x_lim = _decode_low16(reg0)
    tile_y_lim = _decode_high16(reg0)
    tile_c_lim = _decode_low16(reg1)
    tile_k_lim = _decode_high16(reg1)

    # In these CFG regs, tile limits are programmed as N-1 counts.
    num_tiles_x = (tile_x_lim + 1) if tile_x_lim is not None else None
    num_tiles_y = (tile_y_lim + 1) if tile_y_lim is not None else None
    num_tiles_c = (tile_c_lim + 1) if tile_c_lim is not None else None
    num_tiles_k = (tile_k_lim + 1) if tile_k_lim is not None else None

    if num_tiles_x is None:
        num_tiles_x = 1
    if num_tiles_y is None:
        num_tiles_y = 1
    if num_tiles_c is None:
        num_tiles_c = 1
    if num_tiles_k is None:
        num_tiles_k = 1

    preload_en = _decode_flag(reg41, PSUMS_PRELOAD_EN_BIT)
    if preload_en is None:
        preload_en = 0

    return RegressionRunConfig(
        loop_order=_decode_loop_order(reg21),
        tile_dim_x=num_tiles_x,
        tile_dim_y=num_tiles_y,
        tile_dim_c=num_tiles_c,
        tile_dim_k=num_tiles_k,
        num_tiles_x=num_tiles_x,
        num_tiles_y=num_tiles_y,
        num_tiles_c=num_tiles_c,
        num_tiles_k=num_tiles_k,
        psums_preload_en=preload_en,
        cw_eq=_decode_flag(reg21, DF_CW_EQ_BIT),
        ch_eq=_decode_flag(reg21, DF_CH_EQ_BIT),
        ck_eq=_decode_flag(reg21, DF_CK_EQ_BIT),
    )


def build_regression_run_row(
    run_name: str,
    csv_path: Path,
    tensor_summaries: list[TensorSummary],
    run_config: RegressionRunConfig,
) -> dict[str, object]:
    core_cycles = sum(item.core_cycle_counter_sum for item in tensor_summaries)
    core_active = sum(item.core_active_counter_sum for item in tensor_summaries)
    core_stalls = sum(item.core_stall_counter_sum for item in tensor_summaries)

    observed_active = sum(item.observed_unit_active_cycles for item in tensor_summaries)
    observed_idle = sum(item.observed_unit_idle_cycles for item in tensor_summaries)
    observed_stalls = sum(item.observed_stall_only_cycles for item in tensor_summaries)
    observed_total = observed_active + observed_idle + observed_stalls

    subsystem_window = sum(item.subsystem_window_core_eq_cycles for item in tensor_summaries)
    subsystem_df_only = sum(item.subsystem_df_only_cycles_core_eq for item in tensor_summaries)
    subsystem_core_only = sum(item.subsystem_core_only_cycles_core_eq for item in tensor_summaries)
    subsystem_dma_only = sum(item.subsystem_dma_only_cycles_core_eq for item in tensor_summaries)

    return {
        "run_name": run_name,
        "input_csv": str(csv_path),
        **asdict(run_config),
        "tensor_count": len(tensor_summaries),
        "tile_count": sum(item.tile_count for item in tensor_summaries),
        "core_cycles": core_cycles,
        "core_active_cycles": core_active,
        "core_stall_cycles": core_stalls,
        "core_utilization_pct": (100.0 * core_active / core_cycles) if core_cycles else 0.0,
        "observed_active_cycles": observed_active,
        "observed_other_cycles": observed_idle,
        "observed_stall_cycles": observed_stalls,
        "observed_utilization_pct": (100.0 * observed_active / observed_total) if observed_total else 0.0,
        "dma_read_cycles_core_eq": sum(item.dma_read_cycles_core_eq for item in tensor_summaries),
        "dma_write_cycles_core_eq": sum(item.dma_write_cycles_core_eq for item in tensor_summaries),
        "ifmaps_feed_cycles": sum(item.ifmaps_feed_cycles for item in tensor_summaries),
        "weights_feed_cycles": sum(item.weights_feed_cycles for item in tensor_summaries),
        "psums_scan_cycles": sum(item.psums_scan_cycles for item in tensor_summaries),
        "subsystem_window_core_eq_cycles": subsystem_window,
        "subsystem_df_only_core_eq_cycles": subsystem_df_only,
        "subsystem_core_only_core_eq_cycles": subsystem_core_only,
        "subsystem_dma_only_core_eq_cycles": subsystem_dma_only,
    }


def summarize_by_configuration(run_rows: list[dict[str, object]]) -> list[dict[str, object]]:
    if not run_rows:
        return []

    metric_fields = [
        "tensor_count",
        "tile_count",
        "core_cycles",
        "core_active_cycles",
        "core_stall_cycles",
        "core_utilization_pct",
        "observed_active_cycles",
        "observed_other_cycles",
        "observed_stall_cycles",
        "observed_utilization_pct",
        "dma_read_cycles_core_eq",
        "dma_write_cycles_core_eq",
        "ifmaps_feed_cycles",
        "weights_feed_cycles",
        "psums_scan_cycles",
        "subsystem_window_core_eq_cycles",
        "subsystem_df_only_core_eq_cycles",
        "subsystem_core_only_core_eq_cycles",
        "subsystem_dma_only_core_eq_cycles",
    ]

    grouped: dict[tuple[object, ...], dict[str, object]] = {}
    for row in run_rows:
        key = tuple(row[field] for field in CONFIG_GROUP_FIELDS)
        if key not in grouped:
            grouped[key] = {
                "run_count": 0,
                **{field: row[field] for field in CONFIG_GROUP_FIELDS},
                **{f"avg_{metric}": 0.0 for metric in metric_fields},
            }

        group = grouped[key]
        group["run_count"] = int(group["run_count"]) + 1
        for metric in metric_fields:
            group[f"avg_{metric}"] = float(group[f"avg_{metric}"]) + float(row[metric])

    for group in grouped.values():
        run_count = int(group["run_count"])
        for metric in metric_fields:
            group[f"avg_{metric}"] = float(group[f"avg_{metric}"]) / run_count if run_count else 0.0

    return sorted(grouped.values(), key=lambda item: tuple(item[field] for field in CONFIG_GROUP_FIELDS))


def _config_signature(row: dict[str, object]) -> str:
    return (
        f"LO={row.get('loop_order')} "
        f"T=({row.get('tile_dim_x')},{row.get('tile_dim_y')},{row.get('tile_dim_c')},{row.get('tile_dim_k')}) "
        f"N=({row.get('num_tiles_x')},{row.get('num_tiles_y')},{row.get('num_tiles_c')},{row.get('num_tiles_k')}) "
        f"PL={row.get('psums_preload_en')} "
        f"EQ=({row.get('cw_eq')},{row.get('ch_eq')},{row.get('ck_eq')})"
    )


def build_regression_presentation_payload(
    run_rows: list[dict[str, object]],
    grouped_rows: list[dict[str, object]],
) -> PresentationPayload:
    run_count = len(run_rows)
    group_count = len(grouped_rows)
    avg_core_util = (
        sum(float(row["core_utilization_pct"]) for row in run_rows) / run_count if run_count else 0.0
    )
    avg_observed_util = (
        sum(float(row["observed_utilization_pct"]) for row in run_rows) / run_count if run_count else 0.0
    )

    summary_cards = [
        SummaryCard("Regression runs", run_count),
        SummaryCard("Configuration groups", group_count),
        SummaryCard("Average core utilization (%)", avg_core_util),
        SummaryCard("Average observed utilization (%)", avg_observed_util),
    ]

    run_core_util_items = [
        BarValue(str(row["run_name"]), float(row["core_utilization_pct"]))
        for row in run_rows
    ]
    run_observed_util_items = [
        BarValue(str(row["run_name"]), float(row["observed_utilization_pct"]))
        for row in run_rows
    ]

    group_util_groups = [
        ChartGroup(
            _config_signature(group),
            [
                ChartSegment("Core utilization (%)", float(group["avg_core_utilization_pct"]), PALETTE["teal"]),
                ChartSegment(
                    "Observed utilization (%)",
                    float(group["avg_observed_utilization_pct"]),
                    PALETTE["orange"],
                ),
            ],
        )
        for group in grouped_rows
    ]

    charts = [
        PresentationChart(
            title="Per-Run Core Utilization (%)",
            kind="bar",
            items=run_core_util_items,
            x_label="Utilization (%)",
            bar_color=PALETTE["teal"],
        ),
        PresentationChart(
            title="Per-Run Observed Utilization (%)",
            kind="bar",
            items=run_observed_util_items,
            x_label="Utilization (%)",
            bar_color=PALETTE["orange"],
        ),
        PresentationChart(
            title="Configuration Group Utilization Comparison",
            kind="grouped_bar",
            groups=group_util_groups,
            x_label="Utilization (%)",
        ),
    ]

    run_columns = [
        "Run",
        "Config Signature",
        "Loop Order",
        "Tile X",
        "Tile Y",
        "Tile C",
        "Tile K",
        "Num Tiles X",
        "Num Tiles Y",
        "Num Tiles C",
        "Num Tiles K",
        "Preload En",
        "Cw_eq",
        "Ch_eq",
        "Ck_eq",
        "Core Util (%)",
        "Observed Util (%)",
        "DMA Read Core-Eq",
        "DMA Write Core-Eq",
    ]
    run_table_rows = [
        [
            row["run_name"],
            _config_signature(row),
            row["loop_order"],
            row["tile_dim_x"],
            row["tile_dim_y"],
            row["tile_dim_c"],
            row["tile_dim_k"],
            row["num_tiles_x"],
            row["num_tiles_y"],
            row["num_tiles_c"],
            row["num_tiles_k"],
            row["psums_preload_en"],
            row["cw_eq"],
            row["ch_eq"],
            row["ck_eq"],
            f"{float(row['core_utilization_pct']):.2f}",
            f"{float(row['observed_utilization_pct']):.2f}",
            f"{float(row['dma_read_cycles_core_eq']):.2f}",
            f"{float(row['dma_write_cycles_core_eq']):.2f}",
        ]
        for row in run_rows
    ]

    group_columns = [
        "Run Count",
        "Config Signature",
        "Avg Core Util (%)",
        "Avg Observed Util (%)",
        "Avg DMA Read Core-Eq",
        "Avg DMA Write Core-Eq",
        "Avg Core Cycles",
        "Avg Core Active Cycles",
        "Avg Core Stall Cycles",
    ]
    group_table_rows = [
        [
            group["run_count"],
            _config_signature(group),
            f"{float(group['avg_core_utilization_pct']):.2f}",
            f"{float(group['avg_observed_utilization_pct']):.2f}",
            f"{float(group['avg_dma_read_cycles_core_eq']):.2f}",
            f"{float(group['avg_dma_write_cycles_core_eq']):.2f}",
            f"{float(group['avg_core_cycles']):.2f}",
            f"{float(group['avg_core_active_cycles']):.2f}",
            f"{float(group['avg_core_stall_cycles']):.2f}",
        ]
        for group in grouped_rows
    ]

    tables = [
        PresentationTable(
            title="Regression Run Metrics by Configuration",
            columns=run_columns,
            rows=run_table_rows,
        ),
        PresentationTable(
            title="Configuration Group Summary",
            columns=group_columns,
            rows=group_table_rows,
        ),
    ]

    return PresentationPayload(
        summary_cards=summary_cards,
        charts=charts,
        tables=tables,
    )
