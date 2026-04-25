from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from perf_analyzer.models import DmaBufferMetrics, TensorSummary, TileSummary
from perf_analyzer.presentation_builder import build_presentation_payload
from perf_analyzer.reporting.models import PresentationPayload


@dataclass(frozen=True)
class PresentationMetadata:
    title: str
    input_csv: Path
    source_periods: dict[str, int | None]


@dataclass(frozen=True)
class PresentationBundle:
    metadata: PresentationMetadata
    tensor_summaries: list[TensorSummary]
    tile_summaries: list[TileSummary]
    dma_buffer_metrics: dict[str, DmaBufferMetrics]
    presentation: PresentationPayload


def build_presentation_bundle(
    report_title: str,
    csv_path: Path,
    tensor_summaries: list[TensorSummary],
    tile_summaries: list[TileSummary],
    source_periods: dict[str, int | None],
    dma_buffer_metrics: dict[str, DmaBufferMetrics],
) -> PresentationBundle:
    return PresentationBundle(
        metadata=PresentationMetadata(
            title=report_title,
            input_csv=csv_path,
            source_periods=source_periods,
        ),
        tensor_summaries=tensor_summaries,
        tile_summaries=tile_summaries,
        dma_buffer_metrics=dma_buffer_metrics,
        presentation=build_presentation_payload(tensor_summaries, tile_summaries, dma_buffer_metrics),
    )
