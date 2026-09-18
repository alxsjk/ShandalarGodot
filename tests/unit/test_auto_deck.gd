extends GutTest
## AUTODECK'S HEAD ([AutoDeck], 2026-09-18): the pools it reads,
## the deck it builds from a pool and a handful of wishes — legal, in the
## colours asked for, the lands the speed asks for, the caps the rules
## set — and the report it writes into the notes. Nothing here opens the
## window; that is `tests/ui/test_auto_deck_window.gd`.


func before_all() -> void:
	CardRegistry.ensure_loaded()


## The whole library, four of everything — the widest pool there is.
func _library() -> Dictionary:
	return AutoDeck.pool_from_names(CardRegistry.all_names())


func _builder(pool: Dictionary, seed := 7) -> AutoDeck:
	var auto := AutoDeck.new()
	auto.pool = pool
	auto.seed = seed
	return auto


func _lands(deck: DeckModel) -> int:
	var n := 0
	for name in deck.names():
		if DeckModel._card(name).is_land():
			n += int(deck.counts[name])
	return n


func _creatures(deck: DeckModel) -> int:
	var n := 0
	for name in deck.names():
		if DeckModel._card(name).is_creature():
			n += int(deck.counts[name])
	return n


## The first-turn castables: non-land cards of mana value 0 or 1.
func _one_drops(deck: DeckModel) -> int:
	var n := 0
	for name in deck.names():
		var data := DeckModel._card(name)
		if not data.is_land() and data.cost.mana_value() <= 1:
			n += int(deck.counts[name])
	return n


func _average_mana(deck: DeckModel) -> float:
	var mana := 0
	var spells := 0
	for name in deck.names():
		var data := DeckModel._card(name)
		if data.is_land():
			continue
		mana += data.cost.mana_value() * int(deck.counts[name])
		spells += int(deck.counts[name])
	return float(mana) / maxi(spells, 1)


## Every non-land card is castable in the deck's colours and comes from
## the pool, no card is over the copy limit, and the basics are basics.
func _assert_legal(deck: DeckModel, auto: AutoDeck, size: int) -> void:
	assert_eq(deck.total(), size, "the size asked for")
	assert_eq(deck.side_total(), 0, "no sideboard")
	var limit := DeckModel.duplicates_allowed(size)
	for name in deck.names():
		var data := DeckModel._card(name)
		assert_not_null(data, name)
		if AutoDeck.BASICS.has(name):
			continue
		assert_true(auto.pool.has(name), "%s is in the pool" % name)
		assert_true(int(deck.counts[name]) <= mini(limit, int(auto.pool[name])),
			"%d %s within the pool's %d and the rules' %d" % [
				int(deck.counts[name]), name, int(auto.pool[name]), limit])
		assert_true(AutoDeck.castable(data, auto.chosen_colors),
			"%s is castable in %s" % [name, AutoDeck.color_phrase(auto.chosen_colors)])


# ------------------------------------------------------------ the pools --

func test_a_pool_of_names_leaves_out_basics_and_strangers() -> void:
	var pool := AutoDeck.pool_from_names(["Lightning Bolt", "Plains", "Not A Card", "Serra Angel"], 3)
	assert_eq(pool, {"Lightning Bolt": 3, "Serra Angel": 3})
	assert_eq(AutoDeck.pool_total(pool), 6)
	assert_eq(AutoDeck.pool_from_counts({"Terror": 2, "Island": 9, "Terror ": 0, "Nope": 4}), {"Terror": 2})


func test_a_set_pool_is_the_registry_s_own_membership() -> void:
	var pool := AutoDeck.pool_from_sets(["4ed"])
	assert_gt(pool.size(), 100, "Fourth Edition is a big set (149 names with the card packs off)")
	for name in pool:
		assert_true(CardRegistry.card_in_set(name, "4ed", true, true), "%s is in 4ed" % name)
		assert_false(AutoDeck.BASICS.has(name), "no basic in a pool")
		assert_eq(int(pool[name]), 4, "four of each")
	var two := AutoDeck.pool_from_sets(["4ed", "drk"])
	assert_gt(two.size(), pool.size(), "two sets are more than one")
	assert_eq(AutoDeck.pool_from_sets([]), {}, "no set, no pool")


func test_a_text_pool_reads_deck_lines_sideboard_and_all() -> void:
	var report: Array = []
	var pool := AutoDeck.pool_from_text(
		"# my pool\n4 Lightning Bolt\n2x Serra Angel\nSB: 1 Terror\n1 Lightning Bolt\n3 Nothing Of The Sort\n", report)
	assert_eq(pool, {"Lightning Bolt": 5, "Serra Angel": 2, "Terror": 1},
		"main and sideboard lines count together; the stranger is left out")
	assert_eq(report.size(), 1)
	assert_eq(String(report[0]), "1 name the game does not have: Nothing Of The Sort")
	report.clear()
	assert_eq(AutoDeck.pool_from_text("Lightning Bolt\nSerra Angel", report), {},
		"a line without a count is not a card line: the pool is empty")
	assert_false(report.is_empty(), "and the reason is reported")
	assert_true(String(report[0]).begins_with("line 1:"), String(report[0]))


func test_the_pool_becomes_a_sealed_pool_with_free_basics() -> void:
	var auto := _builder({"Lightning Bolt": 4, "Serra Angel": 2})
	auto.size = 40
	var pool := auto.to_sealed_pool()
	assert_eq(pool.copies_of("Lightning Bolt"), 4)
	assert_eq(pool.copies_of("Serra Angel"), 2)
	for land in AutoDeck.BASICS:
		assert_eq(pool.copies_of(land), 40, "%s, as many as the deck is big" % land)
	assert_eq(pool.packs.size(), 1)
	assert_eq(String(pool.packs[0]["title"]), "AutoDeck")
	assert_eq(pool.total(), 6 + 5 * 40)
	assert_eq(auto.to_sealed_pool(60).copies_of("Plains"), 60, "or more, when asked")


