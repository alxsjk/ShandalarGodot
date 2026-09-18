extends GutTest
## [QoL] The Stats window's mana analysis — the sources a colour needs,
## the cards that are stuck on one, and the land count the curve wants.
##
## Measured against edhcheck.com's mana analysis and carried back to a
## 1997 duel deck: seven-card hand, sixty cards (or forty), two players,
## no commander. [ManaAnalysis] states its model in its own doc; these
## tests are what make the claim checkable. Every figure below was
## computed independently of the implementation, so a refactor that
## quietly turns the hypergeometric into an approximation — or that
## forgets a dual land can only be one colour at a time — fails here
## rather than in a player's judgement of a deck.


var deck: DeckModel


func before_each() -> void:
	CardRegistry.ensure_loaded()
	deck = DeckModel.new()


func _fill(card_name: String, n: int) -> void:
	for i in range(n):
		deck.add(card_name)


func _row(rows: Array, color: int) -> Dictionary:
	for row in rows:
		if int(row["color"]) == color:
			return row
	return {}


# ------------------------------------- the sources a colour must have --

func test_sixty_cards_reproduce_the_published_turn_four_figures() -> void:
	# The three numbers every mana-base tool quotes for a sixty-card deck
	# on turn four: 12 sources for one pip, 20 for two, 26 for three.
	# Solved here, not looked up — and landing on them is the check that
	# the model is the one the rest of the world is using.
	assert_eq(ManaAnalysis.sources_needed(60, 1, 4), 12, "{B} on turn 4")
	assert_eq(ManaAnalysis.sources_needed(60, 2, 4), 20, "{B}{B} on turn 4")
	assert_eq(ManaAnalysis.sources_needed(60, 3, 4), 26, "{B}{B}{B} on turn 4")


func test_a_turn_one_pip_wants_sixteen_of_sixty() -> void:
	# Fifteen sources is 88.2% and sixteen is 90.1%, so sixteen is the
	# first count that clears the bar. Karsten's own table says fourteen
	# because his simulation may throw back a sourceless hand; this one
	# may not, and the doc says so.
	assert_almost_eq(DeckStats.at_least(60, 15, 7, 1), 0.8825, 0.0005)
	assert_almost_eq(DeckStats.at_least(60, 16, 7, 1), 0.9008, 0.0005)
	assert_eq(ManaAnalysis.sources_needed(60, 1, 1), 16)


func test_forty_cards_ask_for_proportionally_fewer() -> void:
	assert_eq(ManaAnalysis.sources_needed(40, 1, 1), 11, "{G} on turn 1")
	assert_eq(ManaAnalysis.sources_needed(40, 2, 2), 16, "{G}{G} on turn 2")
	assert_eq(ManaAnalysis.sources_needed(40, 3, 3), 19, "{G}{G}{G} on turn 3")


func test_the_requirement_eases_with_time_and_hardens_with_pips() -> void:
	var previous := 99
	for turn in range(1, 7):
		var asks := ManaAnalysis.sources_needed(60, 1, turn)
		assert_lt(asks, previous + 1, "turn %d never asks more than turn %d"
			% [turn, turn - 1])
		previous = asks
	assert_lt(ManaAnalysis.sources_needed(60, 1, 3),
		ManaAnalysis.sources_needed(60, 2, 3), "the second pip costs more")
	assert_lt(ManaAnalysis.sources_needed(60, 2, 3),
		ManaAnalysis.sources_needed(60, 3, 3), "and the third more again")


func test_the_draw_is_worth_a_source() -> void:
	# One extra card seen, one fewer source needed.
	assert_eq(ManaAnalysis.sources_needed(60, 1, 1, ManaAnalysis.CONFIDENCE,
		false), 15, "on the draw")
	assert_eq(ManaAnalysis.cards_seen(60, 1, true), 7, "seven, on the play")
	assert_eq(ManaAnalysis.cards_seen(60, 1, false), 8, "eight, on the draw")
	assert_eq(ManaAnalysis.cards_seen(10, 9, true), 10, "never past the deck")


