from __future__ import annotations

import argparse
import csv
from pathlib import Path

from perf_analyzer.models import PerfRow


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Analyze SAURIA performance logs and generate reports. "
            "Input can be a single SA_perf_data.csv file or a regression directory."
        )
    )
    parser.add_argument(
        "csv_path",
        help=(
            "Path to SAURIA perf CSV file, or a regression run directory "
            "containing multiple SA_perf_data.csv files."
        ),
    )
    parser.add_argument(
        "-o",
        "--output-dir",
        help="Directory where the report artifacts will be written.",
    )
    parser.add_argument(
        "--report-title",
        default="SAURIA Performance Analysis",
        help="Custom title used in the HTML report.",
    )
    return parser.parse_args()


def parse_optional_int(value: str) -> int | None:
    stripped = value.strip()
    if not stripped:
        return None
    if stripped.lower().startswith("0x"):
        return int(stripped, 16)
    return int(stripped)


def load_perf_rows(csv_path: Path) -> list[PerfRow]:
    rows: list[PerfRow] = []
    with csv_path.open(newline="", encoding="utf-8") as handle:
        reader = csv.DictReader(handle)
        for raw in reader:
            rows.append(
                PerfRow(
                    time=int(raw["time"]),
                    source=raw["source"].strip(),
                    txn_type=raw["txn_type"].strip(),
                    addr=parse_optional_int(raw["addr"]),
                    data=parse_optional_int(raw["data"]),
                    pipeline_en=parse_optional_int(raw["pipeline_en"]),
                    feeder_en=parse_optional_int(raw["feeder_en"]),
                    act_valid=parse_optional_int(raw["act_valid"]),
                    wei_valid=parse_optional_int(raw["wei_valid"]),
                    pop_en=parse_optional_int(raw["pop_en"]),
                    srama_rden=parse_optional_int(raw["srama_rden"]),
                    sramb_rden=parse_optional_int(raw["sramb_rden"]),
                    fifo_empty=parse_optional_int(raw["fifo_empty"]),
                    fifo_full=parse_optional_int(raw["fifo_full"]),
                    feeder_stall=parse_optional_int(raw["feeder_stall"]),
                    feeder_active=parse_optional_int(raw["feeder_active"]),
                    cscan_en=parse_optional_int(raw["cscan_en"]),
                    sramc_rden=parse_optional_int(raw["sramc_rden"]),
                    sramc_wren=parse_optional_int(raw["sramc_wren"]),
                    context_num=parse_optional_int(raw["context_num"]),
                    cswitch=parse_optional_int(raw["cswitch"]),
                    ctx_status=parse_optional_int(raw["ctx_status"]),
                    feed_status=parse_optional_int(raw["feed_status"]),
                    feed_deadlock=parse_optional_int(raw["feed_deadlock"]),
                    df_done=parse_optional_int(raw["df_done"]),
                    core_start=parse_optional_int(raw["core_start"]),
                    core_done=parse_optional_int(raw["core_done"]),
                    dma_arvalid=parse_optional_int(raw["dma_arvalid"]),
                    dma_rvalid=parse_optional_int(raw["dma_rvalid"]),
                    dma_awvalid=parse_optional_int(raw["dma_awvalid"]),
                    dma_wvalid=parse_optional_int(raw["dma_wvalid"]),
                )
            )
    return rows


def write_csv(path: Path, rows: list[dict[str, object]]) -> None:
    if not rows:
        path.write_text("", encoding="utf-8")
        return

    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)