from __future__ import annotations

from collections import defaultdict
from collections.abc import Callable
from statistics import median

from perf_analyzer.constants import (
    CORE_CLOCK_PERIOD_PS,
    CORE_CYCLE_COUNTER_ADDR,
    DF_LOOP_ORDER_LSB,
    DF_LOOP_ORDER_WIDTH,
    CORE_STALL_COUNTER_ADDR,
    DF_START_ADDR,
    SYSTEM_CLOCK_PERIOD_PS,
)
from perf_analyzer.models import PerfRow, SubsystemTimeBreakdown, TileSummary


def is_df_start_event(row: PerfRow) -> bool:
    return row.source == "cfg" and row.txn_type == "wr" and row.addr == DF_START_ADDR


def decode_df_loop_order(row: PerfRow) -> int | None:
    if row.data is None:
        return None
    mask = (1 << DF_LOOP_ORDER_WIDTH) - 1
    return int((row.data >> DF_LOOP_ORDER_LSB) & mask)


def pair_tile_counters(rows: list[PerfRow]) -> list[TileSummary]:
    tiles: list[TileSummary] = []
    pending_cycle: PerfRow | None = None

    for row in rows:
        if row.source != "cfg" or row.txn_type != "rd" or row.addr is None or row.data is None:
            continue

        if row.addr == CORE_CYCLE_COUNTER_ADDR:
            pending_cycle = row
            continue

        if row.addr == CORE_STALL_COUNTER_ADDR and pending_cycle is not None:
            cycle_counter = pending_cycle.data
            stall_counter = row.data
            active_counter = max(cycle_counter - stall_counter, 0)
            utilization = (active_counter / cycle_counter) if cycle_counter else 0.0
            tiles.append(
                TileSummary(
                    tensor_id=0,
                    tile_id=len(tiles) + 1,
                    cycle_counter=cycle_counter,
                    stall_counter=stall_counter,
                    active_counter=active_counter,
                    utilization=utilization,
                    observed_active_cycles=0,
                    observed_other_cycles=0,
                    observed_stall_cycles=0,
                    observed_utilization=0.0,
                    cycle_read_time=pending_cycle.time,
                    stall_read_time=row.time,
                    is_outlier=False,
                )
            )
            pending_cycle = None

    return tiles


def get_start_times(rows: list[PerfRow]) -> list[int]:
    return [row.time for row in rows if is_df_start_event(row)]


def get_df_start_events(rows: list[PerfRow]) -> list[tuple[int, int | None]]:
    return [
        (row.time, decode_df_loop_order(row))
        for row in rows
        if is_df_start_event(row)
    ]


def get_core_start_times(rows: list[PerfRow]) -> list[int]:
    return get_subsystem_signal_pulse_times(rows, lambda row: row.core_start)


def collapse_asserted_signal_times(times: list[int], merge_gap_ps: int | None = None) -> list[int]:
    if not times:
        return []

    if merge_gap_ps is None:
        positive_deltas = [
            current - previous
            for previous, current in zip(times, times[1:])
            if current > previous
        ]
        sample_period_ps = min(positive_deltas) if positive_deltas else int(SYSTEM_CLOCK_PERIOD_PS)
        merge_gap_ps = max(sample_period_ps * 2, int(SYSTEM_CLOCK_PERIOD_PS))

    collapsed = [times[0]]
    previous_time = times[0]
    for current_time in times[1:]:
        if current_time - previous_time > merge_gap_ps:
            collapsed.append(current_time)
        previous_time = current_time
    return collapsed


def get_subsystem_signal_pulse_times(
    rows: list[PerfRow],
    field_getter: Callable[[PerfRow], int | None],
) -> list[int]:
    raw_times = [row.time for row in rows if row.source == "subsystem" and bool(field_getter(row))]
    return collapse_asserted_signal_times(raw_times)


def build_sampled_activity_intervals(
    active_times: list[int],
    default_period_ps: int,
) -> list[tuple[int, int]]:
    if not active_times:
        return []

    positive_deltas = [
        current - previous
        for previous, current in zip(active_times, active_times[1:])
        if current > previous
    ]
    sample_period_ps = min(positive_deltas) if positive_deltas else default_period_ps

    intervals: list[tuple[int, int]] = []
    interval_start = active_times[0]
    previous_time = active_times[0]
    for current_time in active_times[1:]:
        if current_time - previous_time > sample_period_ps:
            intervals.append((interval_start, previous_time + sample_period_ps))
            interval_start = current_time
        previous_time = current_time

    intervals.append((interval_start, previous_time + sample_period_ps))
    return merge_intervals(intervals)