func test_a_colourless_cost_needs_no_sources() -> void:
	assert_eq(ManaAnalysis.sources_needed(60, 0, 3), 0)
	assert_eq(ManaAnalysis.sources_needed(0, 2, 3), 0, "and an empty deck")


# ---------------------------------------- the colours of a single spell --

func test_one_colour_is_the_plain_hypergeometric() -> void:
	_fill("Mountain", 24)
	_fill("Lightning Bolt", 36)
	assert_almost_eq(ManaAnalysis.color_available(
		deck, {Mtg.ManaColor.R: 1}, 1), DeckStats.at_least(60, 24, 7, 1), 1e-6)
	assert_almost_eq(ManaAnalysis.color_available(
		deck, {Mtg.ManaColor.R: 1}, 1), 0.97839, 0.0005)


func test_a_cost_with_no_pips_is_always_payable_on_colour() -> void:
	_fill("Mountain", 24)
	_fill("Sol Ring", 4)
	assert_eq(ManaAnalysis.color_available(deck, {}, 3), 1.0)


func test_two_colours_are_the_exact_joint_and_not_a_product() -> void:
	# 12 Plains, 12 Islands, 8 cards seen by turn two. By inclusion and
	# exclusion: 1 - 2*C(48,8)/C(60,8) + C(36,8)/C(60,8) = 0.71686.
	_fill("Plains", 12)
	_fill("Island", 12)
	_fill("Lightning Bolt", 36)
	var joint := ManaAnalysis.color_available(
		deck, {Mtg.ManaColor.W: 1, Mtg.ManaColor.U: 1}, 2)
	assert_almost_eq(joint, 0.71686, 0.0005)
	# Two basics compete for the same eight cards, so the naive product
	# of the two marginals is the WRONG answer and is higher.
	var one := DeckStats.at_least(60, 12, 8, 1)
	assert_lt(joint, one * one, "the product overstates a two-basic base")


func test_a_dual_land_is_not_worth_two_sources() -> void:
	# 10 Plains, 10 Islands, 4 Tundra: fourteen white sources and fourteen
	# blue ones by the count, but a Tundra taps once. {W}{U} on turn two
	# is 0.79481 — under the 0.80015 the same 14/14 would give if the
	# sources were all separate cards, and well under the product of the
	# marginals. This is the case a per-colour check cannot see.
	_fill("Plains", 10)
	_fill("Island", 10)
	_fill("Tundra", 4)
	_fill("Lightning Bolt", 36)
	var sources := deck.mana_sources()
	assert_eq(int(sources[Mtg.ManaColor.W]), 14, "fourteen white by the count")
	assert_eq(int(sources[Mtg.ManaColor.U]), 14, "and fourteen blue")
	var joint := ManaAnalysis.color_available(
		deck, {Mtg.ManaColor.W: 1, Mtg.ManaColor.U: 1}, 2)
	assert_almost_eq(joint, 0.79481, 0.0005)
	assert_lt(joint, DeckStats.at_least(60, 14, 8, 1)
		* DeckStats.at_least(60, 14, 8, 1), "a dual pays one pip, not two")


func test_a_lone_dual_can_never_pay_two_different_pips() -> void:
	# One Tundra and nothing else that makes white or blue. A per-colour
	# check would call it 11% likely; the deck cannot cast {W}{U} at all,
	# because the one land taps once. Hall's condition on the whole
	# subset is what says so.
	_fill("Tundra", 1)
	_fill("Lightning Bolt", 59)
	assert_eq(ManaAnalysis.color_available(
		deck, {Mtg.ManaColor.W: 1, Mtg.ManaColor.U: 1}, 2), 0.0)
	assert_gt(ManaAnalysis.color_available(deck, {Mtg.ManaColor.W: 1}, 2), 0.0,
		"…while one white pip alone is merely unlikely")


