from __future__ import annotations

from perf_analyzer.presentation_bundle import PresentationBundle
from perf_analyzer.reporting.models import ChartGroup, PresentationChart
from perf_analyzer.reporting.formatting import format_number, format_percent_display


_BAR_WIDTH = 28
_STACK_WIDTH = 32
_SERIES_MARKERS = "#=+*xo~:^%@$"


def _escape_markdown_cell(value: str | int | float) -> str:
    text = str(value)
    return text.replace("|", "\\|").replace("\n", " ")


def _format_chart_value(value: float, value_format: str) -> str:
    if value_format == "percent":
        return format_percent_display(value)
    return format_number(value)


def _format_period_value(period: int | None) -> str:
    if period is None:
        return "n/a"
    return format_number(period)


def _render_table(columns: list[str], rows: list[list[str | int | float]]) -> str:
    header = "| " + " | ".join(_escape_markdown_cell(column) for column in columns) + " |"
    divider = "| " + " | ".join("---" for _ in columns) + " |"
    body = [
        "| " + " | ".join(_escape_markdown_cell(cell) for cell in row) + " |"
        for row in rows
    ]
    return "\n".join([header, divider, *body])


def _chart_value_heading(chart: PresentationChart) -> str:
    if chart.x_label:
        return chart.x_label
    if chart.value_format == "percent":
        return "Percent"
    return "Value"


def _ordered_segment_labels(groups: list[ChartGroup]) -> list[str]:
    labels: list[str] = []
    seen: set[str] = set()
    for group in groups:
        for segment in group.segments:
            if segment.label in seen:
                continue
            seen.add(segment.label)
            labels.append(segment.label)
    return labels


def _normalize_label(label: str, width: int) -> str:
    if len(label) <= width:
        return label.ljust(width)
    if width <= 3:
        return label[:width]
    return label[: width - 3] + "..."


def _scaled_bar(value: float, max_value: float, width: int = _BAR_WIDTH) -> str:
    if width <= 0 or max_value <= 0 or value <= 0:
        return ""
    filled = max(1, round((value / max_value) * width))
    return "#" * min(width, filled)


def _render_code_block(lines: list[str]) -> str:
    return "\n".join(["```text", *lines, "```"])


def _render_item_bar_chart(chart: PresentationChart) -> str | None:
    if not chart.items:
        return None

    max_value = max(item.value for item in chart.items)
    label_width = min(max(len(item.label) for item in chart.items), 24)
    lines = [f"Scale: 0 to {_format_chart_value(max_value, chart.value_format)}"]
    for item in chart.items:
        lines.append(
            f"{_normalize_label(item.label, label_width)} | {_scaled_bar(item.value, max_value)} {_format_chart_value(item.value, chart.value_format)}"
        )
    return _render_code_block(lines)


def _render_grouped_bar_chart(chart: PresentationChart) -> str | None:
    if not chart.groups:
        return None

    segment_labels = _ordered_segment_labels(chart.groups)
    if not segment_labels:
        return None

    if len(chart.groups) == 1:
        group = chart.groups[0]
        max_value = max((segment.value for segment in group.segments), default=0.0)
        label_width = min(max(len(segment.label) for segment in group.segments), 24)
        lines = [f"Scale: 0 to {_format_chart_value(max_value, chart.value_format)}"]
        for segment in group.segments:
            lines.append(
                f"{_normalize_label(segment.label, label_width)} | {_scaled_bar(segment.value, max_value)} {_format_chart_value(segment.value, chart.value_format)}"
            )
        return _render_code_block(lines)

    label_width = min(max(len(group.label) for group in chart.groups), 24)
    lines: list[str] = []
    for index, segment_label in enumerate(segment_labels):
        segment_values = []
        for group in chart.groups:
            value = next((segment.value for segment in group.segments if segment.label == segment_label), 0.0)
            segment_values.append((group.label, value))

        max_value = max(value for _, value in segment_values)
        lines.append(segment_label)
        lines.append(f"Scale: 0 to {_format_chart_value(max_value, chart.value_format)}")
        for group_label, value in segment_values:
            lines.append(
                f"{_normalize_label(group_label, label_width)} | {_scaled_bar(value, max_value)} {_format_chart_value(value, chart.value_format)}"
            )
        if index != len(segment_labels) - 1:
            lines.append("")

    return _render_code_block(lines)


def _segment_marker_map(labels: list[str]) -> dict[str, str]:
    return {
        label: _SERIES_MARKERS[index % len(_SERIES_MARKERS)]
        for index, label in enumerate(labels)
    }