def get_dma_activity_intervals(
    rows: list[PerfRow],
    fields: tuple[str, ...],
) -> list[tuple[int, int]]:
    active_times = [
        row.time
        for row in rows
        if row.source == "dma_status"
        and any(bool(getattr(row, field)) for field in fields)
    ]
    return build_sampled_activity_intervals(active_times, int(round(SYSTEM_CLOCK_PERIOD_PS)))


def get_df_done_time(rows: list[PerfRow]) -> int | None:
    done_times = get_subsystem_signal_pulse_times(rows, lambda row: row.df_done)
    if not done_times:
        return None
    return max(done_times)


def get_core_done_times(rows: list[PerfRow]) -> list[int]:
    return get_subsystem_signal_pulse_times(rows, lambda row: row.core_done)


def build_core_activity_intervals_from_events(
    core_start_times: list[int],
    core_done_times: list[int],
) -> list[tuple[int, int]]:
    if not core_start_times or not core_done_times:
        return []
    if len(core_start_times) != len(core_done_times):
        return []

    core_intervals: list[tuple[int, int]] = []
    for core_start_time, core_done_time in zip(core_start_times, core_done_times):
        if core_done_time < core_start_time:
            return []
        interval_end = core_done_time
        if interval_end <= core_start_time:
            return []
        core_intervals.append((core_start_time, interval_end))

    return merge_intervals(core_intervals)


def get_observed_activity_intervals(
    cycle_map: dict[int, dict[str, int]],
    predicate: Callable[[dict[str, int]], bool],
) -> list[tuple[int, int]]:
    if not cycle_map:
        return []

    sample_times = sorted(cycle_map)
    sample_deltas = [
        current - previous
        for previous, current in zip(sample_times, sample_times[1:])
        if current > previous
    ]
    sample_period_ps = min(sample_deltas) if sample_deltas else int(CORE_CLOCK_PERIOD_PS)

    intervals: list[tuple[int, int]] = []
    interval_start: int | None = None
    previous_active_time: int | None = None
    for cycle_time in sample_times:
        if predicate(cycle_map[cycle_time]):
            if interval_start is None:
                interval_start = cycle_time
            elif previous_active_time is not None and cycle_time - previous_active_time > sample_period_ps:
                intervals.append((interval_start, previous_active_time + sample_period_ps))
                interval_start = cycle_time
            previous_active_time = cycle_time
            continue

        if interval_start is not None and previous_active_time is not None:
            intervals.append((interval_start, previous_active_time + sample_period_ps))
        interval_start = None
        previous_active_time = None

    if interval_start is not None and previous_active_time is not None:
        intervals.append((interval_start, previous_active_time + sample_period_ps))

    return merge_intervals(intervals)


def pair_core_activity_intervals(
    core_start_times: list[int],
    core_done_times: list[int],
    tile_summaries: list[TileSummary],
    observed_compute_intervals: list[tuple[int, int]],
    start_time: int,
    first_compute_active_time: int | None,
) -> list[tuple[int, int]]:
    event_intervals = build_core_activity_intervals_from_events(core_start_times, core_done_times)
    if event_intervals:
        return event_intervals

    core_intervals: list[tuple[int, int]] = []

    for index, tile in enumerate(tile_summaries):
        if index < len(core_start_times):
            tile_start_time = core_start_times[index]
        elif index == 0:
            tile_start_time = first_compute_active_time or start_time
        else:
            previous_tile = tile_summaries[index - 1]
            tile_start_time = core_intervals[-1][1] if core_intervals else (
                previous_tile.stall_read_time + 1
            )
        tile_end_time = tile_start_time + int(tile.cycle_counter * CORE_CLOCK_PERIOD_PS)
        if tile_end_time > tile_start_time:
            core_intervals.append((tile_start_time, tile_end_time))

    if core_intervals:
        return core_intervals

    return merge_intervals(observed_compute_intervals)


def rows_in_window(rows: list[PerfRow], start_time: int, end_time: int) -> list[PerfRow]:
    return [row for row in rows if start_time <= row.time <= end_time]