func test_three_colours_and_two_pips_each_are_still_exact() -> void:
	# Nicol Bolas, {2}{U}{U}{B}{B}{R}{R} on turn eight, over a mana base
	# that overlaps three ways: 8 Islands, 8 Swamps, 8 Mountains, 4
	# Underground Seas (blue and black) and 4 City of Brass (all five).
	# 0.68586, brute-forced independently — this is the shape the
	# recursion exists for, and the shape a product of marginals gets
	# most wrong.
	_fill("Island", 8)
	_fill("Swamp", 8)
	_fill("Mountain", 8)
	_fill("Underground Sea", 4)
	_fill("City of Brass", 4)
	_fill("Nicol Bolas", 4)
	_fill("Lightning Bolt", 24)
	assert_eq(deck.total(), 60, "sixty cards")
	assert_almost_eq(ManaAnalysis.color_available(deck, {Mtg.ManaColor.U: 2,
		Mtg.ManaColor.B: 2, Mtg.ManaColor.R: 2}, 8), 0.68586, 0.0005)
	# …and it is the figure the page reports for the card itself.
	for row in ManaAnalysis.castability(deck):
		if String(row["card"]) == "Nicol Bolas":
			assert_eq(int(row["turn"]), 8, "its own turn is its mana value")
			assert_almost_eq(float(row["odds"]), 0.68586, 0.0005)
			return
	fail_test("Nicol Bolas should be in the list")


# ------------------------------------------------ the deck, by colour --

func test_the_hardest_ask_is_the_one_reported() -> void:
	# Dark Ritual asks {B} on turn one (16 sources); Sengir Vampire asks
	# {B}{B} on turn five (18). Eighteen is the requirement and the
	# Vampire is the card that sets it — the deck has fourteen Swamps.
	_fill("Swamp", 14)
	_fill("Dark Ritual", 20)
	_fill("Sengir Vampire", 26)
	var black := _row(ManaAnalysis.color_requirements(deck), Mtg.ManaColor.B)
	assert_false(black.is_empty(), "black is in the deck")
	assert_eq(int(black["pips"]), 20 + 52, "twenty single pips and 26 doubles")
	assert_eq(int(black["sources"]), 14, "a Ritual is not a mana source")
	assert_eq(int(black["need"]), 18)
	assert_eq(int(black["need_pips"]), 2)
	assert_eq(int(black["need_turn"]), 5)
	assert_eq(String(black["card"]), "Sengir Vampire")
	assert_eq(int(black["short"]), 4, "four Swamps short")
	assert_almost_eq(float(black["odds"]), 0.79454, 0.0005)


func test_a_colour_that_is_only_a_source_asks_for_nothing() -> void:
	_fill("Mountain", 20)
	_fill("Island", 4)
	_fill("Lightning Bolt", 36)
	var rows := ManaAnalysis.color_requirements(deck)
	var blue := _row(rows, Mtg.ManaColor.U)
	assert_false(blue.is_empty(), "the Islands are still listed")
	assert_eq(int(blue["pips"]), 0, "but nothing asks for blue")
	assert_eq(int(blue["need_pips"]), 0, "so there is no requirement")
	assert_eq(int(blue["short"]), 0)
	assert_true(_row(rows, Mtg.ManaColor.G).is_empty(),
		"and a colour the deck never touches is left out entirely")


func test_a_covered_colour_says_so() -> void:
	_fill("Swamp", 24)
	_fill("Hypnotic Specter", 36)
	var black := _row(ManaAnalysis.color_requirements(deck), Mtg.ManaColor.B)
	assert_eq(int(black["need"]), 22, "{B}{B} on turn three")
	assert_eq(int(black["short"]), 0, "twenty-four Swamps cover it")


# --------------------------------------------- the deck, card by card --

func test_castability_names_the_card_that_is_stuck() -> void:
	_fill("Swamp", 14)
	_fill("Dark Ritual", 20)
	_fill("Sengir Vampire", 26)
	var rows := ManaAnalysis.castability(deck)
	assert_eq(rows.size(), 2, "two spells, the Swamps are not cast")
	assert_eq(String(rows[0]["card"]), "Sengir Vampire", "worst first")
	assert_eq(int(rows[0]["turn"]), 5, "on its own turn")
	assert_almost_eq(float(rows[0]["odds"]), 0.79454, 0.0005)
	assert_eq(String(rows[1]["card"]), "Dark Ritual")
	assert_almost_eq(float(rows[1]["odds"]), 0.86141, 0.0005)
	# Weighted by copies: 26 Vampires and 20 Rituals.
	assert_almost_eq(ManaAnalysis.average_castability(rows), 0.82362, 0.0005)


