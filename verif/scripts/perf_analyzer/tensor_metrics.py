from __future__ import annotations

from collections import defaultdict
from statistics import median

from perf_analyzer.constants import (
    CORE_CLOCK_PERIOD_PS,
    START_SRAMA_LOCAL_ADDR,
    START_SRAMA_MEM_ADDR,
    START_SRAMB_LOCAL_ADDR,
    START_SRAMB_MEM_ADDR,
    START_SRAMC_LOCAL_ADDR,
    START_SRAMC_MEM_ADDR,
)
from perf_analyzer.intervals import (
    bool_int,
    build_subsystem_time_breakdown,
    feeder_valid_sram_read,
    get_core_done_times,
    get_core_start_times,
    get_df_done_time,
    get_dma_activity_intervals,
    get_interval_duration_ps,
    get_observed_activity_intervals,
    mark_outlier_tiles,
    pair_core_activity_intervals,
    rows_in_window,
    system_cycles_to_core_cycles,
    time_ps_to_core_cycles,
    time_ps_to_system_cycles,
)
from perf_analyzer.models import (
    DmaBufferMetrics,
    FeederInefficiencyMetrics,
    PerfRow,
    TensorSummary,
    TileSummary,
)


def summarize_feeder_inefficiency(
    rows: list[PerfRow],
    feeder_name: str,
    valid_field: str,
    sram_field: str,
) -> FeederInefficiencyMetrics:
    raw_sram_rden_cycles = 0
    valid_sram_cycles = 0
    feed_cycles = 0
    feed_and_sram_cycles = 0
    feed_only_cycles = 0
    sram_only_cycles = 0
    stall_cycles = 0
    reads_pipe_disabled = 0
    reads_fifo_prefill = 0
    reads_waiting_for_pop = 0
    feed_without_sram = 0

    for row in rows:
        raw_sram_rden = bool(getattr(row, sram_field))
        pipeline_en = bool(row.pipeline_en)
        feeder_en = bool(row.feeder_en)
        valid = bool(getattr(row, valid_field))
        pop_en = bool(row.pop_en)
        fifo_empty = bool(row.fifo_empty)
        feeder_active = bool(row.feeder_active)

        raw_sram_rden_cycles += int(raw_sram_rden)
        valid_sram_read = bool(feeder_valid_sram_read(row, sram_field))
        valid_sram_cycles += int(valid_sram_read)
        feed_cycles += int(feeder_active)
        feed_and_sram_cycles += int(feeder_active and valid_sram_read)
        feed_only_cycles += int(feeder_active and (not valid_sram_read))
        sram_only_cycles += int(valid_sram_read and (not feeder_active))
        stall_cycles += int(bool(row.feeder_stall))
        reads_pipe_disabled += int(raw_sram_rden and (not pipeline_en) and (not feeder_en))
        reads_fifo_prefill += int(raw_sram_rden and pipeline_en and feeder_en and (not valid) and fifo_empty)
        reads_waiting_for_pop += int(raw_sram_rden and pipeline_en and feeder_en and valid and (not pop_en))
        feed_without_sram += int(feeder_active and (not raw_sram_rden))

    return FeederInefficiencyMetrics(
        feeder_name=feeder_name,
        raw_sram_rden_cycles=raw_sram_rden_cycles,
        valid_sram_cycles=valid_sram_cycles,
        feed_cycles=feed_cycles,
        feed_and_sram_cycles=feed_and_sram_cycles,
        feed_only_cycles=feed_only_cycles,
        sram_only_cycles=sram_only_cycles,
        stall_cycles=stall_cycles,
        reads_pipe_disabled=reads_pipe_disabled,
        reads_fifo_prefill=reads_fifo_prefill,
        reads_waiting_for_pop=reads_waiting_for_pop,
        feed_without_sram=feed_without_sram,
    )


