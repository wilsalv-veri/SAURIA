from __future__ import annotations

from dataclasses import dataclass


@dataclass
class PerfRow:
    time: int
    source: str
    txn_type: str
    addr: int | None
    data: int | None
    pipeline_en: int | None
    feeder_en: int | None
    act_valid: int | None
    wei_valid: int | None
    pop_en: int | None
    srama_rden: int | None
    sramb_rden: int | None
    fifo_empty: int | None
    fifo_full: int | None
    feeder_stall: int | None
    feeder_active: int | None
    cscan_en: int | None
    sramc_rden: int | None
    sramc_wren: int | None
    context_num: int | None
    cswitch: int | None
    ctx_status: int | None
    feed_status: int | None
    feed_deadlock: int | None
    df_done: int | None
    core_start: int | None
    core_done: int | None
    dma_arvalid: int | None
    dma_rvalid: int | None
    dma_awvalid: int | None
    dma_wvalid: int | None


@dataclass
class TileSummary:
    tensor_id: int
    tile_id: int
    cycle_counter: int
    stall_counter: int
    active_counter: int
    utilization: float
    observed_active_cycles: int
    observed_other_cycles: int
    observed_stall_cycles: int
    observed_utilization: float
    cycle_read_time: int
    stall_read_time: int
    is_outlier: bool


@dataclass
class TensorSummary:
    tensor_id: int
    start_time: int
    end_time: int
    subsystem_end_time: int
    tile_count: int
    valid_tile_count: int
    outlier_tile_count: int
    core_cycle_counter_sum: int
    core_stall_counter_sum: int
    core_active_counter_sum: int
    core_utilization: float
    observed_unit_active_cycles: int
    observed_unit_idle_cycles: int
    observed_stall_only_cycles: int
    observed_utilization: float
    observed_main_controller_cycles: int
    no_tracked_unit_active_cycles: int
    observed_feeders_only_cycles: int
    observed_psums_only_cycles: int
    observed_systolic_only_cycles: int
    observed_feeders_psums_cycles: int
    observed_feeders_systolic_cycles: int
    observed_psums_systolic_cycles: int
    observed_all_units_cycles: int
    ifmaps_feed_cycles: int
    ifmaps_feed_and_sram_cycles: int
    ifmaps_feed_only_cycles: int
    ifmaps_sram_only_cycles: int
    ifmaps_sram_rden_cycles: int
    ifmaps_sram_cycles: int
    ifmaps_stall_cycles: int
    ifmaps_reads_pipe_disabled: int
    ifmaps_reads_fifo_prefill: int
    ifmaps_reads_waiting_for_pop: int
    ifmaps_feed_without_sram: int
    weights_feed_cycles: int
    weights_feed_and_sram_cycles: int
    weights_feed_only_cycles: int
    weights_sram_only_cycles: int
    weights_sram_rden_cycles: int
    weights_sram_cycles: int
    weights_stall_cycles: int
    weights_reads_pipe_disabled: int
    weights_reads_fifo_prefill: int
    weights_reads_waiting_for_pop: int
    weights_feed_without_sram: int
    psums_scan_cycles: int
    psums_scan_with_feeding_cycles: int
    psums_scan_without_feeding_cycles: int
    psums_scan_read_cycles: int
    psums_scan_write_cycles: int
    psums_scan_only_cycles: int
    psums_read_only_cycles: int
    psums_write_only_cycles: int
    psums_sram_read_cycles: int
    psums_sram_write_cycles: int
    psums_sram_access_cycles: int
    systolic_context_switch_cycles: int
    systolic_context_switch_with_feeding_cycles: int
    systolic_context_switch_without_feeding_cycles: int
    systolic_active_cycles: int
    dma_read_cycles_raw: int
    dma_write_cycles_raw: int
    dma_read_cycles_core_eq: float
    dma_write_cycles_core_eq: float
    subsystem_window_core_eq_cycles: float
    subsystem_utilization: float
    subsystem_df_controller_cycles_core_eq: float
    subsystem_core_cycles_core_eq: float
    subsystem_dma_cycles_core_eq: float
    subsystem_df_controller_utilization: float
    subsystem_core_utilization: float
    subsystem_dma_utilization: float
    subsystem_df_only_cycles_core_eq: float
    subsystem_core_only_cycles_core_eq: float
    subsystem_dma_only_cycles_core_eq: float
    subsystem_df_core_overlap_cycles_core_eq: float
    subsystem_df_dma_overlap_cycles_core_eq: float
    subsystem_core_dma_overlap_cycles_core_eq: float
    subsystem_all_units_overlap_cycles_core_eq: float


@dataclass
class DmaBufferMetrics:
    buffer_name: str
    read_cycles_raw: int
    write_cycles_raw: int
    total_cycles_raw: int
    read_cycles_core_eq: float
    write_cycles_core_eq: float
    total_cycles_core_eq: float
    read_transaction_count: int
    unique_read_base_addresses: int
    reused_read_transactions: int
    read_reuse_ratio: float


@dataclass
class FeederInefficiencyMetrics:
    feeder_name: str
    raw_sram_rden_cycles: int
    valid_sram_cycles: int
    feed_cycles: int
    feed_and_sram_cycles: int
    feed_only_cycles: int
    sram_only_cycles: int
    stall_cycles: int
    reads_pipe_disabled: int
    reads_fifo_prefill: int
    reads_waiting_for_pop: int
    feed_without_sram: int


@dataclass
class SubsystemTimeBreakdown:
    end_time: int
    window_core_eq_cycles: float
    utilization: float
    df_controller_cycles_core_eq: float
    core_cycles_core_eq: float
    dma_cycles_core_eq: float
    df_controller_utilization: float
    core_utilization: float
    dma_utilization: float
    df_only_cycles_core_eq: float
    core_only_cycles_core_eq: float
    dma_only_cycles_core_eq: float
    df_core_overlap_cycles_core_eq: float
    df_dma_overlap_cycles_core_eq: float
    core_dma_overlap_cycles_core_eq: float
    all_units_overlap_cycles_core_eq: float