def get_tensor_windows(
    rows: list[PerfRow],
    tiles: list[TileSummary],
) -> list[tuple[int, int, int, list[TileSummary], int | None]]:
    if not rows:
        return []

    start_events = get_df_start_events(rows)
    if not start_events:
        start_events = [(rows[0].time, None)]

    windows: list[tuple[int, int, int, list[TileSummary], int | None]] = []
    last_time = rows[-1].time

    for index, (start_time, loop_order) in enumerate(start_events):
        next_start = start_events[index + 1][0] if index + 1 < len(start_events) else None
        window_tiles = [
            tile
            for tile in tiles
            if tile.stall_read_time >= start_time
            and (next_start is None or tile.stall_read_time < next_start)
        ]

        if window_tiles:
            end_time = window_tiles[-1].stall_read_time
        elif next_start is not None:
            end_time = next_start - 1
        else:
            end_time = last_time

        search_end_time = (next_start - 1) if next_start is not None else last_time
        windows.append((index + 1, start_time, search_end_time, window_tiles, loop_order))
        if next_start is None:
            break

    return windows


def bool_int(value: int | None) -> int:
    return 1 if value else 0


def feeder_valid_sram_read(row: PerfRow, sram_field: str) -> int:
    if sram_field == "srama_rden":
        valid = bool(row.act_valid)
    elif sram_field == "sramb_rden":
        valid = bool(row.wei_valid)
    else:
        valid = False

    return int(bool(getattr(row, sram_field)) and bool(row.feeder_en) and valid)


def system_cycles_to_core_cycles(system_cycles: int | float) -> float:
    return float(system_cycles) * (SYSTEM_CLOCK_PERIOD_PS / CORE_CLOCK_PERIOD_PS)


def time_ps_to_core_cycles(duration_ps: int | float) -> float:
    return float(duration_ps) / CORE_CLOCK_PERIOD_PS


def time_ps_to_system_cycles(duration_ps: int | float) -> int:
    return int(round(float(duration_ps) / SYSTEM_CLOCK_PERIOD_PS))


def merge_intervals(intervals: list[tuple[int, int]]) -> list[tuple[int, int]]:
    if not intervals:
        return []

    merged: list[tuple[int, int]] = []
    for start, end in sorted(intervals):
        if end <= start:
            continue
        if not merged or start > merged[-1][1]:
            merged.append((start, end))
            continue
        merged[-1] = (merged[-1][0], max(merged[-1][1], end))
    return merged


def clip_intervals(
    intervals: list[tuple[int, int]],
    start_time: int,
    end_time: int,
) -> list[tuple[int, int]]:
    clipped: list[tuple[int, int]] = []
    for interval_start, interval_end in intervals:
        bounded_start = max(interval_start, start_time)
        bounded_end = min(interval_end, end_time)
        if bounded_end > bounded_start:
            clipped.append((bounded_start, bounded_end))
    return merge_intervals(clipped)


def subtract_intervals(
    base_intervals: list[tuple[int, int]],
    cut_intervals: list[tuple[int, int]],
) -> list[tuple[int, int]]:
    if not base_intervals:
        return []
    if not cut_intervals:
        return merge_intervals(base_intervals)

    remaining: list[tuple[int, int]] = []
    merged_base = merge_intervals(base_intervals)
    merged_cut = merge_intervals(cut_intervals)

    for base_start, base_end in merged_base:
        cursor = base_start
        for cut_start, cut_end in merged_cut:
            if cut_end <= cursor:
                continue
            if cut_start >= base_end:
                break
            if cut_start > cursor:
                remaining.append((cursor, min(cut_start, base_end)))
            cursor = max(cursor, cut_end)
            if cursor >= base_end:
                break
        if cursor < base_end:
            remaining.append((cursor, base_end))

    return merge_intervals(remaining)