# ------------------------------------------------------------ the build --

func test_sixty_from_the_library_is_legal_and_two_coloured() -> void:
	var auto := _builder(_library())
	var deck := auto.build()
	_assert_legal(deck, auto, 60)
	assert_eq(_lands(deck), int(AutoDeck.LANDS[60][AutoDeck.SPEED_MEDIUM]), "medium: 24 lands")
	assert_eq(AutoDeck._count_colors(auto.chosen_colors), 2, "the builder's own choice is two colours")
	assert_eq(auto.short_by, 0, "the library never runs short")
	assert_eq(deck.deck_name, auto.deck_name())
	assert_true(deck.deck_name.ends_with(" Midrange"), deck.deck_name)
	assert_true(deck.notes.begins_with("Built by AutoDeck: 60 cards, "), deck.notes)
	assert_true(deck.notes.contains("Card pool: the library (%d cards on offer)." % AutoDeck.pool_total(auto.pool)))
	assert_true(deck.notes.contains("24 lands: "), deck.notes)
	assert_true(deck.notes.contains("36 spells: "), deck.notes)
	assert_true(deck.notes.contains("Seed 7: the same pool and wishes build this deck again."), deck.notes)
	assert_false(deck.notes.contains("ran out"), "no ran-short line")
	assert_false(deck.notes.contains("Built around"), "nothing was kept")
	assert_false(deck.notes.contains("without the tournament rules"))
	assert_true(deck.notes.contains("The Power Nine left out: the switch is off."),
		"the library holds them; the notes say why none is in (2026-09-18): " + deck.notes)
	assert_eq(auto.report.size(), 6)


func test_forty_from_a_set_is_legal_with_three_of_a_card() -> void:
	var auto := _builder(AutoDeck.pool_from_sets(["4ed"]))
	auto.size = 40
	var deck := auto.build()
	_assert_legal(deck, auto, 40)
	assert_eq(_lands(deck), int(AutoDeck.LANDS[40][AutoDeck.SPEED_MEDIUM]), "medium: 16 lands in 40")
	for name in deck.names():
		if not AutoDeck.BASICS.has(name):
			assert_true(int(deck.counts[name]) <= 3, "%s: three copies at most in 40 (manual ch.10)" % name)
	assert_true(deck.notes.begins_with("Built by AutoDeck: 40 cards, "), deck.notes)


func test_the_colours_asked_for_are_the_deck_s() -> void:
	var auto := _builder(_library())
	auto.colors = Mtg.ManaColor.U | Mtg.ManaColor.B
	var deck := auto.build()
	assert_eq(auto.chosen_colors, Mtg.ManaColor.U | Mtg.ManaColor.B, "both, and no third")
	_assert_legal(deck, auto, 60)
	assert_true(deck.deck_name.begins_with("Blue-Black "), deck.deck_name)
	for land in ["Plains", "Mountain", "Forest"]:
		assert_eq(deck.count_of(land), 0, "no %s in a blue-black deck" % land)
	assert_true(deck.count_of("Island") >= 2 and deck.count_of("Swamp") >= 2,
		"each colour with pips gets at least two basics")
	# One colour asked for and one allowed: mono.
	auto.colors = Mtg.ManaColor.G
	auto.max_colors = 1
	deck = auto.build()
	assert_eq(auto.chosen_colors, Mtg.ManaColor.G)
	assert_true(deck.deck_name.begins_with("Mono-Green "), deck.deck_name)
	_assert_legal(deck, auto, 60)
	assert_eq(deck.count_of("Forest"), _lands(deck) - _nonbasics(deck), "the basics are all Forests")


func _nonbasics(deck: DeckModel) -> int:
	var n := 0
	for name in deck.names():
		if DeckModel._card(name).is_land() and not AutoDeck.BASICS.has(name):
			n += int(deck.counts[name])
	return n


func test_asking_for_three_colours_widens_the_cap() -> void:
	var auto := _builder(_library())
	auto.colors = Mtg.ManaColor.W | Mtg.ManaColor.R | Mtg.ManaColor.G
	auto.max_colors = 1
	var deck := auto.build()
	assert_eq(auto.chosen_colors, Mtg.ManaColor.W | Mtg.ManaColor.R | Mtg.ManaColor.G,
		"the colours asked for always win over the cap")
	_assert_legal(deck, auto, 60)
	assert_true(deck.deck_name.begins_with("White-Red-Green "), deck.deck_name)


