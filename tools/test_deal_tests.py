"""The deal behind `run_tests.sh`'s shards (tools/deal_tests.py)."""
import io
import tempfile
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest import mock

import deal_tests

SCRIPTS = ["tests/ai/test_a.gd", "tests/ai/test_b.gd", "tests/cards/test_c.gd",
           "tests/ui/test_d.gd", "tests/ui/test_e.gd", "tests/unit/test_f.gd",
           "tests/unit/test_g.gd"]

JUNIT = """<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="GutTests" failures="0" tests="9">
<testsuite name="res://tests/ui/test_d.gd" tests="3" failures="0" skipped="0" time="90.5">
<testcase name="test_one" assertions="4" status="pass" classname="x" time="90.5"></testcase>
</testsuite>
<testsuite name="res://tests/ai/test_a.gd" tests="3" failures="0" skipped="0" time="1.25">
</testsuite>
<testsuite name="res://tests/unit/test_g.gd" tests="3" failures="0" skipped="0" time="40">
</testsuite>
</testsuites>
"""


class RoundRobin(unittest.TestCase):
    def test_every_script_is_dealt_exactly_once(self):
        deals = [deal_tests.deal(SCRIPTS, 3, k) for k in (1, 2, 3)]
        self.assertEqual(sorted(sum(deals, [])), sorted(SCRIPTS))
        self.assertEqual([len(d) for d in deals], [3, 2, 2])

    def test_every_third_script_from_the_lists_own_order(self):
        self.assertEqual(deal_tests.deal(SCRIPTS, 3, 1),
                         ["tests/ai/test_a.gd", "tests/ui/test_d.gd", "tests/unit/test_g.gd"])
        self.assertEqual(deal_tests.deal(SCRIPTS, 3, 2),
                         ["tests/ai/test_b.gd", "tests/ui/test_e.gd"])

    def test_one_shard_is_the_whole_suite(self):
        self.assertEqual(deal_tests.deal(SCRIPTS, 1, 1), SCRIPTS)

    def test_a_shard_outside_the_deal_is_refused(self):
        with self.assertRaises(ValueError):
            deal_tests.deal(SCRIPTS, 3, 4)
        with self.assertRaises(ValueError):
            deal_tests.deal(SCRIPTS, 3, 0)


class LongestFirst(unittest.TestCase):
    def setUp(self):
        self.seconds = {"tests/ui/test_d.gd": 90.5, "tests/ai/test_a.gd": 1.25,
                        "tests/unit/test_g.gd": 40.0}

    def test_the_slowest_scripts_never_share_a_deal(self):
        deals = [deal_tests.deal(SCRIPTS, 3, k, self.seconds) for k in (1, 2, 3)]
        self.assertEqual(sorted(sum(deals, [])), sorted(SCRIPTS))
        homes = {s: k for k, d in enumerate(deals) for s in d}
        self.assertNotEqual(homes["tests/ui/test_d.gd"], homes["tests/unit/test_g.gd"])

    def test_the_loads_are_balanced_and_unknown_scripts_weigh_the_median(self):
        # Median of the known three is 40: four unknown scripts at 40 each.
        deals = [deal_tests.deal(SCRIPTS, 2, k, self.seconds) for k in (1, 2)]
        weight = lambda s: self.seconds.get(s, 40.0)
        loads = [sum(weight(s) for s in d) for d in deals]
        # Longest first: d (90.5) opens deal one; b, c, e (40 each) fill
        # deal two to 120; f (40) goes to the lighter deal one (130.5); g
        # (40) to deal two (160); a (1.25) to deal one (131.75). The
        # round-robin deal of the same list is 172.75 against 119.
        self.assertEqual(sorted(loads), [131.75, 160.0])

    def test_a_deal_keeps_the_suites_own_order(self):
        for k in (1, 2, 3):
            dealt = deal_tests.deal(SCRIPTS, 3, k, self.seconds)
            self.assertEqual(dealt, sorted(dealt, key=SCRIPTS.index))

    def test_the_same_inputs_give_the_same_deal(self):
        first = [deal_tests.deal(SCRIPTS, 3, k, self.seconds) for k in (1, 2, 3)]
        again = [deal_tests.deal(SCRIPTS, 3, k, dict(reversed(list(self.seconds.items()))))
                 for k in (1, 2, 3)]
        self.assertEqual(first, again)

    def test_no_timings_at_all_is_the_round_robin_deal(self):
        for k in (1, 2, 3):
            self.assertEqual(deal_tests.deal(SCRIPTS, 3, k, {}), deal_tests.deal(SCRIPTS, 3, k))


class Timings(unittest.TestCase):
    def test_guts_junit_is_read_by_script_path(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "gut-junit.xml"
            path.write_text(JUNIT, encoding="utf-8")
            seconds = deal_tests.timings([path, Path(tmp) / "missing.xml"])
        self.assertEqual(seconds, {"tests/ui/test_d.gd": 90.5, "tests/ai/test_a.gd": 1.25,
                                   "tests/unit/test_g.gd": 40.0})

    def test_a_file_that_is_not_junit_contributes_nothing(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "gut.log"
            path.write_text("* test_something\n", encoding="utf-8")
            self.assertEqual(deal_tests.timings([path]), {})


class CommandLine(unittest.TestCase):
    def test_it_prints_one_gtest_value(self):
        out = io.StringIO()
        with mock.patch("sys.stdin", io.StringIO("\n".join(SCRIPTS) + "\n")), redirect_stdout(out):
            status = deal_tests.main(["deal_tests.py", "3", "2"])
        self.assertEqual(status, 0)
        self.assertEqual(out.getvalue(), "res://tests/ai/test_b.gd,res://tests/ui/test_e.gd")

    def test_too_few_arguments_is_a_usage_error(self):
        with mock.patch("sys.stderr", io.StringIO()):
            self.assertEqual(deal_tests.main(["deal_tests.py", "3"]), 2)

    def test_a_shard_past_the_last_is_a_usage_error_not_a_traceback(self):
        # The shell wrapper reads exit 2 and an EMPTY stdout as "could not
        # deal"; a traceback on stdout would have become a -gtest= value.
        out, err = io.StringIO(), io.StringIO()
        with mock.patch("sys.stdin", io.StringIO("\n".join(SCRIPTS) + "\n")), \
                redirect_stdout(out), mock.patch("sys.stderr", err):
            status = deal_tests.main(["deal_tests.py", "3", "7"])
        self.assertEqual(status, 2)
        self.assertEqual(out.getvalue(), "")
        self.assertIn("shard 7 of 3", err.getvalue())


if __name__ == "__main__":
    unittest.main()
