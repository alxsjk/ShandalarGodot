extends GutTest
## The opening toss is fair, measured — the owner's playtest (2026-09-18):
## *"I have subjective feeling that opponent wins most coin tosses. Please
## examine this is truly random!"*
##
## The roll is `game.rng.randi() % 2` in DuelScreen._new_game, on the
## game's own PCG32 seeded with the duel seed, after the two libraries
## are shuffled. The duel seed is `randi() | 1` from Godot's global RNG
## (randomised at start-up), or the match/gauntlet screens' own seeded
## RNG — never a counter. This suite replays that shape over thousands of
## seeds and pins the split; the seeds come from a FIXED seeder so the
## measurement is the same every run.

const TRIALS := 3000
const SEEDER := 20260918


static func _deck(size: int) -> Array:
	var out := []
	for i in size:
		out.append("Forest" if i % 2 == 0 else "Grizzly Bears")
	return out


## The production shape: a fresh odd seed, setup (two shuffles), the toss.
static func _toss(seed_value: int, deck0: Array, deck1: Array) -> int:
	var g := MtgGame.new()
	g.setup(deck0, deck1, "A", "B", 20, 20, seed_value)
	return g.rng.randi() % 2


func test_the_toss_is_a_fair_coin_over_thousands_of_duels() -> void:
	# 3000 fair tosses: sigma ~27, so 1350..1650 is more than five sigma
	# either side — a real bias fails here, noise never does.
	var seeder := RandomNumberGenerator.new()
	seeder.seed = SEEDER
	var deck0 := _deck(40)
	var deck1 := _deck(60)
	var seat0 := 0
	var last := -1
	var run := 0
	var longest := 0
	for i in TRIALS:
		var winner := _toss(seeder.randi() | 1, deck0, deck1)
		if winner == 0:
			seat0 += 1
		if winner == last:
			run += 1
		else:
			run = 1
			last = winner
		longest = maxi(longest, run)
	gut.p("toss: seat 0 won %d of %d; longest streak %d" % [seat0, TRIALS, longest])
	assert_between(seat0, 1350, 1650, "seat 0 won %d of %d" % [seat0, TRIALS])
	# Streaks are what a fair coin FEELS like: the longest run of one seat
	# in 3000 tosses is around eleven, and never the "always" a player
	# remembers after three in a row.
	assert_between(longest, 6, 24, "longest streak %d" % longest)


func test_equal_decks_and_the_ante_change_nothing_about_the_split() -> void:
	var seeder := RandomNumberGenerator.new()
	seeder.seed = SEEDER + 1
	var deck := _deck(40)
	var seat0 := 0
	for i in TRIALS:
		var g := MtgGame.new()
		g.setup(deck, deck, "A", "B", 20, 20, seeder.randi() | 1)
		g.stake_ante(0, 1, true)      # the ante draws on the same stream
		g.stake_ante(1, 1, false)
		if g.rng.randi() % 2 == 0:
			seat0 += 1
	assert_between(seat0, 1350, 1650, "seat 0 won %d of %d" % [seat0, TRIALS])


func test_the_toss_is_part_of_the_seeded_stream() -> void:
	# A replayed seed replays its leader — the roll is on game.rng, never
	# on the global RNG (DuelScreen._new_game says so; this pins it).
	var deck0 := _deck(40)
	var deck1 := _deck(40)
	for seed_value in [1, 90210, 4242, 606, 2147483647]:
		assert_eq(_toss(seed_value, deck0, deck1), _toss(seed_value, deck0, deck1),
			"seed %d" % seed_value)
	# And the seeds themselves are not one bit: both seats win.
	var seen := {}
	for seed_value in range(1, 64, 2):
		seen[_toss(seed_value, deck0, deck1)] = true
	assert_eq(seen.size(), 2, "both seats win some")
