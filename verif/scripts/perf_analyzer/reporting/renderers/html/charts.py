from __future__ import annotations

import html
from collections.abc import Callable

from perf_analyzer.constants import PALETTE
from perf_analyzer.reporting.formatting import format_number
from perf_analyzer.reporting.models import BarValue, ChartGroup


def _build_legend_rows(
    legend_items: list[tuple[str, str]],
    width: int,
    legend_item_spacing: int,
    legend_swatch_width: int,
    legend_text_padding: int,
) -> list[list[tuple[str, str]]]:
    max_legend_width = width - 24
    legend_rows: list[list[tuple[str, str]]] = [[]]
    current_row_width = 0
    for label, color in legend_items:
        item_width = legend_swatch_width + legend_text_padding + len(label) * 7 + legend_item_spacing
        if legend_rows[-1] and current_row_width + item_width > max_legend_width:
            legend_rows.append([])
            current_row_width = 0
        legend_rows[-1].append((label, color))
        current_row_width += item_width
    return legend_rows


def build_svg_bar_chart(
    title: str,
    items: list[BarValue],
    width: int = 860,
    bar_color: str = PALETTE["blue"],
    x_label: str = "Value",
) -> str:
    if not items:
        return f"<section><h2>{html.escape(title)}</h2><p>No data available.</p></section>"

    left_margin = 190
    right_margin = 110
    bar_height = 28
    gap = 16
    top_margin = 56
    bottom_margin = 34
    chart_width = width - left_margin - right_margin
    max_value = max(item.value for item in items) or 1.0
    height = top_margin + bottom_margin + len(items) * (bar_height + gap)

    parts = [
        f'<section class="chart"><h2>{html.escape(title)}</h2>',
        f'<svg viewBox="0 0 {width} {height}" role="img" aria-label="{html.escape(title)}">',
        f'<text x="{left_margin}" y="24" font-size="16" font-weight="700" fill="#1a1a1a">{html.escape(title)}</text>',
    ]

    for index, item in enumerate(items):
        y = top_margin + index * (bar_height + gap)
        scaled = 0 if max_value == 0 else (item.value / max_value) * chart_width
        parts.append(
            f'<text x="12" y="{y + 18}" font-size="13" fill="#1a1a1a">{html.escape(item.label)}</text>'
        )
        parts.append(
            f'<rect x="{left_margin}" y="{y}" width="{scaled:.2f}" height="{bar_height}" fill="{bar_color}" rx="4" />'
        )
        parts.append(
            f'<text x="{width - 12}" y="{y + 18}" font-size="12" fill="#1a1a1a" text-anchor="end">{format_number(item.value)}</text>'
        )

    parts.append(
        f'<text x="{left_margin}" y="{height - 8}" font-size="12" fill="#555">{html.escape(x_label)}</text>'
    )
    parts.append("</svg></section>")
    return "".join(parts)


def build_svg_stacked_bar_chart(
    title: str,
    bars: list[ChartGroup],
    width: int = 860,
) -> str:
    if not bars:
        return f"<section><h2>{html.escape(title)}</h2><p>No data available.</p></section>"

    left_margin = 175
    right_margin = 100
    bar_height = 34
    gap = 22
    top_margin = 66
    legend_item_spacing = 18
    legend_swatch_width = 14
    legend_text_padding = 20
    legend_row_height = 22
    chart_width = width - left_margin - right_margin
    max_total = max(sum(segment.value for segment in bar.segments) for bar in bars) or 1.0
    legend_items: list[tuple[str, str]] = []
    seen_legend: set[str] = set()

    for bar in bars:
        for segment in bar.segments:
            if segment.label not in seen_legend:
                seen_legend.add(segment.label)
                legend_items.append((segment.label, segment.color))

    legend_rows = _build_legend_rows(
        legend_items,
        width,
        legend_item_spacing,
        legend_swatch_width,
        legend_text_padding,
    )
    bottom_margin = 40 + len(legend_rows) * legend_row_height
    height = top_margin + bottom_margin + len(bars) * (bar_height + gap)

    parts = [
        f'<section class="chart"><h2>{html.escape(title)}</h2>',
        f'<svg viewBox="0 0 {width} {height}" role="img" aria-label="{html.escape(title)}">',
        f'<text x="{left_margin}" y="24" font-size="16" font-weight="700" fill="#1a1a1a">{html.escape(title)}</text>',
    ]

    for index, bar in enumerate(bars):
        y = top_margin + index * (bar_height + gap)
        parts.append(
            f'<text x="12" y="{y + 22}" font-size="13" fill="#1a1a1a">{html.escape(bar.label)}</text>'
        )
        cursor = left_margin
        total = sum(segment.value for segment in bar.segments)
        for segment in bar.segments:
            segment_width = 0 if max_total == 0 else (segment.value / max_total) * chart_width
            if segment_width <= 0:
                continue
            parts.append(
                f'<rect x="{cursor:.2f}" y="{y}" width="{segment_width:.2f}" height="{bar_height}" fill="{segment.color}" rx="3" />'
            )
            cursor += segment_width
        parts.append(
            f'<text x="{width - 12}" y="{y + 22}" font-size="12" fill="#1a1a1a" text-anchor="end">{format_number(total)}</text>'
        )

    legend_y = height - bottom_margin + 12
    for row_index, legend_row in enumerate(legend_rows):
        legend_x = 12
        row_y = legend_y + row_index * legend_row_height
        for label, color in legend_row:
            parts.append(
                f'<rect x="{legend_x}" y="{row_y}" width="{legend_swatch_width}" height="14" fill="{color}" rx="2" />'
            )
            parts.append(
                f'<text x="{legend_x + legend_text_padding}" y="{row_y + 12}" font-size="12" fill="#1a1a1a">{html.escape(label)}</text>'
            )
            legend_x += legend_swatch_width + legend_text_padding + len(label) * 7 + legend_item_spacing

    parts.append("</svg></section>")
    return "".join(parts)