def classify_dma_buffer(addr: int | None) -> str | None:
    if addr is None:
        return None

    if (addr & 0xF0000000) == START_SRAMA_MEM_ADDR or (addr & 0xFFFF0000) == START_SRAMA_LOCAL_ADDR:
        return "ifmaps"
    if (addr & 0xF0000000) == START_SRAMB_MEM_ADDR or (addr & 0xFFFF0000) == START_SRAMB_LOCAL_ADDR:
        return "weights"
    if (addr & 0xF0000000) == START_SRAMC_MEM_ADDR or (addr & 0xFFFF0000) == START_SRAMC_LOCAL_ADDR:
        return "psums"
    return None


def summarize_dma_buffer_metrics(dma_rows: list[PerfRow]) -> dict[str, DmaBufferMetrics]:
    counters: dict[str, dict[str, object]] = {
        "ifmaps": {"read": 0, "write": 0, "read_addresses": set(), "read_txn_count": 0},
        "weights": {"read": 0, "write": 0, "read_addresses": set(), "read_txn_count": 0},
        "psums": {"read": 0, "write": 0, "read_addresses": set(), "read_txn_count": 0},
    }
    previous_dma_key: tuple[str, str, int] | None = None

    for row in dma_rows:
        buffer_name = classify_dma_buffer(row.addr)
        if buffer_name is None or row.txn_type not in {"rd", "wr"}:
            continue

        dma_key = (buffer_name, row.txn_type, row.addr if row.addr is not None else -1)
        if row.txn_type == "rd" and dma_key != previous_dma_key:
            counters[buffer_name]["read_txn_count"] = int(counters[buffer_name]["read_txn_count"]) + 1
        previous_dma_key = dma_key

        if row.txn_type == "rd":
            counters[buffer_name]["read"] = int(counters[buffer_name]["read"]) + 1
            if row.addr is not None:
                address_set = counters[buffer_name]["read_addresses"]
                assert isinstance(address_set, set)
                address_set.add(row.addr)
        else:
            counters[buffer_name]["write"] = int(counters[buffer_name]["write"]) + 1

    summary: dict[str, DmaBufferMetrics] = {}
    for buffer_name, values in counters.items():
        read_cycles_raw = int(values["read"])
        write_cycles_raw = int(values["write"])
        total_cycles_raw = read_cycles_raw + write_cycles_raw
        read_transaction_count = int(values["read_txn_count"])
        address_set = values["read_addresses"]
        assert isinstance(address_set, set)
        unique_read_base_addresses = len(address_set)
        reused_read_transactions = max(read_transaction_count - unique_read_base_addresses, 0)
        read_reuse_ratio = (read_transaction_count / unique_read_base_addresses) if unique_read_base_addresses else 0.0

        summary[buffer_name] = DmaBufferMetrics(
            buffer_name=buffer_name,
            read_cycles_raw=read_cycles_raw,
            write_cycles_raw=write_cycles_raw,
            total_cycles_raw=total_cycles_raw,
            read_cycles_core_eq=system_cycles_to_core_cycles(read_cycles_raw),
            write_cycles_core_eq=system_cycles_to_core_cycles(write_cycles_raw),
            total_cycles_core_eq=system_cycles_to_core_cycles(total_cycles_raw),
            read_transaction_count=read_transaction_count,
            unique_read_base_addresses=unique_read_base_addresses,
            reused_read_transactions=reused_read_transactions,
            read_reuse_ratio=read_reuse_ratio,
        )

    return summary


