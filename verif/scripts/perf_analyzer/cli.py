from __future__ import annotations

import json
from dataclasses import asdict
from pathlib import Path

from perf_analyzer.constants import DEFAULT_OUTPUT_DIR_SUFFIX
from perf_analyzer.io_utils import load_perf_rows, parse_args, write_csv
from perf_analyzer.metrics import (
    analyze_tensor,
    get_tensor_windows,
    infer_source_period,
    pair_tile_counters,
    rows_in_window,
    summarize_dma_buffer_metrics,
)
from perf_analyzer.models import PerfRow, TensorSummary, TileSummary
from perf_analyzer.presentation_bundle import build_presentation_bundle
from perf_analyzer.reporting.renderers.markdown import render_markdown_report
from perf_analyzer.reporting.schema import PRESENTATION_PAYLOAD_SCHEMA_VERSION
from perf_analyzer.reporting.renderers.html import render_html_report


def main() -> int:
    args = parse_args()
    csv_path = Path(args.csv_path).expanduser().resolve()
    if not csv_path.exists():
        raise FileNotFoundError(f"Perf CSV not found: {csv_path}")

    output_dir = (
        Path(args.output_dir).expanduser().resolve()
        if args.output_dir
        else csv_path.parent / f"{csv_path.stem}{DEFAULT_OUTPUT_DIR_SUFFIX}"
    )
    output_dir.mkdir(parents=True, exist_ok=True)

    rows = load_perf_rows(csv_path)
    if not rows:
        raise ValueError(f"Perf CSV is empty: {csv_path}")

    tiles = pair_tile_counters(rows)
    tensor_windows = get_tensor_windows(rows, tiles)

    tensor_summaries: list[TensorSummary] = []
    tile_summaries: list[TileSummary] = []

    for tensor_id, start_time, window_end_hint, tensor_tiles in tensor_windows:
        tensor_summary, tensor_tile_summaries = analyze_tensor(
            tensor_id,
            rows,
            start_time,
            window_end_hint,
            tensor_tiles,
        )
        tensor_summaries.append(tensor_summary)
        tile_summaries.extend(tensor_tile_summaries)

    source_periods = {
        source: infer_source_period(rows, source)
        for source in ["ifmaps_feeder", "weights_feeder", "systolic_array", "psums_mgr", "dma"]
    }

    analysis_rows: list[PerfRow] = []
    for tensor_summary in tensor_summaries:
        analysis_rows.extend(
            rows_in_window(rows, tensor_summary.start_time, tensor_summary.subsystem_end_time)
        )

    dma_buffer_metrics = summarize_dma_buffer_metrics(
        [row for row in analysis_rows if row.source == "dma"]
    )
    presentation_bundle = build_presentation_bundle(
        args.report_title,
        csv_path,
        tensor_summaries,
        tile_summaries,
        source_periods,
        dma_buffer_metrics,
    )

    tensor_rows = [asdict(item) for item in tensor_summaries]
    tile_rows = [asdict(item) for item in tile_summaries]
    dma_buffer_rows = [asdict(item) for item in dma_buffer_metrics.values()]
    report_payload = {
        "input_csv": str(csv_path),
        "tensor_summaries": tensor_rows,
        "tile_summaries": tile_rows,
        "dma_buffer_metrics": dma_buffer_rows,
        "source_periods": source_periods,
    }
    presentation_payload = {
        "schema_version": PRESENTATION_PAYLOAD_SCHEMA_VERSION,
        "metadata": {
            "title": presentation_bundle.metadata.title,
            "input_csv": str(presentation_bundle.metadata.input_csv),
            "source_periods": presentation_bundle.metadata.source_periods,
        },
        "presentation": asdict(presentation_bundle.presentation),
    }

    write_csv(output_dir / "tensor_summary.csv", tensor_rows)
    write_csv(output_dir / "tile_summary.csv", tile_rows)
    write_csv(output_dir / "dma_buffer_summary.csv", dma_buffer_rows)
    (output_dir / "perf_summary.json").write_text(
        json.dumps(report_payload, indent=2),
        encoding="utf-8",
    )
    (output_dir / "presentation_payload.json").write_text(
        json.dumps(presentation_payload, indent=2),
        encoding="utf-8",
    )
    (output_dir / "perf_report.html").write_text(
        render_html_report(presentation_bundle),
        encoding="utf-8",
    )
    (output_dir / "perf_report.md").write_text(
        render_markdown_report(presentation_bundle),
        encoding="utf-8",
    )

    print(f"Wrote analysis artifacts to {output_dir}")
    print(f"HTML report: {output_dir / 'perf_report.html'}")
    print(f"Markdown report: {output_dir / 'perf_report.md'}")
    print(f"Presentation payload JSON: {output_dir / 'presentation_payload.json'}")
    print(f"Tensor summary CSV: {output_dir / 'tensor_summary.csv'}")
    print(f"Tile summary CSV: {output_dir / 'tile_summary.csv'}")
    return 0