func test_the_speed_sets_the_lands_and_the_curve() -> void:
	var fast := _builder(_library())
	fast.speed = AutoDeck.SPEED_FAST
	var fast_deck := fast.build()
	var slow := _builder(_library())
	slow.speed = AutoDeck.SPEED_SLOW
	var slow_deck := slow.build()
	_assert_legal(fast_deck, fast, 60)
	_assert_legal(slow_deck, slow, 60)
	assert_eq(_lands(fast_deck), 22, "fast: 22 lands in 60")
	assert_eq(_lands(slow_deck), 25, "slow: 25 lands in 60")
	assert_lt(_average_mana(fast_deck), _average_mana(slow_deck),
		"the fast deck's spells are cheaper: %.2f against %.2f" % [
			_average_mana(fast_deck), _average_mana(slow_deck)])
	assert_lt(_average_mana(fast_deck), 2.5, "a fast deck lives at one and two")
	assert_gt(_average_mana(slow_deck), 3.2, "a slow deck reaches for the big spells")
	# The speed is the cost of the creatures and the spells (2026-09-18):
	# a fast deck is full of first-turn castables, a slow deck nearly
	# without — the curve is held firmly, not nudged.
	var medium := _builder(_library())
	var medium_deck := medium.build()
	assert_gte(_one_drops(fast_deck), 10, "fast: three in ten of 38 spells cost one, got %d" % _one_drops(fast_deck))
	assert_lte(_one_drops(slow_deck), 3, "slow: hardly any one-drops, got %d" % _one_drops(slow_deck))
	assert_gt(_one_drops(fast_deck), _one_drops(medium_deck), "fast has more one-drops than medium")
	assert_gt(_one_drops(medium_deck), _one_drops(slow_deck), "medium has more than slow")
	assert_between(_average_mana(medium_deck), 2.6, 3.2, "medium sits between")
	fast.size = 40
	var fast_forty := fast.build()
	assert_eq(_lands(fast_forty), 15, "fast: 15 lands in 40")
	assert_gte(_one_drops(fast_forty), 7, "and the curve scales with the size: %d one-drops" % _one_drops(fast_forty))
	slow.size = 40
	var slow_forty := slow.build()
	assert_eq(_lands(slow_forty), 17, "slow: 17 lands in 40")
	assert_lte(_one_drops(slow_forty), 2, "slow: %d one-drops in 40" % _one_drops(slow_forty))


func test_the_lean_sets_the_creature_share() -> void:
	var shares := {}
	for lean in AutoDeck.LEANS:
		var auto := _builder(_library())
		auto.lean = lean
		var deck := auto.build()
		_assert_legal(deck, auto, 60)
		shares[lean] = float(_creatures(deck)) / (60 - _lands(deck))
	assert_gt(float(shares[AutoDeck.LEAN_CREATURES]), float(shares[AutoDeck.LEAN_BALANCED]),
		"more creatures: %s" % str(shares))
	assert_gt(float(shares[AutoDeck.LEAN_BALANCED]), float(shares[AutoDeck.LEAN_SPELLS]),
		"more spells: %s" % str(shares))
	assert_almost_eq(float(shares[AutoDeck.LEAN_CREATURES]), 0.70, 0.12, "about seven in ten")
	assert_almost_eq(float(shares[AutoDeck.LEAN_SPELLS]), 0.38, 0.12, "under four in ten")


## The tiers of a deck's non-basic cards, `tier -> copies`.
func _tiers(deck: DeckModel) -> Dictionary:
	var out := {}
	for name in deck.names():
		if AutoDeck.BASICS.has(name):
			continue
		var tier := DeckStats.rarity_tier(DeckModel._card(name))
		out[tier] = int(out.get(tier, 0)) + int(deck.counts[name])
	return out


## The rarity wish is a floor and a ceiling (2026-09-18): commons only,
## no rares, uncommons and up, rares and legends only.
func test_the_rarity_wish_holds() -> void:
	var commons := _builder(_library())
	commons.rarity = AutoDeck.RARITY_PAUPER
	var deck := commons.build()
	_assert_legal(deck, commons, 60)
	var tiers := _tiers(deck)
	for tier in tiers:
		assert_true(tier == "common" or tier == "", "a pauper deck: %s" % str(tiers))
	assert_true(deck.notes.contains("Rarity: commons only."), deck.notes)
	var uncommons := _builder(_library())
	uncommons.rarity = AutoDeck.RARITY_NO_RARES
	deck = uncommons.build()
	tiers = _tiers(deck)
	assert_false(tiers.has("rare") or tiers.has("legendary"), "no rares, no legends: %s" % str(tiers))
	assert_true(tiers.has("uncommon"), "the uncommons are allowed in: %s" % str(tiers))
	assert_true(deck.notes.contains("Rarity: no rares, no legends."), deck.notes)
	var uncommon_up := _builder(_library())
	uncommon_up.rarity = AutoDeck.RARITY_UNCOMMON_UP
	deck = uncommon_up.build()
	_assert_legal(deck, uncommon_up, 60)
	tiers = _tiers(deck)
	assert_false(tiers.has("common") or tiers.has(""), "uncommon up: no commons in %s" % str(tiers))
	assert_true(tiers.has("uncommon") and tiers.has("rare"), "uncommons and rares both: %s" % str(tiers))
	assert_eq(uncommon_up.short_by, 0, "the library has uncommons enough")
	assert_true(deck.notes.contains("Rarity: uncommons, rares and legends."), deck.notes)
	var rares := _builder(_library())
	rares.rarity = AutoDeck.RARITY_RARES
	deck = rares.build()
	_assert_legal(deck, rares, 60)
	tiers = _tiers(deck)
	for tier in tiers:
		assert_true(tier == "rare" or tier == "legendary", "only rares: %s" % str(tiers))
	assert_true(tiers.has("rare"), "and there are rares: %s" % str(tiers))
	assert_eq(rares.short_by, 0, "the library has rares enough for sixty")
	assert_true(deck.notes.contains("Rarity: rares and legends only."), deck.notes)
	# The old ceiling words still read, and a stranger falls back to any.
	var odd := _builder({"Lightning Bolt": 4})
	odd.rarity = "mythic"
	odd.build()
	assert_eq(odd.rarity, AutoDeck.RARITY_ANY)
	assert_eq(AutoDeck.RARITY_PAUPER, "common", "the saved words of the first release")
	assert_eq(AutoDeck.RARITY_NO_RARES, "uncommon")