def get_dma_burst_intervals_by_type(rows: list[PerfRow]) -> dict[str, list[tuple[int, int]]]:
    dma_rows = [
        row
        for row in rows
        if row.source == "dma" and row.txn_type in {"rd", "wr"}
    ]
    if not dma_rows:
        return {"rd": [], "wr": []}

    burst_tail_by_type: dict[str, int] = {}
    for txn_type in ("rd", "wr"):
        txn_times = [row.time for row in dma_rows if row.txn_type == txn_type]
        txn_deltas = [curr - prev for prev, curr in zip(txn_times, txn_times[1:]) if curr > prev]
        burst_tail_by_type[txn_type] = min(txn_deltas) if txn_deltas else int(SYSTEM_CLOCK_PERIOD_PS)

    burst_gap_threshold_by_type = {
        txn_type: max(burst_tail_by_type[txn_type] * 2, int(SYSTEM_CLOCK_PERIOD_PS))
        for txn_type in ("rd", "wr")
    }

    burst_intervals_by_type: dict[str, list[tuple[int, int]]] = {"rd": [], "wr": []}
    burst_start = dma_rows[0].time
    burst_end = dma_rows[0].time
    burst_type = dma_rows[0].txn_type

    for row in dma_rows[1:]:
        same_burst = (
            row.txn_type == burst_type
            and row.time - burst_end <= burst_gap_threshold_by_type.get(
                burst_type,
                int(SYSTEM_CLOCK_PERIOD_PS),
            )
        )
        if same_burst:
            burst_end = row.time
            continue
        burst_intervals_by_type[burst_type].append(
            (burst_start, burst_end + burst_tail_by_type.get(burst_type, int(SYSTEM_CLOCK_PERIOD_PS)))
        )
        burst_start = row.time
        burst_end = row.time
        burst_type = row.txn_type

    burst_intervals_by_type[burst_type].append(
        (burst_start, burst_end + burst_tail_by_type.get(burst_type, int(SYSTEM_CLOCK_PERIOD_PS)))
    )

    return {
        txn_type: merge_intervals(intervals)
        for txn_type, intervals in burst_intervals_by_type.items()
    }


def get_dma_burst_intervals(rows: list[PerfRow]) -> list[tuple[int, int]]:
    burst_intervals_by_type = get_dma_burst_intervals_by_type(rows)
    return merge_intervals(
        burst_intervals_by_type["rd"] + burst_intervals_by_type["wr"]
    )


def get_interval_duration_ps(intervals: list[tuple[int, int]]) -> int:
    return sum(max(interval_end - interval_start, 0) for interval_start, interval_end in intervals)