def build_cycle_map(
    rows: list[PerfRow],
    cycle_period_ps: int | None = None,
    anchor_time: int | None = None,
) -> dict[int, dict[str, int]]:
    cycle_map: dict[int, dict[str, int]] = defaultdict(dict)

    for row in rows:
        slot_time = row.time
        if cycle_period_ps is not None and anchor_time is not None and row.time >= anchor_time:
            slot_index = (row.time - anchor_time) // cycle_period_ps
            slot_time = anchor_time + slot_index * cycle_period_ps

        slot = cycle_map[slot_time]
        if row.source == "ifmaps_feeder":
            slot["pipeline_en"] = bool_int(row.pipeline_en)
            slot["act_pop_en"] = bool_int(row.pop_en)
            slot["ifmaps_feeder_active"] = bool_int(row.feeder_active)
            slot["ifmaps_sram"] = bool_int(row.srama_rden)
            slot["ifmaps_valid_sram"] = feeder_valid_sram_read(row, "srama_rden")
            slot["ifmaps_stall"] = bool_int(row.feeder_stall)
        elif row.source == "weights_feeder":
            slot["pipeline_en"] = bool_int(row.pipeline_en)
            slot["wei_pop_en"] = bool_int(row.pop_en)
            slot["weights_feeder_active"] = bool_int(row.feeder_active)
            slot["weights_sram"] = bool_int(row.sramb_rden)
            slot["weights_valid_sram"] = feeder_valid_sram_read(row, "sramb_rden")
            slot["weights_stall"] = bool_int(row.feeder_stall)
        elif row.source == "systolic_array":
            slot["pipeline_en"] = bool_int(row.pipeline_en)
            slot["systolic_compute"] = int(
                bool(row.pipeline_en) and bool(row.act_valid or row.wei_valid)
            )
            slot["systolic_cscan"] = bool_int(row.cscan_en)
            slot["context_switch"] = bool_int(row.cswitch)
        elif row.source == "main_controller":
            slot["pipeline_en"] = bool_int(row.pipeline_en)
            if row.ctx_status is not None:
                slot["main_ctx_status"] = row.ctx_status
            if row.feed_status is not None:
                slot["main_feed_status"] = row.feed_status
            slot["main_feed_deadlock"] = bool_int(row.feed_deadlock)
        elif row.source == "psums_mgr":
            slot["psums_scan"] = bool_int(row.cscan_en)
            slot["psums_rden"] = bool_int(row.sramc_rden)
            slot["psums_wren"] = bool_int(row.sramc_wren)

    return cycle_map


def coalesce_cycle_map(
    cycle_map: dict[int, dict[str, int]],
    merge_gap_ps: int,
) -> dict[int, dict[str, int]]:
    if not cycle_map:
        return {}

    coalesced: dict[int, dict[str, int]] = {}
    cluster_time: int | None = None
    cluster_slot: dict[str, int] = {}
    previous_time: int | None = None

    for cycle_time in sorted(cycle_map):
        if cluster_time is None:
            cluster_time = cycle_time
            cluster_slot = dict(cycle_map[cycle_time])
            previous_time = cycle_time
            continue

        if previous_time is not None and cycle_time - previous_time < merge_gap_ps:
            for key, value in cycle_map[cycle_time].items():
                cluster_slot[key] = max(cluster_slot.get(key, 0), value)
            previous_time = cycle_time
            continue

        coalesced[cluster_time] = cluster_slot
        cluster_time = cycle_time
        cluster_slot = dict(cycle_map[cycle_time])
        previous_time = cycle_time

    assert cluster_time is not None
    coalesced[cluster_time] = cluster_slot
    return coalesced


def is_main_controller_active(slot: dict[str, int]) -> bool:
    ctx_status = slot.get("main_ctx_status")
    feed_status = slot.get("main_feed_status")
    return (
        bool(slot.get("main_feed_deadlock", 0))
        or (ctx_status is not None and ctx_status not in {0, 31})
        or (feed_status is not None and feed_status not in {0, 31})
    )