def _stack_bar(values: list[tuple[str, float]], width: int = _STACK_WIDTH) -> str:
    total = sum(value for _, value in values)
    if total <= 0:
        return "." * width

    raw_widths = [value / total * width for _, value in values]
    base_widths = [int(raw_width) for raw_width in raw_widths]
    remainder = width - sum(base_widths)

    ranked_remainders = sorted(
        enumerate(raw_widths),
        key=lambda item: item[1] - int(item[1]),
        reverse=True,
    )
    for index, _ in ranked_remainders[:remainder]:
        base_widths[index] += 1

    bar = ""
    for (marker, value), segment_width in zip(values, base_widths):
        if value > 0 and segment_width == 0:
            segment_width = 1
        bar += marker * segment_width

    if len(bar) > width:
        bar = bar[:width]
    return bar.ljust(width, ".")


def _render_stacked_bar_chart(chart: PresentationChart) -> str | None:
    if not chart.groups:
        return None

    segment_labels = _ordered_segment_labels(chart.groups)
    if not segment_labels:
        return None

    marker_map = _segment_marker_map(segment_labels)
    label_width = min(max(len(group.label) for group in chart.groups), 24)
    legend = "  ".join(f"{marker_map[label]}={label}" for label in segment_labels)
    lines = [f"Legend: {legend}"]

    for group in chart.groups:
        values_by_label = {
            segment.label: segment.value
            for segment in group.segments
        }
        marker_values = [
            (marker_map[label], values_by_label.get(label, 0.0))
            for label in segment_labels
        ]
        total_value = sum(values_by_label.get(label, 0.0) for label in segment_labels)
        lines.append(
            f"{_normalize_label(group.label, label_width)} | {_stack_bar(marker_values)} {_format_chart_value(total_value, chart.value_format)}"
        )

    return _render_code_block(lines)


def _render_chart_visual(chart: PresentationChart) -> str | None:
    if chart.items:
        return _render_item_bar_chart(chart)
    if chart.kind == "grouped_bar":
        return _render_grouped_bar_chart(chart)
    if chart.kind == "stacked_bar":
        return _render_stacked_bar_chart(chart)
    return None


def _render_group_table(chart: PresentationChart) -> str:
    value_heading = _chart_value_heading(chart)
    if len(chart.groups) == 1:
        group = chart.groups[0]
        return "\n".join([
            f"**{group.label}**",
            "",
            _render_table(
                ["Segment", value_heading],
                [
                    [segment.label, _format_chart_value(segment.value, chart.value_format)]
                    for segment in group.segments
                ],
            ),
        ])

    segment_labels = _ordered_segment_labels(chart.groups)
    rows: list[list[str]] = []
    for group in chart.groups:
        values_by_label = {
            segment.label: _format_chart_value(segment.value, chart.value_format)
            for segment in group.segments
        }
        rows.append([group.label, *[values_by_label.get(label, "") for label in segment_labels]])

    return _render_table(["Group", *segment_labels], rows)


def _render_chart(chart: PresentationChart) -> str:
    parts: list[str] = [f"### {chart.title}"]

    visual = _render_chart_visual(chart)
    if visual:
        parts.extend([
            "",
            visual,
        ])

    if chart.items:
        parts.extend([
            "",
            _render_table(
                ["Metric", _chart_value_heading(chart)],
                [
                    [item.label, _format_chart_value(item.value, chart.value_format)]
                    for item in chart.items
                ],
            ),
        ])

    if chart.groups:
        parts.extend([
            "",
            _render_group_table(chart),
        ])

    return "\n".join(parts)


def _render_named_value_table(title: str, rows: list[list[str]]) -> str:
    return "\n".join([
        f"## {title}",
        "",
        _render_table(["Metric", "Value"], rows),
    ])


def render_markdown_report(
    presentation_bundle: PresentationBundle,
) -> str:
    presentation = presentation_bundle.presentation
    metadata = presentation_bundle.metadata

    summary_rows = [[card.label, format_number(card.value)] for card in presentation.summary_cards]
    period_rows = [[source, _format_period_value(period)] for source, period in metadata.source_periods.items()]

    parts: list[str] = [
        f"# {metadata.title}",
        "",
        "> Performance analysis rendered for Markdown consumption.",
        "",
        _render_named_value_table(
            "Report Context",
            [
                ["Input CSV", str(metadata.input_csv)],
            ],
        ),
        "",
        _render_named_value_table("Summary", summary_rows),
        "",
        _render_named_value_table("Source Periods", period_rows),
        "",
        "## Metric Breakdowns",
        "",
    ]

    for index, chart in enumerate(presentation.charts):
        parts.append(_render_chart(chart))
        if index != len(presentation.charts) - 1:
            parts.extend(["", "---", ""])

    parts.extend([
        "",
        "## Detailed Tables",
        "",
    ])

    for index, table in enumerate(presentation.tables):
        parts.extend([
            f"### {table.title}",
            "",
            _render_table(table.columns, table.rows),
        ])
        if index != len(presentation.tables) - 1:
            parts.extend(["", "---", ""])

    return "\n".join(parts).rstrip() + "\n"