func test_the_tournament_rules_bar_the_banned_and_cap_the_restricted() -> void:
	var pool := {"Contract from Below": 4, "Black Lotus": 4, "Lightning Bolt": 4, "Hypnotic Specter": 4}
	var auto := _builder(pool)
	auto.colors = Mtg.ManaColor.B | Mtg.ManaColor.R
	auto.power_nine = true   # the Lotus is one of the nine (2026-09-18)
	var deck := auto.build()
	_assert_legal(deck, auto, 60)
	assert_eq(deck.count_of("Contract from Below"), 0, "banned")
	assert_eq(deck.count_of("Black Lotus"), 1, "restricted: one")
	assert_eq(deck.count_of("Lightning Bolt"), 4)
	assert_eq(deck.count_of("Hypnotic Specter"), 4)
	assert_eq(auto.short_by, 36 - 9, "the rest of the spells are missing")
	assert_eq(_lands(deck), 24 + 27, "and basics fill the deck")
	assert_true(deck.notes.contains("The pool ran out after 9 spells; 27 extra basic lands fill the deck."), deck.notes)
	auto.tournament = false
	deck = auto.build()
	assert_eq(deck.count_of("Contract from Below"), 4, "allowed without the rules")
	assert_eq(deck.count_of("Black Lotus"), 4)
	assert_true(deck.notes.contains("Built without the tournament rules: banned and restricted cards were allowed."), deck.notes)


func test_a_legend_comes_twice_at_most() -> void:
	var auto := _builder({"Tetsuo Umezawa": 4, "Lightning Bolt": 4})
	auto.colors = Mtg.ManaColor.U | Mtg.ManaColor.B | Mtg.ManaColor.R
	var deck := auto.build()
	_assert_legal(deck, auto, 60)
	assert_eq(deck.count_of("Tetsuo Umezawa"), AutoDeck.LEGEND_CAP, "one in play at a time")
	assert_eq(deck.count_of("Lightning Bolt"), 4)
	assert_true(deck.count_of("Island") >= 2 and deck.count_of("Swamp") >= 2 and deck.count_of("Mountain") >= 2,
		"the three colours each get their two basics: %s" % str(deck.counts))


func test_the_kept_cards_go_in_first_and_set_the_colours() -> void:
	var keep := DeckModel.new()
	for i in 4:
		keep.add("Lightning Bolt")
	keep.add("Serra Angel")
	keep.add("Serra Angel")
	keep.add("Plains")
	var auto := _builder(_library())
	auto.keep = keep
	var deck := auto.build()
	_assert_legal(deck, auto, 60)
	assert_eq(auto.chosen_colors, Mtg.ManaColor.W | Mtg.ManaColor.R, "the kept cards' colours")
	assert_eq(deck.count_of("Lightning Bolt"), 4)
	assert_eq(deck.count_of("Serra Angel"), 2)
	assert_true(deck.notes.contains("Built around the 6 cards already on the surface."), deck.notes)
	assert_eq(_lands(deck), 24, "the kept Plains is not counted; the lands are laid fresh")


func test_a_seed_is_a_deck() -> void:
	var one := _builder(_library(), 1234).build()
	var again := _builder(_library(), 1234).build()
	assert_eq(again.counts, one.counts, "same seed, same deck")
	assert_eq(again.notes, one.notes)
	var other := _builder(_library(), 4321)
	other.build()
	assert_eq(other.roll, 4321, "the roll is the seed given")
	var fresh := _builder(_library(), 0)
	fresh.build()
	assert_true(fresh.roll >= 1 and fresh.roll <= 999_999, "a fresh roll when none is given: %d" % fresh.roll)
	assert_true(fresh.report[fresh.report.size() - 1].begins_with("Seed %d:" % fresh.roll))


func test_an_empty_pool_builds_lands_and_says_so() -> void:
	var auto := _builder({})
	auto.colors = Mtg.ManaColor.R
	var deck := auto.build()
	assert_eq(deck.total(), 60)
	assert_eq(deck.count_of("Mountain"), 60, "the colour asked for, evenly")
	assert_eq(auto.short_by, 36)
	assert_true(deck.notes.contains("The pool ran out after 0 spells; 36 extra basic lands fill the deck."), deck.notes)
	auto.colors = 0
	deck = auto.build()
	assert_eq(deck.total(), 60, "and with no colour asked for, still a deck")


func test_a_bad_size_falls_back_to_sixty() -> void:
	var auto := _builder(_library())
	auto.size = 53
	auto.max_colors = 9
	auto.land_kind = "snow"
	var deck := auto.build()
	assert_eq(auto.size, 60)
	assert_eq(auto.max_colors, 5, "five colours at most")
	assert_eq(auto.land_kind, AutoDeck.LANDS_CLASSIC, "a land kind the builder does not know is classic")
	assert_eq(deck.total(), 60)


func test_five_colours_when_asked_for() -> void:
	var auto := _builder(_library())
	auto.colors = Mtg.ManaColor.W | Mtg.ManaColor.U | Mtg.ManaColor.B | Mtg.ManaColor.R | Mtg.ManaColor.G
	var deck := auto.build()
	assert_eq(auto.chosen_colors, auto.colors, "all five")
	_assert_legal(deck, auto, 60)
	assert_true(deck.deck_name.begins_with("White-Blue-Black-Red-Green "), deck.deck_name)
	for land in AutoDeck.BASICS:
		assert_gte(deck.count_of(land), 2, "%s: every colour with pips gets at least two" % land)
	assert_eq(_lands(deck), 24)
	# At most five with nothing ticked: the builder may still settle on
	# fewer — the per-colour discount is what keeps a deep pool from
	# always ending five colours — but never on more.
	var free := _builder(_library())
	free.max_colors = 5
	deck = free.build()
	assert_lte(AutoDeck._count_colors(free.chosen_colors), 5)
	_assert_legal(deck, free, 60)
	# Four colours asked for and a cap of one: the cap widens.
	var four := _builder(_library())
	four.colors = Mtg.ManaColor.W | Mtg.ManaColor.U | Mtg.ManaColor.B | Mtg.ManaColor.R
	four.max_colors = 1
	four.build()
	assert_eq(four.chosen_colors, four.colors)