def build_subsystem_time_breakdown(
    start_time: int,
    window_end_hint: int,
    tile_summaries: list[TileSummary],
    observed_compute_intervals: list[tuple[int, int]],
    first_compute_active_time: int | None,
    subsystem_rows: list[PerfRow],
    core_start_times: list[int],
    core_done_times: list[int],
    df_done_time: int | None,
) -> SubsystemTimeBreakdown:
    core_intervals = pair_core_activity_intervals(
        core_start_times,
        core_done_times,
        tile_summaries,
        observed_compute_intervals,
        start_time,
        first_compute_active_time,
    )

    dma_intervals = get_dma_activity_intervals(
        subsystem_rows,
        ("dma_arvalid", "dma_rvalid", "dma_awvalid", "dma_wvalid"),
    )

    last_core_time = max(
        max((end for _, end in core_intervals), default=start_time),
        max(core_done_times, default=start_time),
    )
    last_dma_time = max((end for _, end in dma_intervals), default=start_time)
    fallback_end_time = max(last_core_time, last_dma_time, start_time)
    end_time = df_done_time if df_done_time is not None else fallback_end_time
    subsystem_end_interval = (
        end_time + int(SYSTEM_CLOCK_PERIOD_PS)
        if df_done_time is not None
        else min(
            window_end_hint + int(CORE_CLOCK_PERIOD_PS),
            max(
                max((end for _, end in core_intervals), default=start_time + int(CORE_CLOCK_PERIOD_PS)),
                max((end for _, end in dma_intervals), default=start_time + int(CORE_CLOCK_PERIOD_PS)),
                start_time + int(CORE_CLOCK_PERIOD_PS),
            ),
        )
    )

    core_intervals = clip_intervals(core_intervals, start_time, subsystem_end_interval)
    dma_intervals = clip_intervals(dma_intervals, start_time, subsystem_end_interval)
    df_intervals = subtract_intervals(
        [(start_time, subsystem_end_interval)],
        dma_intervals,
    )

    interval_sets = {
        1: merge_intervals(df_intervals),
        2: merge_intervals(core_intervals),
        4: merge_intervals(dma_intervals),
    }

    events: dict[int, list[tuple[int, int]]] = defaultdict(list)
    for bit, intervals in interval_sets.items():
        for interval_start, interval_end in intervals:
            events[interval_start].append((bit, 1))
            events[interval_end].append((bit, -1))

    mask_durations_ps: dict[int, int] = defaultdict(int)
    active_counts: dict[int, int] = defaultdict(int)
    active_mask = 0
    previous_time: int | None = None
    for event_time in sorted(events):
        if previous_time is not None and event_time > previous_time and active_mask:
            mask_durations_ps[active_mask] += event_time - previous_time
        for bit, delta in events[event_time]:
            active_counts[bit] += delta
        active_mask = 0
        for bit, count in active_counts.items():
            if count > 0:
                active_mask |= bit
        previous_time = event_time

    window_ps = max(subsystem_end_interval - start_time, int(CORE_CLOCK_PERIOD_PS))
    df_only_ps = mask_durations_ps.get(1, 0)
    core_only_ps = mask_durations_ps.get(2, 0)
    df_core_overlap_ps = mask_durations_ps.get(3, 0)
    dma_only_ps = mask_durations_ps.get(4, 0)
    df_dma_overlap_ps = mask_durations_ps.get(5, 0)
    core_dma_overlap_ps = mask_durations_ps.get(6, 0)
    all_units_overlap_ps = mask_durations_ps.get(7, 0)

    df_controller_active_ps = (
        df_only_ps + df_core_overlap_ps + df_dma_overlap_ps + all_units_overlap_ps
    )
    core_active_ps = (
        core_only_ps + df_core_overlap_ps + core_dma_overlap_ps + all_units_overlap_ps
    )
    dma_active_ps = (
        dma_only_ps + df_dma_overlap_ps + core_dma_overlap_ps + all_units_overlap_ps
    )

    window_core_eq_cycles = time_ps_to_core_cycles(window_ps)
    df_controller_cycles_core_eq = time_ps_to_core_cycles(df_controller_active_ps)
    core_cycles_core_eq = time_ps_to_core_cycles(core_active_ps)
    dma_cycles_core_eq = time_ps_to_core_cycles(dma_active_ps)

    utilization = (
        (df_controller_cycles_core_eq + core_cycles_core_eq + dma_cycles_core_eq)
        / (3.0 * window_core_eq_cycles)
        if window_core_eq_cycles
        else 0.0
    )

    return SubsystemTimeBreakdown(
        end_time=end_time,
        window_core_eq_cycles=window_core_eq_cycles,
        utilization=utilization,
        df_controller_cycles_core_eq=df_controller_cycles_core_eq,
        core_cycles_core_eq=core_cycles_core_eq,
        dma_cycles_core_eq=dma_cycles_core_eq,
        df_controller_utilization=(df_controller_cycles_core_eq / window_core_eq_cycles) if window_core_eq_cycles else 0.0,
        core_utilization=(core_cycles_core_eq / window_core_eq_cycles) if window_core_eq_cycles else 0.0,
        dma_utilization=(dma_cycles_core_eq / window_core_eq_cycles) if window_core_eq_cycles else 0.0,
        df_only_cycles_core_eq=time_ps_to_core_cycles(df_only_ps),
        core_only_cycles_core_eq=time_ps_to_core_cycles(core_only_ps),
        dma_only_cycles_core_eq=time_ps_to_core_cycles(dma_only_ps),
        df_core_overlap_cycles_core_eq=time_ps_to_core_cycles(df_core_overlap_ps),
        df_dma_overlap_cycles_core_eq=time_ps_to_core_cycles(df_dma_overlap_ps),
        core_dma_overlap_cycles_core_eq=time_ps_to_core_cycles(core_dma_overlap_ps),
        all_units_overlap_cycles_core_eq=time_ps_to_core_cycles(all_units_overlap_ps),
    )


def mark_outlier_tiles(tile_summaries: list[TileSummary]) -> list[TileSummary]:
    if len(tile_summaries) < 4:
        return tile_summaries

    cycle_values = sorted(tile.cycle_counter for tile in tile_summaries)
    median_cycle = median(cycle_values)
    lower_half = cycle_values[: len(cycle_values) // 2]
    upper_half = cycle_values[(len(cycle_values) + 1) // 2 :]
    q1 = median(lower_half) if lower_half else median_cycle
    q3 = median(upper_half) if upper_half else median_cycle
    iqr = q3 - q1

    if iqr > 0:
        lower_bound = q1 - 1.5 * iqr
        upper_bound = q3 + 1.5 * iqr
        for tile in tile_summaries:
            tile.is_outlier = tile.cycle_counter < lower_bound or tile.cycle_counter > upper_bound
        return tile_summaries

    if median_cycle <= 0:
        return tile_summaries

    lower_bound = median_cycle * 0.5
    upper_bound = median_cycle * 1.5
    for tile in tile_summaries:
        tile.is_outlier = tile.cycle_counter < lower_bound or tile.cycle_counter > upper_bound

    return tile_summaries