def get_observed_activity_flags(
    slot: dict[str, int],
) -> tuple[bool, bool, bool, bool, bool, bool, bool, bool, bool]:
    feeder_active = bool(slot.get("ifmaps_feeder_active", 0) or slot.get("weights_feeder_active", 0))
    feeder_operating = bool(
        feeder_active or slot.get("ifmaps_valid_sram", 0) or slot.get("weights_valid_sram", 0)
    )
    context_active = bool(slot.get("context_switch", 0))
    scan_active = bool(slot.get("psums_scan", 0))
    psums_read_active = bool(slot.get("psums_rden", 0))
    psums_write_active = bool(slot.get("psums_wren", 0))
    psums_operating = bool(scan_active or psums_read_active or psums_write_active)
    systolic_operating = bool(
        slot.get("systolic_compute", 0) or slot.get("systolic_cscan", 0) or context_active
    )
    main_controller_active = is_main_controller_active(slot)
    return (
        feeder_active,
        feeder_operating,
        context_active,
        scan_active,
        psums_read_active,
        psums_write_active,
        psums_operating,
        systolic_operating,
        main_controller_active,
    )


def get_observed_compute_flag(slot: dict[str, int]) -> bool:
    return bool(slot.get("ifmaps_feeder_active", 0) or slot.get("weights_feeder_active", 0))


def get_observed_stall_flag(slot: dict[str, int]) -> bool:
    if get_observed_compute_flag(slot):
        return False

    (
        _feeder_active,
        feeder_operating,
        _context_active,
        _scan_active,
        _psums_read_active,
        _psums_write_active,
        psums_operating,
        systolic_operating,
        _main_controller_active,
    ) = get_observed_activity_flags(slot)

    if feeder_operating or psums_operating or systolic_operating:
        return False

    return bool(slot.get("ifmaps_stall", 0) or slot.get("weights_stall", 0))


def get_observed_other_activity_flag(slot: dict[str, int]) -> bool:
    if get_observed_compute_flag(slot):
        return False

    (
        _feeder_active,
        feeder_operating,
        _context_active,
        _scan_active,
        _psums_read_active,
        _psums_write_active,
        psums_operating,
        systolic_operating,
        _main_controller_active,
    ) = get_observed_activity_flags(slot)
    return feeder_operating or psums_operating or systolic_operating


def get_first_compute_active_time(cycle_map: dict[int, dict[str, int]], start_time: int) -> int | None:
    for cycle_time in sorted(cycle_map):
        if cycle_time < start_time:
            continue
        if get_observed_compute_flag(cycle_map[cycle_time]):
            return cycle_time
    return None


def cycle_time_in_intervals(cycle_time: int, intervals: list[tuple[int, int]]) -> bool:
    return any(interval_start <= cycle_time < interval_end for interval_start, interval_end in intervals)


