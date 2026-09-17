#!/usr/bin/env python3
"""Deal the GUT test scripts over N processes, the slow ones first.

`run_tests.sh` runs the whole suite as SHARDS headless Godot processes,
one deal of scripts each (its header says why: sixteen minutes in one
process, five in six). This is the deal. It reads the script list on
stdin — one `tests/...` path per line, the order it was found in — and
prints the SHARD-th of SHARDS deals as one comma-joined `-gtest=` value.

Two deals, and the same input gives the same deal on every machine:

* WITHOUT TIMINGS, every SHARDS-th script from the sorted list goes to one
  process. Each directory (ai, cards, ui, unit) is spread evenly, and a
  runner that has never run before (CI) deals the same way as the desk.
* WITH TIMINGS — the JUnit files GUT wrote on the LAST run, given on the
  command line — the longest-known script goes first to the process with
  the least on it (longest-processing-time first). Measured 2026-09-17:
  the round-robin deal of six gave one process 280 s of GUT time and
  another 104 s, because two SGManalink network suites of 93 and 99 s
  landed together; the sum is 1036 s, so a balanced six is 173 s each. A
  script with no timing yet — new, renamed — takes the median of the
  known ones, so it neither sinks nor floats a process.

Only the deal is here. What runs, what is green and what is read from
the logs is `run_tests.sh`'s, and stays there.
"""
from __future__ import annotations

import re
import statistics
import sys
from pathlib import Path

## GUT's JUnit export names a suite by the script's res:// path and
## gives it the sum of its tests' times (addons/gut/junit_xml_export.gd).
SUITE = re.compile(r'<testsuite name="(?:res://)?([^"]+)"[^>]*?\btime="([0-9.]+)"')


def timings(junit_files: list[Path]) -> dict[str, float]:
    """Seconds per script from GUT's JUnit files; a file that is not there
    or not JUnit contributes nothing. The last word on a script wins, so a
    script that moved between deals is counted once."""
    seconds: dict[str, float] = {}
    for junit in junit_files:
        try:
            text = junit.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        for name, took in SUITE.findall(text):
            seconds[name] = float(took)
    return seconds


def round_robin(scripts: list[str], shards: int) -> list[list[str]]:
    """Every SHARDS-th script to one deal, from the list's own order."""
    return [scripts[k::shards] for k in range(shards)]


def longest_first(scripts: list[str], shards: int,
                  seconds: dict[str, float]) -> list[list[str]]:
    """LPT: the longest-known script first, each to the deal with the least
    on it. Unknown scripts weigh the median known script (or one second
    when nothing is known, which is then the round-robin deal in disguise).
    Ties break by name, so the deal is a function of its inputs alone."""
    known = [seconds[s] for s in scripts if s in seconds]
    fallback = statistics.median(known) if known else 1.0
    weight = {s: seconds.get(s, fallback) for s in scripts}
    order = sorted(scripts, key=lambda s: (-weight[s], s))
    deals: list[list[str]] = [[] for _ in range(shards)]
    load = [0.0] * shards
    for script in order:
        k = min(range(shards), key=lambda i: (load[i], i))
        deals[k].append(script)
        load[k] += weight[script]
    # Each deal in the list's own order, so a log reads like the suite does.
    rank = {s: i for i, s in enumerate(scripts)}
    return [sorted(deal, key=rank.__getitem__) for deal in deals]


def deal(scripts: list[str], shards: int, shard: int,
         seconds: dict[str, float] | None = None) -> list[str]:
    """The SHARD-th (1-based) of SHARDS deals of these scripts."""
    if shards < 1 or not 1 <= shard <= shards:
        raise ValueError("shard %d of %d" % (shard, shards))
    deals = longest_first(scripts, shards, seconds) if seconds else round_robin(scripts, shards)
    return deals[shard - 1]


def main(argv: list[str]) -> int:
    if len(argv) < 3:
        sys.stderr.write("usage: deal_tests.py SHARDS SHARD [gut-junit.xml ...] < scripts\n")
        return 2
    shards, shard = int(argv[1]), int(argv[2])
    scripts = [line.strip() for line in sys.stdin if line.strip()]
    seconds = timings([Path(p) for p in argv[3:]])
    try:
        chosen = deal(scripts, shards, shard, seconds)
    except ValueError as error:
        sys.stderr.write("deal_tests.py: no such deal: %s\n" % error)
        return 2
    sys.stdout.write(",".join("res://" + s for s in chosen))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
