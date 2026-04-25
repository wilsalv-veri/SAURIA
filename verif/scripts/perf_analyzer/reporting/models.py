from __future__ import annotations

from dataclasses import dataclass, field
from typing import Literal


@dataclass(frozen=True)
class SummaryCard:
    label: str
    value: int | float


@dataclass(frozen=True)
class BarValue:
    label: str
    value: float


@dataclass(frozen=True)
class ChartSegment:
    label: str
    value: float
    color: str


@dataclass(frozen=True)
class ChartGroup:
    label: str
    segments: list[ChartSegment]


@dataclass(frozen=True)
class PresentationChart:
    title: str
    kind: Literal["bar", "stacked_bar", "grouped_bar"]
    items: list[BarValue] = field(default_factory=list)
    groups: list[ChartGroup] = field(default_factory=list)
    x_label: str | None = None
    value_format: Literal["number", "percent"] = "number"
    bar_color: str | None = None


@dataclass(frozen=True)
class PresentationTable:
    title: str
    columns: list[str]
    rows: list[list[str | int | float]]


@dataclass(frozen=True)
class PresentationPayload:
    summary_cards: list[SummaryCard]
    charts: list[PresentationChart]
    tables: list[PresentationTable]