## A gold deck (2026-09-18): multicoloured cards get [constant
## AutoDeck.GOLD_BONUS] on their worth, so the colour choice and the
## fill reach for them; and it is two colours at least.
func _gold_cards(deck: DeckModel) -> int:
	var n := 0
	for name in deck.names():
		if AutoDeck.is_gold(DeckModel._card(name)):
			n += int(deck.counts[name])
	return n


func test_a_gold_deck_prefers_multicoloured_cards() -> void:
	assert_true(AutoDeck.is_gold(_card("Tetsuo Umezawa")), "three colours")
	assert_true(AutoDeck.is_gold(_card("Marsh Goblins")), "two")
	assert_false(AutoDeck.is_gold(_card("Lightning Bolt")), "one")
	assert_false(AutoDeck.is_gold(_card("Black Lotus")), "none")
	var plain := _builder(_library())
	plain.colors = Mtg.ManaColor.U | Mtg.ManaColor.B
	var plain_deck := plain.build()
	var gold := _builder(_library())
	gold.colors = Mtg.ManaColor.U | Mtg.ManaColor.B
	gold.gold = true
	var gold_deck := gold.build()
	_assert_legal(gold_deck, gold, 60)
	assert_gt(_gold_cards(gold_deck), _gold_cards(plain_deck),
		"the gold deck holds more gold cards: %d against %d" % [_gold_cards(gold_deck), _gold_cards(plain_deck)])
	assert_gte(_gold_cards(gold_deck), 6,
		"the blue-black legends of Legends, all five-drops and up, two of each: %d" % _gold_cards(gold_deck))
	# Colours of its own choosing, the gold deck goes where the gold
	# cards are — red-green in the library, Scarwood Goblins and the
	# legends of the mountain.
	var free := _builder(_library())
	free.gold = true
	var free_deck := free.build()
	_assert_legal(free_deck, free, 60)
	assert_gte(_gold_cards(free_deck), 10, "%s: %d gold" % [free_deck.deck_name, _gold_cards(free_deck)])
	assert_true(gold_deck.notes.contains("A gold deck: multicoloured cards preferred; %d of the 36 spells are gold." % _gold_cards(gold_deck)),
		gold_deck.notes)
	assert_false(plain_deck.notes.contains("A gold deck"), plain_deck.notes)
	var goblins := _card("Marsh Goblins")
	assert_almost_eq(gold.worth(goblins), plain.worth(goblins) + AutoDeck.GOLD_BONUS, 0.001, "the bonus")
	assert_eq(gold.worth(_card("Lightning Bolt")), plain.worth(_card("Lightning Bolt")), "and none for a plain card")
	assert_eq(gold.score(goblins), plain.score(goblins), "the score is the card's own")
	# Mono-coloured and gold cannot both be: two colours at least.
	var mono := _builder(_library())
	mono.max_colors = 1
	mono.gold = true
	mono.build()
	assert_eq(mono.max_colors, 2)
	assert_gte(AutoDeck._count_colors(mono.chosen_colors), 2, "a gold deck is never mono")
	# Even from a pool with no gold card in it — Fourth Edition has none
	# — and the notes say so.
	var none := _builder(AutoDeck.pool_from_sets(["4ed"]))
	none.gold = true
	none.rarity = AutoDeck.RARITY_RARES
	var none_deck := none.build()
	assert_eq(AutoDeck._count_colors(none.chosen_colors), 2, "two colours, not mono-red: %s" % none_deck.deck_name)
	assert_eq(_gold_cards(none_deck), 0)
	assert_true(none_deck.notes.contains("A gold deck: multicoloured cards preferred, but the pool had none the deck could cast."),
		none_deck.notes)


## The Power Nine (2026-09-18, the owner's playtest): a switch of their
## own, off by default. Off, the builder avoids all nine even from a
## pool that holds them; on, it puts the Lotus and the five Moxen in
## every deck and the blue three in a blue deck, one copy each under the
## tournament rules, and the notes say which.
func _power_cards(deck: DeckModel) -> Dictionary:
	var out := {}
	for name in AutoDeck.POWER_NINE:
		if deck.count_of(name) > 0:
			out[name] = deck.count_of(name)
	return out


