from __future__ import annotations

import html

from perf_analyzer.presentation_bundle import PresentationBundle
from perf_analyzer.reporting.renderers.html.sections import (
    build_charts_html,
    build_intro_html,
    build_sampling_notes_html,
    build_summary_cards_html,
    build_tables_html,
)
from perf_analyzer.reporting.renderers.html.template import REPORT_STYLE_BLOCK


__all__ = ["PresentationBundle", "render_html_report"]


def render_html_report(
    presentation_bundle: PresentationBundle,
) -> str:
    presentation = presentation_bundle.presentation

    intro_html = build_intro_html(str(presentation_bundle.metadata.input_csv))
    cards_html = build_summary_cards_html(presentation.summary_cards)
    charts_html = build_charts_html(presentation.charts)
    tables_html = build_tables_html(presentation.tables)
    sampling_notes_html = build_sampling_notes_html(presentation_bundle.metadata.source_periods)

    return f"""
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{html.escape(presentation_bundle.metadata.title)}</title>
  <style>
{REPORT_STYLE_BLOCK}
  </style>
</head>
<body>
  <main>
    <h1>{html.escape(presentation_bundle.metadata.title)}</h1>
    {intro_html}
    {cards_html}
    {charts_html}
    {tables_html}
    {sampling_notes_html}
  </main>
</body>
</html>
"""
