from __future__ import annotations


def safe_percent(value: int | float, total: int | float) -> float:
    return (float(value) / float(total) * 100.0) if total else 0.0


def format_number(value: int | float) -> str:
    if isinstance(value, float):
        return f"{value:.2f}"
    return f"{value:,}"


def format_percent_display(value: float) -> str:
    if value == 0:
        return "0.00%"
    magnitude = abs(value)
    if magnitude >= 0.01:
        return f"{value:.2f}%"
    if magnitude >= 0.001:
        return f"{value:.3f}%"
    return f"{value:.4f}%"