func test_the_power_nine_are_avoided_unless_asked_for() -> void:
	var unlimited := AutoDeck.pool_from_sets(["2ed"])
	for name in AutoDeck.POWER_NINE:
		assert_true(unlimited.has(name), "Unlimited holds %s" % name)
	var plain := _builder(unlimited)
	plain.colors = Mtg.ManaColor.U | Mtg.ManaColor.R
	assert_false(plain.power_nine, "off by default")
	var plain_deck := plain.build()
	_assert_legal(plain_deck, plain, 60)
	assert_eq(_power_cards(plain_deck), {}, "not one of the nine")
	assert_true(plain_deck.notes.contains("The Power Nine left out: the switch is off."), plain_deck.notes)
	# On, in a blue deck: all nine, one copy each.
	var blue := _builder(unlimited)
	blue.colors = Mtg.ManaColor.U | Mtg.ManaColor.R
	blue.power_nine = true
	var blue_deck := blue.build()
	_assert_legal(blue_deck, blue, 60)
	var all_nine := {}
	for name in AutoDeck.POWER_NINE:
		all_nine[name] = 1
	assert_eq(_power_cards(blue_deck), all_nine, "all nine, once each under the tournament rules")
	assert_true(blue_deck.notes.contains("The Power Nine in play: Black Lotus, Mox Pearl, Mox Sapphire, Mox Jet, "
		+ "Mox Ruby, Mox Emerald, Ancestral Recall, Time Walk, Timetwister."), blue_deck.notes)
	assert_false(blue_deck.notes.contains("left out"), blue_deck.notes)
	# On, in a deck without blue: the Lotus and the Moxen — every Mox,
	# an off-colour one still pays the colourless part of a cost.
	var green := _builder(unlimited)
	green.colors = Mtg.ManaColor.R | Mtg.ManaColor.G
	green.power_nine = true
	var green_deck := green.build()
	_assert_legal(green_deck, green, 60)
	assert_eq(_power_cards(green_deck), {"Black Lotus": 1, "Mox Pearl": 1, "Mox Sapphire": 1,
		"Mox Jet": 1, "Mox Ruby": 1, "Mox Emerald": 1}, "the mana six; the blue three need blue")
	assert_true(green_deck.notes.contains("The Power Nine in play: Black Lotus, Mox Pearl, Mox Sapphire, Mox Jet, Mox Ruby, Mox Emerald."),
		green_deck.notes)
	# The bonus on their worth, and only theirs.
	var lotus := _card("Black Lotus")
	assert_almost_eq(blue.worth(lotus), plain.worth(lotus) + AutoDeck.POWER_BONUS, 0.001, "the bonus")
	assert_eq(blue.worth(_card("Lightning Bolt")), plain.worth(_card("Lightning Bolt")), "and none for a plain card")
	assert_eq(blue.score(lotus), plain.score(lotus), "the score is the card's own")
	# The pool must hold them: Fourth Edition has none.
	var fourth := _builder(AutoDeck.pool_from_sets(["4ed"]))
	fourth.colors = Mtg.ManaColor.U | Mtg.ManaColor.R
	fourth.power_nine = true
	var fourth_deck := fourth.build()
	_assert_legal(fourth_deck, fourth, 60)
	assert_eq(_power_cards(fourth_deck), {})
	assert_true(fourth_deck.notes.contains("The Power Nine asked for, but the pool, the rarity wish and the colours allowed none."),
		fourth_deck.notes)
	# And the rarity wish still holds: a pauper deck has no rares.
	var pauper := _builder(unlimited)
	pauper.colors = Mtg.ManaColor.U | Mtg.ManaColor.R
	pauper.power_nine = true
	pauper.rarity = AutoDeck.RARITY_PAUPER
	var pauper_deck := pauper.build()
	_assert_legal(pauper_deck, pauper, 60)
	assert_eq(_power_cards(pauper_deck), {}, "rares, all nine")
	assert_true(pauper_deck.notes.contains("The Power Nine asked for, but the pool, the rarity wish and the colours allowed none."),
		pauper_deck.notes)


## Classic lands (2026-09-18) are the five basics alone, whatever the
## pool holds; non-classic lands take the pool's duals and the lands
## with abilities first.
func test_classic_lands_are_the_basics_alone() -> void:
	var pool := AutoDeck.pool_from_sets(["4ed"])
	pool["Taiga"] = 4
	var auto := _builder(pool)
	auto.colors = Mtg.ManaColor.R | Mtg.ManaColor.G
	var deck := auto.build()
	_assert_legal(deck, auto, 60)
	assert_eq(auto.land_kind, AutoDeck.LANDS_CLASSIC, "the default")
	assert_eq(_nonbasics(deck), 0, "no Taiga, no Mishra's Factory: %s" % str(deck.counts))
	assert_eq(deck.count_of("Mountain") + deck.count_of("Forest"), 24)
	assert_false(deck.notes.contains("Non-classic"), deck.notes)


func test_non_classic_lands_take_the_duals_and_the_lands_with_abilities_first() -> void:
	var pool := AutoDeck.pool_from_sets(["4ed"])
	pool["Taiga"] = 4
	pool["Tundra"] = 4
	var auto := _builder(pool)
	auto.colors = Mtg.ManaColor.R | Mtg.ManaColor.G
	auto.land_kind = AutoDeck.LANDS_NONCLASSIC
	var deck := auto.build()
	_assert_legal(deck, auto, 60)
	assert_eq(deck.count_of("Taiga"), 4, "the red-green dual, all four")
	assert_eq(deck.count_of("Tundra"), 0, "a white-blue dual makes nothing the deck casts")
	assert_true(_nonbasics(deck) <= int(floor(AutoDeck.NONBASIC_SHARE * 24)),
		"%d non-basic lands within the share" % _nonbasics(deck))
	assert_eq(_lands(deck), 24)
	assert_true(deck.notes.contains("Non-classic lands: %d of the 24 lands are not basics." % _nonbasics(deck)), deck.notes)
	# The whole library, blue-black: the dual first, then the Factory
	# and the Library within the colourless room, the Maze within the
	# room for lands that make no mana, the restricted ones once.
	var wide := _builder(_library())
	wide.colors = Mtg.ManaColor.U | Mtg.ManaColor.B
	wide.land_kind = AutoDeck.LANDS_NONCLASSIC
	deck = wide.build()
	_assert_legal(deck, wide, 60)
	assert_eq(deck.count_of("Underground Sea"), 4, "the blue-black dual, all four")
	assert_gte(deck.count_of("Mishra's Factory"), 1, "the Factory is in: %s" % str(deck.counts))
	assert_eq(deck.count_of("Library of Alexandria"), 1, "restricted: once")
	assert_eq(deck.count_of("Tundra") + deck.count_of("Taiga") + deck.count_of("Karakas"), 0,
		"nothing that makes only colours the deck is not")
	for name in ["Sorrow's Path", "The Tabernacle at Pendrell Vale", "Seafarer's Quay", "Urza's Tower"]:
		assert_eq(deck.count_of(name), 0, "%s is not worth a slot" % name)
	var colorless := 0
	var no_mana := 0
	for name in deck.names():
		var data := DeckModel._card(name)
		if not data.is_land() or AutoDeck.BASICS.has(name):
			continue
		if (AutoDeck.produces(data) & wide.chosen_colors) == 0:
			colorless += int(deck.counts[name])
		if AutoDeck.produces(data) == 0:
			no_mana += int(deck.counts[name])
	assert_lte(colorless, int(AutoDeck.COLORLESS_ROOM[60]), "%d lands making no colour of the deck" % colorless)
	assert_lte(no_mana, int(AutoDeck.NO_MANA_ROOM[60]), "%d lands making no mana" % no_mana)
	assert_lte(_nonbasics(deck), 12, "half the lands at most: %d" % _nonbasics(deck))
	assert_true(deck.count_of("Island") >= 2 and deck.count_of("Swamp") >= 2, "the basics still carry the colours")
	# In forty, the rooms are smaller.
	wide.size = 40
	deck = wide.build()
	_assert_legal(deck, wide, 40)
	colorless = 0
	for name in deck.names():
		var data := DeckModel._card(name)
		if data.is_land() and not AutoDeck.BASICS.has(name) and (AutoDeck.produces(data) & wide.chosen_colors) == 0:
			colorless += int(deck.counts[name])
	assert_lte(colorless, int(AutoDeck.COLORLESS_ROOM[40]))
	assert_lte(_nonbasics(deck), 8, "half of 16: %d" % _nonbasics(deck))


