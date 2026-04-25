from __future__ import annotations


DF_START_ADDR = 0x40000064
DF_START_BIT = 22
CORE_CYCLE_COUNTER_ADDR = 0x50000014
CORE_STALL_COUNTER_ADDR = 0x50000018
# Perf timestamps are logged in the simulator time units used by $time, which are
# 1000x finer than picoseconds in this environment.
CORE_CLOCK_PERIOD_PS = 2_000_000.0
SYSTEM_CLOCK_PERIOD_PS = 666_000.0
START_SRAMA_MEM_ADDR = 0x70000000
START_SRAMB_MEM_ADDR = 0x80000000
START_SRAMC_MEM_ADDR = 0x90000000
START_SRAMA_LOCAL_ADDR = 0xD0040000
START_SRAMB_LOCAL_ADDR = 0xD0080000
START_SRAMC_LOCAL_ADDR = 0xD00C0000

DEFAULT_OUTPUT_DIR_SUFFIX = "_perf_analysis"

PALETTE = {
    "blue": "#1f77b4",
    "teal": "#2a9d8f",
    "green": "#4daf4a",
    "orange": "#f4a261",
    "red": "#e76f51",
    "gold": "#e9c46a",
    "slate": "#6c757d",
    "charcoal": "#264653",
    "purple": "#7b6dba",
}