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
	assert_eq(auto.report.size(), 5)


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


func test_the_rarity_cap_holds() -> void:
	var commons := _builder(_library())
	commons.rarity_cap = "common"
	var deck := commons.build()
	_assert_legal(deck, commons, 60)
	for name in deck.names():
		if AutoDeck.BASICS.has(name):
			continue
		var tier := DeckStats.rarity_tier(DeckModel._card(name))
		assert_true(tier == "common" or tier == "", "%s is %s" % [name, tier])
	var uncommons := _builder(_library())
	uncommons.rarity_cap = "uncommon"
	deck = uncommons.build()
	var seen_uncommon := false
	for name in deck.names():
		var tier := DeckStats.rarity_tier(DeckModel._card(name))
		assert_true(tier != "rare" and tier != "legendary", "%s is %s" % [name, tier])
		seen_uncommon = seen_uncommon or tier == "uncommon"
	assert_true(seen_uncommon, "the uncommons are allowed in")


func test_the_tournament_rules_bar_the_banned_and_cap_the_restricted() -> void:
	var pool := {"Contract from Below": 4, "Black Lotus": 4, "Lightning Bolt": 4, "Hypnotic Specter": 4}
	var auto := _builder(pool)
	auto.colors = Mtg.ManaColor.B | Mtg.ManaColor.R
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
	var deck := auto.build()
	assert_eq(auto.size, 60)
	assert_eq(auto.max_colors, 3)
	assert_eq(deck.total(), 60)


func test_dual_lands_of_the_deck_s_colours_come_first_and_capped() -> void:
	var pool := AutoDeck.pool_from_sets(["4ed"])
	pool["Taiga"] = 4
	pool["Tundra"] = 4
	var auto := _builder(pool)
	auto.colors = Mtg.ManaColor.R | Mtg.ManaColor.G
	var deck := auto.build()
	_assert_legal(deck, auto, 60)
	assert_eq(deck.count_of("Taiga"), 4, "the red-green dual, all four")
	assert_eq(deck.count_of("Tundra"), 0, "a white-blue dual makes nothing the deck casts")
	assert_true(_nonbasics(deck) <= int(floor(AutoDeck.NONBASIC_SHARE * 24)),
		"%d non-basic lands within the share" % _nonbasics(deck))
	assert_eq(_lands(deck), 24)


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