func test_a_land_s_worth_to_the_deck() -> void:
	var auto := _builder({})
	auto.chosen_colors = Mtg.ManaColor.U | Mtg.ManaColor.B
	var sea := auto.land_worth(_card("Underground Sea"))
	assert_almost_eq(sea, 2.5, 0.001, "a dual of the deck's colours: two and a half")
	assert_eq(auto.land_worth(_card("Taiga")), 0.0, "a dual of two other colours is worth nothing to it")
	assert_eq(auto.land_worth(_card("Karakas")), 0.0, "an ability on a colour the deck is not, neither")
	assert_eq(auto.land_worth(_card("Tundra")), AutoDeck.LAND_FLOOR, "an Island with a white side is an Island, no more")
	var city := auto.land_worth(_card("City of Brass"))
	assert_lt(city, sea, "City of Brass in two colours is a dual that hurts: %.2f" % city)
	assert_gt(city, 1.5, "but well worth a slot")
	var factory := auto.land_worth(_card("Mishra's Factory"))
	assert_lt(factory, sea, "the Factory comes after the dual")
	assert_gt(factory, auto.land_worth(_card("Strip Mine")), "and before the Strip Mine")
	assert_gt(auto.land_worth(_card("Strip Mine")), auto.land_worth(_card("Desert")))
	assert_gt(auto.land_worth(_card("Urborg")), 1.0, "a Swamp with abilities is more than a Swamp")
	assert_lt(auto.land_worth(_card("Urborg")), sea)
	var maze := auto.land_worth(_card("Maze of Ith"))
	assert_gte(maze, AutoDeck.LAND_FLOOR, "the Maze makes no mana and is worth a slot: %.2f" % maze)
	assert_lt(maze, factory)
	assert_lt(auto.land_worth(_card("Sorrow's Path")), AutoDeck.LAND_FLOOR, "the Path hurts its owner")
	assert_lt(auto.land_worth(_card("The Tabernacle at Pendrell Vale")), AutoDeck.LAND_FLOOR)
	assert_lt(auto.land_worth(_card("Seafarer's Quay")), AutoDeck.LAND_FLOOR, "a band-land does nothing here")
	assert_lt(auto.land_worth(_card("Urza's Tower")), AutoDeck.LAND_FLOOR, "one Urza's land alone is a colourless land")
	auto.chosen_colors = Mtg.ManaColor.W | Mtg.ManaColor.U | Mtg.ManaColor.B
	assert_gt(auto.land_worth(_card("City of Brass")), auto.land_worth(_card("Underground Sea")),
		"in three colours the City is the best land there is")
	auto.chosen_colors = Mtg.ManaColor.U
	assert_lt(auto.land_worth(_card("City of Brass")), AutoDeck.LAND_FLOOR, "and in one it is an Island that hurts")
	auto.chosen_colors = Mtg.ManaColor.U | Mtg.ManaColor.B
	assert_lt(auto.land_worth(_card("Bazaar of Baghdad")), auto.land_worth(_card("Maze of Ith")))


# ------------------------------------------------------------ the score --

func _card(name: String) -> CardData:
	return CardRegistry.get_card(name)


func test_a_body_per_mana_scores_a_creature() -> void:
	var auto := _builder({})
	var lions := auto.score(_card("Savannah Lions"))
	var bears := auto.score(_card("Grizzly Bears"))
	var wall := auto.score(_card("Wall of Wood"))
	var colossus := auto.score(_card("Colossus of Sardia"))
	assert_gt(lions, bears, "a 2/1 for one beats a 2/2 for two")
	assert_gt(bears, wall, "a defender with no power is worth half its body")
	assert_gt(lions, colossus, "a 9/9 for nine that does not untap is a dead card most games")
	assert_gt(auto.score(_card("Serra Angel")), bears, "flying and vigilance are worth paying for")
	assert_gt(auto.score(_card("Llanowar Elves")), bears,
		"a 1/1 for one with a mana ability beats a bare 2/2 for two")


