from __future__ import annotations

import html

from perf_analyzer.constants import CORE_CLOCK_PERIOD_PS, PALETTE, SYSTEM_CLOCK_PERIOD_PS
from perf_analyzer.reporting.formatting import format_number, format_percent_display
from perf_analyzer.reporting.models import PresentationChart, PresentationTable, SummaryCard
from perf_analyzer.reporting.renderers.html.charts import (
    build_svg_bar_chart,
    build_svg_grouped_bar_chart,
    build_svg_stacked_bar_chart,
)
from perf_analyzer.reporting.renderers.html.template import INTRO_LEDES, SAMPLING_NOTES_TEMPLATE


def build_intro_html(csv_path: str) -> str:
    return "".join(
        f'<p class="lede">{paragraph.format(csv_path=html.escape(csv_path), system_clock_period_ps=SYSTEM_CLOCK_PERIOD_PS, core_clock_period_ps=CORE_CLOCK_PERIOD_PS).strip()}</p>'
        for paragraph in INTRO_LEDES
    )


def build_summary_cards_html(summary_cards: list[SummaryCard]) -> str:
    cards_html = "".join(
        f'<div class="card"><div class="card-label">{html.escape(card.label)}</div><div class="card-value">{format_number(card.value)}</div></div>'
        for card in summary_cards
    )
    return f'<div class="cards">{cards_html}</div>'


def build_chart_html(chart: PresentationChart) -> str:
    if chart.kind == "bar":
        return build_svg_bar_chart(
            chart.title,
            chart.items,
            bar_color=chart.bar_color or PALETTE["blue"],
            x_label=chart.x_label or "Value",
        )
    if chart.kind == "stacked_bar":
        return build_svg_stacked_bar_chart(chart.title, chart.groups)
    return build_svg_grouped_bar_chart(
        chart.title,
        chart.groups,
        x_label=chart.x_label or "Value",
        value_formatter=format_percent_display if chart.value_format == "percent" else None,
    )


def build_charts_html(charts: list[PresentationChart]) -> str:
    return "\n".join(build_chart_html(chart) for chart in charts)


def build_table_html(table: PresentationTable) -> str:
    header_html = "".join(f"<th>{html.escape(column)}</th>" for column in table.columns)
    rows_html = "".join(
        "<tr>" + "".join(f"<td>{html.escape(str(cell))}</td>" for cell in row) + "</tr>"
        for row in table.rows
    )
    return f"""
    <h2>{html.escape(table.title)}</h2>
    <table>
      <thead>
        <tr>{header_html}</tr>
      </thead>
      <tbody>
        {rows_html}
      </tbody>
    </table>
"""


def build_tables_html(tables: list[PresentationTable]) -> str:
    return "\n".join(build_table_html(table) for table in tables)


def build_period_list_html(source_periods: dict[str, int | None]) -> str:
    return "".join(
        f"<li><strong>{html.escape(source)}</strong>: {period if period is not None else 'n/a'}</li>"
        for source, period in source_periods.items()
    )


def build_sampling_notes_html(source_periods: dict[str, int | None]) -> str:
    return SAMPLING_NOTES_TEMPLATE.format(period_list=build_period_list_html(source_periods))