def build_svg_grouped_bar_chart(
    title: str,
    groups: list[ChartGroup],
    width: int = 860,
    x_label: str = "Value",
    value_formatter: Callable[[float], str] | None = None,
) -> str:
    if not groups:
        return f"<section><h2>{html.escape(title)}</h2><p>No data available.</p></section>"

    left_margin = 190
    right_margin = 110
    bar_height = 16
    intra_group_gap = 8
    group_gap = 20
    top_margin = 56
    legend_item_spacing = 18
    legend_swatch_width = 14
    legend_text_padding = 20
    legend_row_height = 22
    chart_width = width - left_margin - right_margin
    max_value = max((segment.value for group in groups for segment in group.segments), default=0.0) or 1.0

    legend_items: list[tuple[str, str]] = []
    seen_legend: set[str] = set()
    for group in groups:
        for segment in group.segments:
            if segment.label not in seen_legend:
                seen_legend.add(segment.label)
                legend_items.append((segment.label, segment.color))

    legend_rows = _build_legend_rows(
        legend_items,
        width,
        legend_item_spacing,
        legend_swatch_width,
        legend_text_padding,
    )
    group_height = len(groups[0].segments) * bar_height + (len(groups[0].segments) - 1) * intra_group_gap
    bottom_margin = 40 + len(legend_rows) * legend_row_height
    height = top_margin + bottom_margin + len(groups) * (group_height + group_gap)

    parts = [
        f'<section class="chart"><h2>{html.escape(title)}</h2>',
        f'<svg viewBox="0 0 {width} {height}" role="img" aria-label="{html.escape(title)}">',
        f'<text x="{left_margin}" y="24" font-size="16" font-weight="700" fill="#1a1a1a">{html.escape(title)}</text>',
    ]

    for group_index, group in enumerate(groups):
        group_y = top_margin + group_index * (group_height + group_gap)
        parts.append(
            f'<text x="12" y="{group_y + group_height / 2 + 4:.0f}" font-size="13" fill="#1a1a1a">{html.escape(group.label)}</text>'
        )
        for series_index, segment in enumerate(group.segments):
            y = group_y + series_index * (bar_height + intra_group_gap)
            scaled = 0 if max_value == 0 else (segment.value / max_value) * chart_width
            parts.append(
                f'<rect x="{left_margin}" y="{y}" width="{scaled:.2f}" height="{bar_height}" fill="{segment.color}" rx="3" />'
            )
            parts.append(
                f'<text x="{width - 12}" y="{y + 12}" font-size="12" fill="#1a1a1a" text-anchor="end">{value_formatter(segment.value) if value_formatter else format_number(segment.value)}</text>'
            )

    legend_y = height - bottom_margin + 12
    for row_index, legend_row in enumerate(legend_rows):
        legend_x = 12
        row_y = legend_y + row_index * legend_row_height
        for label, color in legend_row:
            parts.append(
                f'<rect x="{legend_x}" y="{row_y}" width="{legend_swatch_width}" height="14" fill="{color}" rx="2" />'
            )
            parts.append(
                f'<text x="{legend_x + legend_text_padding}" y="{row_y + 12}" font-size="12" fill="#1a1a1a">{html.escape(label)}</text>'
            )
            legend_x += legend_swatch_width + legend_text_padding + len(label) * 7 + legend_item_spacing

    parts.append(
        f'<text x="{left_margin}" y="{height - 8}" font-size="12" fill="#555">{html.escape(x_label)}</text>'
    )
    parts.append("</svg></section>")
    return "".join(parts)