func test_a_role_scores_a_spell_and_a_narrow_answer_is_marked_down() -> void:
	var auto := _builder({})
	var bolt := auto.score(_card("Lightning Bolt"))
	var terror := auto.score(_card("Terror"))
	var cop := auto.score(_card("Circle of Protection: Red"))
	var shatter := auto.score(_card("Shatter"))
	assert_gt(bolt, 2.0, "burn for one: %.2f" % bolt)
	assert_gt(terror, 2.0, "removal for two: %.2f" % terror)
	assert_gt(bolt, cop, "a Circle of Protection is dead against most decks")
	assert_gt(terror, shatter, "artifact removal is narrower than creature removal")
	assert_gt(shatter, cop, "and colour hate is narrower still")
	assert_eq(auto.score(_card("Lightning Bolt")), bolt, "cached")


## The speed prices the mana value ([constant AutoDeck.TEMPO]) and the
## lean the roles ([constant AutoDeck.LEAN_ROLE_SCALE]); the score
## itself knows neither the curve nor the speed.
func test_the_speed_prices_the_cost_and_the_lean_the_roles() -> void:
	var fast := _builder({})
	fast.speed = AutoDeck.SPEED_FAST
	var medium := _builder({})
	var slow := _builder({})
	slow.speed = AutoDeck.SPEED_SLOW
	var bolt := _card("Lightning Bolt")
	var dragon := _card("Shivan Dragon")
	assert_eq(fast.score(bolt), slow.score(bolt), "the score is the card's own")
	assert_gt(fast.worth(bolt), medium.worth(bolt), "a fast deck prizes its one-drops")
	assert_gt(medium.worth(bolt), slow.worth(bolt), "a slow deck does not")
	assert_gt(slow.worth(dragon), medium.worth(dragon), "a slow deck prizes its six-drops")
	assert_gt(medium.worth(dragon), fast.worth(dragon), "a fast deck discounts them")
	assert_eq(medium.worth(dragon), medium.score(dragon), "medium takes the card at its score")
	assert_almost_eq(fast.worth(bolt), fast.score(bolt) * 1.2, 0.001, "a fifth over")
	assert_almost_eq(fast.worth(dragon), fast.score(dragon) * 0.7, 0.001, "seven tenths")
	var creatures := _builder({})
	creatures.lean = AutoDeck.LEAN_CREATURES
	var spells := _builder({})
	spells.lean = AutoDeck.LEAN_SPELLS
	assert_gt(creatures.score(_card("Giant Growth")), spells.score(_card("Giant Growth")),
		"a deck of creatures wants its pump")
	assert_gt(spells.score(_card("Wrath of God")), creatures.score(_card("Wrath of God")),
		"a deck of spells wants the sweeper that a deck of creatures fears")
	assert_gt(spells.score(_card("Counterspell")), creatures.score(_card("Counterspell")),
		"and the counters")
	assert_eq(medium.score(_card("Terror")), creatures.score(_card("Terror")),
		"removal is removal in any deck")


func test_castable_and_produces_read_the_card() -> void:
	assert_true(AutoDeck.castable(_card("Lightning Bolt"), Mtg.ManaColor.R))
	assert_false(AutoDeck.castable(_card("Lightning Bolt"), Mtg.ManaColor.W))
	assert_true(AutoDeck.castable(_card("Black Lotus"), Mtg.ManaColor.W), "colourless goes anywhere")
	assert_true(AutoDeck.castable(_card("Tetsuo Umezawa"), Mtg.ManaColor.U | Mtg.ManaColor.B | Mtg.ManaColor.R))
	assert_false(AutoDeck.castable(_card("Tetsuo Umezawa"), Mtg.ManaColor.U | Mtg.ManaColor.B))
	assert_eq(AutoDeck.produces(_card("Taiga")), Mtg.ManaColor.R | Mtg.ManaColor.G)
	assert_eq(AutoDeck.produces(_card("Llanowar Elves")), Mtg.ManaColor.G)
	assert_eq(AutoDeck.produces(_card("Lightning Bolt")), 0)


func test_the_words() -> void:
	assert_eq(AutoDeck.color_phrase(0), "Colourless")
	assert_eq(AutoDeck.color_phrase(Mtg.ManaColor.W), "Mono-White")
	assert_eq(AutoDeck.color_phrase(Mtg.ManaColor.B | Mtg.ManaColor.U), "Blue-Black", "WUBRG order")
	assert_eq(AutoDeck.color_phrase(Mtg.ManaColor.G | Mtg.ManaColor.W | Mtg.ManaColor.R), "White-Red-Green")
	var auto := _builder({})
	auto.chosen_colors = Mtg.ManaColor.R | Mtg.ManaColor.G
	auto.lean = AutoDeck.LEAN_CREATURES
	auto.speed = AutoDeck.SPEED_MEDIUM
	assert_eq(auto.deck_name(), "Red-Green Beatdown")
	auto.lean = AutoDeck.LEAN_SPELLS
	auto.speed = AutoDeck.SPEED_SLOW
	auto.chosen_colors = Mtg.ManaColor.U
	assert_eq(auto.deck_name(), "Mono-Blue Control")
	auto.lean = AutoDeck.LEAN_BALANCED
	auto.speed = AutoDeck.SPEED_FAST
	assert_eq(auto.deck_name(), "Mono-Blue Aggro")
	assert_eq(AutoDeck._bucket(_card("Black Lotus")), 0, "mana value 0 sits with the ones")
	assert_eq(AutoDeck._bucket(_card("Lightning Bolt")), 0)
	assert_eq(AutoDeck._bucket(_card("Serra Angel")), 4, "five and up is the last bucket")
	assert_eq(AutoDeck._bucket(_card("Shivan Dragon")), 4)