def analyze_tensor(
    tensor_id: int,
    rows: list[PerfRow],
    start_time: int,
    window_end_hint: int,
    tile_templates: list[TileSummary],
    loop_order: int | None,
) -> tuple[TensorSummary, list[TileSummary]]:
    if tile_templates:
        end_time = tile_templates[-1].stall_read_time
    elif rows:
        end_time = rows[-1].time
    else:
        end_time = start_time

    window_rows = rows_in_window(rows, start_time, end_time)
    subsystem_rows = rows_in_window(rows, start_time, window_end_hint)
    cycle_map = build_cycle_map(window_rows, int(CORE_CLOCK_PERIOD_PS), start_time)
    core_start_times = get_core_start_times(subsystem_rows)
    core_done_times = get_core_done_times(subsystem_rows)
    df_done_time = get_df_done_time(subsystem_rows)
    observed_compute_intervals = get_observed_activity_intervals(cycle_map, get_observed_compute_flag)

    tile_summaries: list[TileSummary] = []
    for index, tile in enumerate(tile_templates, start=1):
        tile_summaries.append(
            TileSummary(
                tensor_id=tensor_id,
                tile_id=index,
                cycle_counter=tile.cycle_counter,
                stall_counter=tile.stall_counter,
                active_counter=tile.active_counter,
                utilization=tile.utilization,
                observed_active_cycles=0,
                observed_other_cycles=0,
                observed_stall_cycles=0,
                observed_utilization=0.0,
                cycle_read_time=tile.cycle_read_time,
                stall_read_time=tile.stall_read_time,
                is_outlier=False,
            )
        )

    tile_summaries = mark_outlier_tiles(tile_summaries)
    valid_tile_summaries = [tile for tile in tile_summaries if not tile.is_outlier]

    ifmaps_rows = [row for row in window_rows if row.source == "ifmaps_feeder"]
    weights_rows = [row for row in window_rows if row.source == "weights_feeder"]
    psums_rows = [row for row in window_rows if row.source == "psums_mgr"]

    ifmaps_inefficiency = summarize_feeder_inefficiency(
        ifmaps_rows,
        "ifmaps",
        "act_valid",
        "srama_rden",
    )
    weights_inefficiency = summarize_feeder_inefficiency(
        weights_rows,
        "weights",
        "wei_valid",
        "sramb_rden",
    )

    ifmaps_feed_cycles = ifmaps_inefficiency.feed_cycles
    ifmaps_sram_rden_cycles = ifmaps_inefficiency.raw_sram_rden_cycles
    ifmaps_sram_cycles = ifmaps_inefficiency.valid_sram_cycles
    ifmaps_stall_cycles = ifmaps_inefficiency.stall_cycles

    weights_feed_cycles = weights_inefficiency.feed_cycles
    weights_sram_rden_cycles = weights_inefficiency.raw_sram_rden_cycles
    weights_sram_cycles = weights_inefficiency.valid_sram_cycles
    weights_stall_cycles = weights_inefficiency.stall_cycles

    psums_scan_cycles = sum(bool_int(row.cscan_en) for row in psums_rows)
    psums_scan_with_feeding_cycles = 0
    psums_scan_without_feeding_cycles = 0
    psums_scan_read_cycles = 0
    psums_scan_write_cycles = 0
    psums_scan_only_cycles = 0
    psums_read_only_cycles = 0
    psums_write_only_cycles = 0
    psums_sram_read_cycles = sum(bool_int(row.sramc_rden) for row in psums_rows)
    psums_sram_write_cycles = sum(bool_int(row.sramc_wren) for row in psums_rows)
    psums_sram_access_cycles = sum(
        1 for row in psums_rows if bool_int(row.sramc_rden) or bool_int(row.sramc_wren)
    )

    dma_window_intervals_by_type = {
        "rd": get_dma_activity_intervals(subsystem_rows, ("dma_arvalid", "dma_rvalid")),
        "wr": get_dma_activity_intervals(subsystem_rows, ("dma_awvalid", "dma_wvalid")),
    }
    dma_read_cycles_raw = time_ps_to_system_cycles(
        get_interval_duration_ps(dma_window_intervals_by_type["rd"])
    )
    dma_write_cycles_raw = time_ps_to_system_cycles(
        get_interval_duration_ps(dma_window_intervals_by_type["wr"])
    )
    dma_read_cycles_core_eq = time_ps_to_core_cycles(
        get_interval_duration_ps(dma_window_intervals_by_type["rd"])
    )
    dma_write_cycles_core_eq = time_ps_to_core_cycles(
        get_interval_duration_ps(dma_window_intervals_by_type["wr"])
    )

    systolic_context_switch_cycles = sum(slot.get("context_switch", 0) for slot in cycle_map.values())
    first_compute_active_time = get_first_compute_active_time(cycle_map, start_time)
    observed_core_intervals = pair_core_activity_intervals(
        core_start_times,
        core_done_times,
        tile_summaries,
        observed_compute_intervals,
        start_time,
        first_compute_active_time,
    )
    systolic_context_switch_with_feeding_cycles = 0
    systolic_context_switch_without_feeding_cycles = 0
    systolic_active_cycles = 0
    observed_unit_active_cycles = 0
    observed_unit_idle_cycles = 0
    observed_stall_only_cycles = 0
    observed_main_controller_cycles = 0
    no_tracked_unit_active_cycles = 0
    observed_feeders_only_cycles = 0
    observed_psums_only_cycles = 0
    observed_systolic_only_cycles = 0
    observed_feeders_psums_cycles = 0
    observed_feeders_systolic_cycles = 0
    observed_psums_systolic_cycles = 0
    observed_all_units_cycles = 0
    for cycle_time, slot in cycle_map.items():
        if not cycle_time_in_intervals(cycle_time, observed_core_intervals):
            continue
        (
            feeder_active,
            feeder_operating,
            context_active,
            scan_active,
            psums_read_active,
            psums_write_active,
            psums_operating,
            systolic_operating,
            main_controller_active,
        ) = get_observed_activity_flags(slot)
        if context_active and feeder_active:
            systolic_context_switch_with_feeding_cycles += 1
        elif context_active:
            systolic_context_switch_without_feeding_cycles += 1
        if scan_active and feeder_active:
            psums_scan_with_feeding_cycles += 1
        elif scan_active:
            psums_scan_without_feeding_cycles += 1
        if scan_active and psums_read_active:
            psums_scan_read_cycles += 1
        elif scan_active and psums_write_active:
            psums_scan_write_cycles += 1
        elif scan_active:
            psums_scan_only_cycles += 1
        elif psums_read_active:
            psums_read_only_cycles += 1
        elif psums_write_active:
            psums_write_only_cycles += 1
        compute_active = get_observed_compute_flag(slot)
        stall_only = get_observed_stall_flag(slot)
        other_activity = get_observed_other_activity_flag(slot)
        if compute_active:
            observed_unit_active_cycles += 1
        elif other_activity:
            observed_unit_idle_cycles += 1
        elif stall_only:
            observed_stall_only_cycles += 1

        active_source_count = int(feeder_operating) + int(psums_operating) + int(systolic_operating)
        if active_source_count == 0:
            if main_controller_active:
                observed_main_controller_cycles += 1
            else:
                no_tracked_unit_active_cycles += 1
        else:
            if feeder_operating and not psums_operating and not systolic_operating:
                observed_feeders_only_cycles += 1
            elif psums_operating and not feeder_operating and not systolic_operating:
                observed_psums_only_cycles += 1
            elif systolic_operating and not feeder_operating and not psums_operating:
                observed_systolic_only_cycles += 1
            elif feeder_operating and psums_operating and not systolic_operating:
                observed_feeders_psums_cycles += 1
            elif feeder_operating and systolic_operating and not psums_operating:
                observed_feeders_systolic_cycles += 1
            elif psums_operating and systolic_operating and not feeder_operating:
                observed_psums_systolic_cycles += 1
            elif feeder_operating and psums_operating and systolic_operating:
                observed_all_units_cycles += 1
        if feeder_active or context_active:
            systolic_active_cycles += 1

    observed_total_cycles = (
        observed_unit_active_cycles + observed_unit_idle_cycles + observed_stall_only_cycles
    )
    observed_utilization = (
        observed_unit_active_cycles / observed_total_cycles if observed_total_cycles else 0.0
    )

    for index, tile in enumerate(tile_summaries):
        if index == 0:
            tile_start_time = first_compute_active_time or start_time
        else:
            tile_start_time = tile_summaries[index - 1].stall_read_time + 1
        tile_end_time = tile.stall_read_time
        tile_observed_active = 0
        tile_observed_other = 0
        tile_observed_stall = 0
        for cycle_time, slot in cycle_map.items():
            if cycle_time < tile_start_time or cycle_time > tile_end_time:
                continue
            if get_observed_compute_flag(slot):
                tile_observed_active += 1
            elif get_observed_other_activity_flag(slot):
                tile_observed_other += 1
            elif get_observed_stall_flag(slot):
                tile_observed_stall += 1
        tile.observed_active_cycles = tile_observed_active
        tile.observed_other_cycles = tile_observed_other
        tile.observed_stall_cycles = tile_observed_stall
        observed_total_cycles = tile_observed_active + tile_observed_other + tile_observed_stall
        tile.observed_utilization = (
            tile_observed_active / observed_total_cycles if observed_total_cycles else 0.0
        )

    core_cycle_counter_sum = sum(tile.cycle_counter for tile in valid_tile_summaries)
    core_stall_counter_sum = sum(tile.stall_counter for tile in valid_tile_summaries)
    core_active_counter_sum = sum(tile.active_counter for tile in valid_tile_summaries)
    core_utilization = (
        core_active_counter_sum / core_cycle_counter_sum if core_cycle_counter_sum else 0.0
    )

    subsystem_breakdown = build_subsystem_time_breakdown(
        start_time,
        window_end_hint,
        tile_summaries,
        observed_compute_intervals,
        first_compute_active_time,
        subsystem_rows,
        core_start_times,
        core_done_times,
        df_done_time,
    )

    subsystem_core_utilization = (
        core_active_counter_sum / subsystem_breakdown.core_cycles_core_eq
        if subsystem_breakdown.core_cycles_core_eq
        else 0.0
    )

    tensor_summary = TensorSummary(
        tensor_id=tensor_id,
        loop_order=loop_order,
        loop_order_label=(f"mode_{loop_order}" if loop_order is not None else "unknown"),
        start_time=start_time,
        end_time=end_time,
        subsystem_end_time=subsystem_breakdown.end_time,
        tile_count=len(tile_summaries),
        valid_tile_count=len(valid_tile_summaries),
        outlier_tile_count=len(tile_summaries) - len(valid_tile_summaries),
        core_cycle_counter_sum=core_cycle_counter_sum,
        core_stall_counter_sum=core_stall_counter_sum,
        core_active_counter_sum=core_active_counter_sum,
        core_utilization=core_utilization,
        observed_unit_active_cycles=observed_unit_active_cycles,
        observed_unit_idle_cycles=observed_unit_idle_cycles,
        observed_stall_only_cycles=observed_stall_only_cycles,
        observed_utilization=observed_utilization,
        observed_main_controller_cycles=observed_main_controller_cycles,
        no_tracked_unit_active_cycles=no_tracked_unit_active_cycles,
        observed_feeders_only_cycles=observed_feeders_only_cycles,
        observed_psums_only_cycles=observed_psums_only_cycles,
        observed_systolic_only_cycles=observed_systolic_only_cycles,
        observed_feeders_psums_cycles=observed_feeders_psums_cycles,
        observed_feeders_systolic_cycles=observed_feeders_systolic_cycles,
        observed_psums_systolic_cycles=observed_psums_systolic_cycles,
        observed_all_units_cycles=observed_all_units_cycles,
        ifmaps_feed_cycles=ifmaps_feed_cycles,
        ifmaps_feed_and_sram_cycles=ifmaps_inefficiency.feed_and_sram_cycles,
        ifmaps_feed_only_cycles=ifmaps_inefficiency.feed_only_cycles,
        ifmaps_sram_only_cycles=ifmaps_inefficiency.sram_only_cycles,
        ifmaps_sram_rden_cycles=ifmaps_sram_rden_cycles,
        ifmaps_sram_cycles=ifmaps_sram_cycles,
        ifmaps_stall_cycles=ifmaps_stall_cycles,
        ifmaps_reads_pipe_disabled=ifmaps_inefficiency.reads_pipe_disabled,
        ifmaps_reads_fifo_prefill=ifmaps_inefficiency.reads_fifo_prefill,
        ifmaps_reads_waiting_for_pop=ifmaps_inefficiency.reads_waiting_for_pop,
        ifmaps_feed_without_sram=ifmaps_inefficiency.feed_without_sram,
        weights_feed_cycles=weights_feed_cycles,
        weights_feed_and_sram_cycles=weights_inefficiency.feed_and_sram_cycles,
        weights_feed_only_cycles=weights_inefficiency.feed_only_cycles,
        weights_sram_only_cycles=weights_inefficiency.sram_only_cycles,
        weights_sram_rden_cycles=weights_sram_rden_cycles,
        weights_sram_cycles=weights_sram_cycles,
        weights_stall_cycles=weights_stall_cycles,
        weights_reads_pipe_disabled=weights_inefficiency.reads_pipe_disabled,
        weights_reads_fifo_prefill=weights_inefficiency.reads_fifo_prefill,
        weights_reads_waiting_for_pop=weights_inefficiency.reads_waiting_for_pop,
        weights_feed_without_sram=weights_inefficiency.feed_without_sram,
        psums_scan_cycles=psums_scan_cycles,
        psums_scan_with_feeding_cycles=psums_scan_with_feeding_cycles,
        psums_scan_without_feeding_cycles=psums_scan_without_feeding_cycles,
        psums_scan_read_cycles=psums_scan_read_cycles,
        psums_scan_write_cycles=psums_scan_write_cycles,
        psums_scan_only_cycles=psums_scan_only_cycles,
        psums_read_only_cycles=psums_read_only_cycles,
        psums_write_only_cycles=psums_write_only_cycles,
        psums_sram_read_cycles=psums_sram_read_cycles,
        psums_sram_write_cycles=psums_sram_write_cycles,
        psums_sram_access_cycles=psums_sram_access_cycles,
        systolic_context_switch_cycles=systolic_context_switch_cycles,
        systolic_context_switch_with_feeding_cycles=systolic_context_switch_with_feeding_cycles,
        systolic_context_switch_without_feeding_cycles=systolic_context_switch_without_feeding_cycles,
        systolic_active_cycles=systolic_active_cycles,
        dma_read_cycles_raw=dma_read_cycles_raw,
        dma_write_cycles_raw=dma_write_cycles_raw,
        dma_read_cycles_core_eq=dma_read_cycles_core_eq,
        dma_write_cycles_core_eq=dma_write_cycles_core_eq,
        subsystem_window_core_eq_cycles=subsystem_breakdown.window_core_eq_cycles,
        subsystem_utilization=subsystem_breakdown.utilization,
        subsystem_df_controller_cycles_core_eq=subsystem_breakdown.df_controller_cycles_core_eq,
        subsystem_core_cycles_core_eq=subsystem_breakdown.core_cycles_core_eq,
        subsystem_dma_cycles_core_eq=subsystem_breakdown.dma_cycles_core_eq,
        subsystem_df_controller_utilization=subsystem_breakdown.df_controller_utilization,
        subsystem_core_utilization=subsystem_core_utilization,
        subsystem_dma_utilization=subsystem_breakdown.dma_utilization,
        subsystem_df_only_cycles_core_eq=subsystem_breakdown.df_only_cycles_core_eq,
        subsystem_core_only_cycles_core_eq=subsystem_breakdown.core_only_cycles_core_eq,
        subsystem_dma_only_cycles_core_eq=subsystem_breakdown.dma_only_cycles_core_eq,
        subsystem_df_core_overlap_cycles_core_eq=subsystem_breakdown.df_core_overlap_cycles_core_eq,
        subsystem_df_dma_overlap_cycles_core_eq=subsystem_breakdown.df_dma_overlap_cycles_core_eq,
        subsystem_core_dma_overlap_cycles_core_eq=subsystem_breakdown.core_dma_overlap_cycles_core_eq,
        subsystem_all_units_overlap_cycles_core_eq=subsystem_breakdown.all_units_overlap_cycles_core_eq,
    )

    return tensor_summary, tile_summaries


def infer_source_period(rows: list[PerfRow], source: str) -> int | None:
    times = [row.time for row in rows if row.source == source]
    if len(times) < 2:
        return None
    deltas = [curr - prev for prev, curr in zip(times, times[1:]) if curr > prev]
    if not deltas:
        return None
    return int(median(deltas))