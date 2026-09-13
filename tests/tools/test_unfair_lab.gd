extends GutTest


func test_unfair_run_is_explicit_unrated_and_outside_fair_sweeps() -> void:
	var lab: Object = autofree(load("res://DeckLab/simulate.gd").new())
	var base := ["--deck-a", "white_knights.deck", "--deck-b", "big_green.deck"]
	assert_eq(lab.PROFILES, ["apprentice", "magician", "sorcerer", "wizard"])
	var opts: Dictionary = lab._parse_args(PackedStringArray(base + ["--profile-b", "unfair"]))
	assert_false(opts.has("error"))
	assert_true(opts.no_elo)
	assert_true(lab._pilot(0, "unfair") is UnfairPlayer)
	assert_true(lab._pilot(1, "unfair") is UnfairPlayer)
	assert_false(lab._pilot(0, "wizard") is UnfairPlayer)
	assert_eq(lab._pilot(1, "unfair").pid, 1)
	var sweep: Dictionary = lab._parse_args(PackedStringArray(base + ["--profile-a", "unfair", "--sweep", "values_context=on,off"]))
	assert_string_contains(sweep.error, "fair profile sweeps")
	var override: Dictionary = lab._parse_args(PackedStringArray(base + ["--profile-b", "unfair:mistake_chance=0"]))
	assert_true(override.has("error"))