func test_a_colourless_spell_is_never_stuck_on_colour() -> void:
	_fill("Mountain", 24)
	_fill("Sol Ring", 4)
	_fill("Lightning Bolt", 32)
	for row in ManaAnalysis.castability(deck):
		if String(row["card"]) == "Sol Ring":
			assert_eq(float(row["odds"]), 1.0, "a Mox is never stuck")
			return
	fail_test("Sol Ring should be in the list")


func test_worst_casts_keeps_quiet_about_a_deck_that_works() -> void:
	_fill("Mountain", 24)
	_fill("Lightning Bolt", 36)
	var rows := ManaAnalysis.castability(deck)
	assert_eq(ManaAnalysis.worst_casts(rows).size(), 0,
		"97.8% is not a problem worth naming")
	assert_eq(ManaAnalysis.worst_casts(rows, 4, 0.99).size(), 1,
		"…until the bar is raised past it")


func test_worst_casts_stops_at_the_limit() -> void:
	_fill("Swamp", 8)
	_fill("Sengir Vampire", 12)
	_fill("Hypnotic Specter", 12)
	_fill("Royal Assassin", 12)
	_fill("Wrath of God", 8)
	_fill("Serra Angel", 8)
	var rows := ManaAnalysis.castability(deck)
	assert_eq(ManaAnalysis.worst_casts(rows, 3).size(), 3, "three at most")


# ---------------------------------------------------------- land count --

func test_the_land_formula_is_karstens_scaled_to_the_deck() -> void:
	# 19.59 + 1.90 * 1.00 - 0.28 * 0 = 21.49 for sixty cards.
	_fill("Mountain", 24)
	_fill("Lightning Bolt", 36)
	var advice := ManaAnalysis.land_advice(deck)
	assert_eq(int(advice["lands"]), 24)
	assert_eq(int(advice["size"]), 60)
	assert_almost_eq(float(advice["average_cost"]), 1.0, 0.0001)
	assert_eq(int(advice["accelerants"]), 0)
	assert_almost_eq(float(advice["want"]), 21.49, 0.005)


func test_forty_cards_at_the_usual_curve_want_seventeen_lands() -> void:
	# The claim the scaling has to earn: an average mana value of three
	# in forty cards must come out at the limited default of 17.
	_fill("Swamp", 17)
	_fill("Hypnotic Specter", 23)
	var advice := ManaAnalysis.land_advice(deck)
	assert_almost_eq(float(advice["average_cost"]), 3.0, 0.0001)
	assert_almost_eq(float(advice["want"]), 16.86, 0.005)
	assert_eq(int(advice["lands"]), 17, "which is what is in there")


func test_cheap_mana_cuts_the_recommendation() -> void:
	# THE SAME SIXTY CARDS both times, four of the spells swapped for
	# Moxen: 21.49 lands wanted before, 20.16 after. Comparing decks of
	# different sizes would have measured the scaling instead.
	_fill("Mountain", 24)
	_fill("Lightning Bolt", 36)
	assert_almost_eq(float(ManaAnalysis.land_advice(deck)["want"]), 21.49, 0.005)
	deck = DeckModel.new()
	_fill("Mountain", 24)
	_fill("Lightning Bolt", 32)
	_fill("Mox Ruby", 4)
	var advice := ManaAnalysis.land_advice(deck)
	assert_eq(int(advice["accelerants"]), 4)
	assert_almost_eq(float(advice["want"]), 20.16, 0.005,
		"four Moxen are more than a land's worth of work")


func test_the_accelerants_are_the_cheap_mana_makers() -> void:
	_fill("Mox Ruby", 4)          # a mana ability, mana value zero
	_fill("Sol Ring", 4)          # a mana ability, mana value one
	_fill("Birds of Paradise", 4) # five mana abilities
	_fill("Llanowar Elves", 4)
	_fill("Dark Ritual", 4)       # no ability at all — a spell that adds
	_fill("Sengir Vampire", 4)    # makes no mana
	_fill("Lightning Bolt", 4)    # nor this
	_fill("City of Brass", 4)     # a land is not acceleration
	assert_eq(ManaAnalysis.cheap_acceleration(deck), 20)


