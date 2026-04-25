from __future__ import annotations

REPORT_STYLE_BLOCK = """
    body {
      font-family: \"Segoe UI\", sans-serif;
      margin: 0;
      color: #1a1a1a;
      background: linear-gradient(180deg, #f5f7fb 0%, #ffffff 100%);
    }
    main {
      max-width: 1200px;
      margin: 0 auto;
      padding: 32px 24px 56px;
    }
    h1 { margin: 0 0 8px; }
    h2 { margin: 28px 0 12px; font-size: 1.2rem; }
    p, li { line-height: 1.5; }
    .lede { max-width: 900px; color: #374151; }
    .cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
      gap: 16px;
      margin: 24px 0 32px;
    }
    .card {
      background: #ffffff;
      border: 1px solid #dbe3ef;
      border-radius: 14px;
      padding: 16px;
      box-shadow: 0 8px 20px rgba(31, 41, 55, 0.06);
    }
    .card-label { font-size: 0.9rem; color: #556070; margin-bottom: 8px; }
    .card-value { font-size: 1.6rem; font-weight: 700; }
    .chart {
      background: #ffffff;
      border: 1px solid #dbe3ef;
      border-radius: 16px;
      padding: 14px;
      margin-bottom: 24px;
      box-shadow: 0 8px 20px rgba(31, 41, 55, 0.05);
    }
    table {
      width: 100%;
      border-collapse: collapse;
      background: #ffffff;
      border: 1px solid #dbe3ef;
      border-radius: 14px;
      overflow: hidden;
      margin-bottom: 24px;
      box-shadow: 0 8px 20px rgba(31, 41, 55, 0.05);
    }
    th, td {
      padding: 10px 12px;
      border-bottom: 1px solid #edf2f7;
      text-align: left;
      font-size: 0.93rem;
    }
    th { background: #eef4fb; }
    code { background: #eef4fb; padding: 2px 6px; border-radius: 6px; }
    .muted { color: #667085; }
"""

INTRO_LEDES = (
    """
      Report generated from <code>{csv_path}</code>. The analyzer anchors tensor execution
      at DF-controller reg21 writes to <code>0x40000064</code>, pairs the per-tile core counters read from
      <code>0x50000014</code> and <code>0x50000018</code>, and derives unit-level activity from the perf rows
      already emitted by the scoreboard. First-tile observed utilization starts at the first compute-active
      cycle to avoid charging initial pipeline fill latency only to tile 1.
    """,
    """
      Core-domain units use the SAURIA core clock, while the DMA and dataflow engines are driven by the system clock.
      To keep unit comparisons on a common basis, all reported DMA cycle totals are converted to core-clock-equivalent cycles
      using {system_clock_period_ps:.0f} ps system cycles and {core_clock_period_ps:.0f} ps core cycles.
    """,
    """
      Tile outliers are detected from the per-tile core cycle counter using a robust cycle-count filter.
      Outlier tiles are flagged in the table and excluded from utilization and average-style core rollups.
    """,
    """
      Feeder SRAM activity is reported two ways: raw SRAM read-enable cycles and valid SRAM access cycles.
      Valid SRAM access cycles now require feeder enable, valid, and SRAM read-enable. Additional mismatch buckets
      highlight invalid SRAM reads that happen while the feeder is effectively disabled or still pre-filling its FIFO. The invalid-read breakdown partitions raw SRAM read-enable cycles into one remaining valid chunk plus those explicit invalid-read categories.
    """,
    """
      The feeder activity breakdown uses mutually exclusive operating states so overlapping feed and valid-SRAM-read cycles are counted once. This gives a more realistic view of active operation versus read-only behavior and stalls.
    """,
    """
      Scan-chain and context-switch breakdowns are both split by whether feeder activity is present in the same cycle, so psums-manager activity can be correlated with active data movement.
    """,
    """
      The psums-manager activity breakdown also uses mutually exclusive scan/read/write overlap states, so simultaneous scan-chain and SRAM activity is shown explicitly instead of being double-counted.
    """,
    """
      The first per-tensor core breakdown is derived directly from the status CRs. The observed breakdown below is evaluated only inside the paired core start/done windows, uses feeder activity as the compute condition, counts feeder stalls as stalls only, and classifies non-compute feeder SRAM access, psums-manager activity, and context-switch or other systolic-side work as other activity. Main-controller-only internal FSM activity and fully untracked gaps stay outside that observed-utilization denominator and remain visible only in the tracked-unit overlap view.
    """,
    """
      DMA traffic is classified as ifmaps, weights, or psums from the logged beat address using the configured base-address families:
      <code>0x7000_0000</code>, <code>0x8000_0000</code>, and <code>0x9000_0000</code> for memory space, plus the corresponding
      local DMA windows rooted at <code>0xD004_0000</code>, <code>0xD008_0000</code>, and <code>0xD00C_0000</code>.
    """,
)

SAMPLING_NOTES_TEMPLATE = """
    <h2>Sampling Notes</h2>
    <p class=\"muted\">
      Core utilization uses the hardware cycle and stall counters, which are reported per tile in the core clock domain.
      DMA read/write window cycles in the tensor summary and unit-activity coverage are counted from the union of the logged AXI valid signals in the system clock domain and converted to core-clock-equivalent cycles for charting.
      Feeder, systolic, and psums-manager activity is derived directly from their logged per-cycle snapshots in the core clock domain.
      The subsystem time breakdown is an abstraction over the observable interfaces. The subsystem window starts at the DF_START write and ends at the true subsystem DF-done interrupt. Within that window, core tile-compute time is reconstructed from logged core-start pulses paired with core-done pulses, DMA activity is measured from the union of the logged AXI valid signals, and the DF controller is treated as active across the subsystem window. This exposes DF + Core overlap, DF + DMA overlap, and DF + Core + DMA overlap explicitly, so background DF orchestration during tile compute is no longer folded into DF-only.
      Feeder valid SRAM access cycles require feeder enable, valid, and SRAM read-enable; the raw read-enable counts are preserved separately in the invalid SRAM read table. The feeder activity chart uses a non-overlapping partition of feed-plus-read, feed-only, read-only, and stall cycles. Scan-chain and context-switch breakdowns are split by simultaneous feeder activity, and the psums-manager chart uses a non-overlapping partition of scan/read/write overlap states. The observed unit-activity tensor view is overlap-aware across feeders, psums manager, and systolic array within the paired core start/done windows, and it separately calls out feeder stalls and main-controller-only internal FSM activity when no other tracked unit is active.
      DMA buffer and reuse metrics are still computed from observed DMA beat rows and read transaction base addresses only; write transactions do not contribute to the read transaction count, unique read addresses, reused read transactions, or read reuse ratio.
      Tiles flagged as outliers are excluded from the reported core utilization rollups and from the per-tile utilization chart.
    </p>
    <ul>{period_list}</ul>
"""