# ----------------------------------------------- generic vs coloured --

func test_the_generic_share_is_what_a_splash_lives_on() -> void:
	_fill("Swamp", 10)
	_fill("Sengir Vampire", 4)    # {3}{B}{B}
	var demand := ManaAnalysis.mana_demand(deck)
	assert_eq(int(demand["colored"]), 8)
	assert_eq(int(demand["generic"]), 12)
	assert_eq(int(demand["total"]), 20)
	assert_almost_eq(float(demand["share"]), 0.6, 0.0001)


func test_an_all_land_deck_asks_for_nothing() -> void:
	_fill("Swamp", 40)
	var demand := ManaAnalysis.mana_demand(deck)
	assert_eq(int(demand["total"]), 0)
	assert_eq(float(demand["share"]), 0.0, "and does not divide by zero")


# ------------------------------------------------------------- the page --

var screen: DeckBuilderScreen


func _tabs() -> HBoxContainer:
	return screen._stats_pages.get_parent().get_parent().get_child(0) as HBoxContainer


func _walk(node: Node) -> Array:
	var out := [node]
	for child in node.get_children():
		out.append_array(_walk(child))
	return out


## Open Stats on the Mana page and read every word on it. The Deck page
## the window opens on is queued for freeing when the Mana page replaces
## it, so a frame is awaited before the words are gathered — the queued
## nodes would otherwise count as orphans at the end of the test.
func _mana_page_labels() -> Array:
	screen._run_command("Stats")
	screen._show_stats_page(2, _tabs())
	await get_tree().process_frame
	var out := []
	for node in _walk(screen._stats_pages):
		if node is Label:
			out.append(String((node as Label).text).strip_edges())
	return out


func _open_screen() -> void:
	screen = load("res://game/deck_builder/deck_builder_screen.tscn").instantiate()
	add_child_autofree(screen)


func test_the_mana_page_answers_all_four_questions() -> void:
	_open_screen()
	for i in 14:
		screen.deck.add("Swamp")
	for i in 20:
		screen.deck.add("Dark Ritual")
	for i in 26:
		screen.deck.add("Sengir Vampire")
	var words: Array = await _mana_page_labels()
	assert_true(words.has("What the deck asks for, and what it has"),
		"the pips and the sources")
	assert_true(words.has("Sources needed to cast on curve"),
		"the requirement")
	assert_true(words.has("Land count"), "the land count")
	assert_true(words.has("Casting on curve"), "and what is still stuck")


func test_the_page_names_the_colour_that_is_short() -> void:
	_open_screen()
	for i in 14:
		screen.deck.add("Swamp")
	for i in 20:
		screen.deck.add("Dark Ritual")
	for i in 26:
		screen.deck.add("Sengir Vampire")
	var words: Array = await _mana_page_labels()
	assert_true(words.has("Black  {B}{B} by turn 5"),
		"the hardest ask, written as the card writes it")
	assert_true(words.has("14 of 18 — short 4"), "and the shortfall")
	assert_true(words.has("Sengir Vampire"), "the card that is stuck")
	assert_true(words.has("79.5% by turn 5"), "with its own turn's odds")


func test_the_page_says_when_the_mana_is_enough() -> void:
	_open_screen()
	for i in 24:
		screen.deck.add("Mountain")
	for i in 36:
		screen.deck.add("Lightning Bolt")
	var words: Array = await _mana_page_labels()
	assert_true(words.has("24 of 16 — enough"), "no verdict is left implied")
	assert_true(words.has("21.5"), "the curve wants 21.5 lands")
	assert_true(words.has("Nothing under 95% — the colours are there."),
		"and nothing is named as stuck")


func test_an_empty_deck_asks_for_cards_rather_than_dividing_by_zero() -> void:
	_open_screen()
	var words: Array = await _mana_page_labels()
	assert_true(words.has("Add some cards first."))
