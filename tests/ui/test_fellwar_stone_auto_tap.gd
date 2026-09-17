extends GutTest
## FELLWAR STONE UNDER THE DOUBLE-CLICK — the owner's playtest, 2026-09-17:
## *"On double-click (when you want to cast with automatic mana tap) card
## Fellwar Stone can tap automatically and produce mana of the wrong
## colour. Fellwar Stone should tap automatically only for a colourless
## mana request, or if we know the opponent only has land of the colour
## we know. Furthermore, if Fellwar Stone can produce many mana types (the
## opponent has many different lands), you should be asked upon tapping
## what kind of mana you want Fellwar Stone to produce."*
##
## What the playtest had actually found: the double-click tapped the
## Forest, put the Stone's *"What kind of mana?"* to the player — and then
## submitted the cast under the open question, which the engine refused
## (*"waiting for a choice to be made"*), and the refusal, not being an
## unpaid one, DROPPED the cast. The answer then landed two mana in the
## pool with the spell back in hand. A second, quieter defect: a Stone
## facing ONE colour held the duel open on a one-button question.
##
## The fix, in three parts: [method ManaPlanner.sources] lists the Stone
## once per colour on offer and the plan step carries the colour it
## priced ([method ManaPlanner.step_of] — so a {R} spell facing an Island
## and a Mountain is castable, and yellow); [method MtgGame.tap_for_mana]
## asks nothing for ONE colour on offer, or for the colour a plan hands
## it; and the double-click plans over
## [method ManaPlanner.auto_tap_sources], where a Stone with several
## colours is generic-only — so it is never silently coloured, its
## question is put to the player, and the cast WAITS for the answer
## ([method DuelScreen._resume_auto_tap]) instead of being dropped.

var screen: DuelScreen


func before_each() -> void:
	screen = load("res://game/duel/duel_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame


## A clean main phase for seat 0: [param card_name] in hand, [param mine]
## on seat 0's table, [param theirs] on seat 1's, nothing floating.
func _stage(card_name: String, mine: Array, theirs: Array) -> CardInstance:
	var g: MtgGame = screen.game
	g.active_player = 0
	g._enter_step(Mtg.STEP_ORDER.find(Mtg.Step.MAIN1))
	g.priority_player = 0
	g.players[0].hand.clear()
	g.players[0].mana_pool.clear()
	g.players[0].battlefield.clear()
	g.players[1].battlefield.clear()
	screen.mode = DuelScreen.Mode.NORMAL
	var inst := CardInstance.new(CardRegistry.get_card(card_name), 93001, 0)
	inst.zone = Mtg.Zone.HAND
	g._instances[inst.id] = inst
	g.players[0].hand.append(inst)
	var next := 93010
	for name in mine:
		var c := CardInstance.new(CardRegistry.get_card(name), next, 0)
		next += 1
		g._instances[c.id] = c
		g._put_on_battlefield(c, 0)
	for name in theirs:
		var c := CardInstance.new(CardRegistry.get_card(name), next, 1)
		next += 1
		g._instances[c.id] = c
		g._put_on_battlefield(c, 1)
	screen._refresh()
	return inst


func _tapped() -> Array:
	var out: Array = []
	for p in screen.game.players[0].battlefield:
		if p.tapped:
			out.append(p.data.card_name)
	return out


func _double_click(inst: CardInstance) -> void:
	screen._on_card_clicked(inst)      # the first click of the pair
	screen._auto_cast(inst)            # the second


# ------------------------------------------ several colours: ASK, and WAIT --

func test_the_stones_question_holds_the_cast_instead_of_dropping_it() -> void:
	var g: MtgGame = screen.game
	var bears := _stage("Grizzly Bears", ["Forest", "Fellwar Stone"], ["Island", "Mountain"])
	_double_click(bears)
	assert_eq(_tapped(), ["Forest"], "the Forest paid the {G}; the Stone waits on its colour")
	assert_not_null(g.awaiting_choice, "the Stone's question is put to the player")
	assert_eq((g.awaiting_choice as PlayerChoice).prompt, "Fellwar Stone: What kind of mana?")
	assert_eq(g.stack.size(), 0, "nothing was submitted under the open question")
	assert_eq(screen._pending_card, bears, "and the cast is still the pending one, not dropped")
	assert_eq(bears.zone, Mtg.Zone.HAND)
	assert_eq(g.answer_choice(Mtg.ManaColor.R), "")
	screen._refresh()
	assert_null(g.awaiting_choice)
	assert_eq(g.stack.size(), 1, "answered, the gesture finishes the cast")
	assert_eq(g.stack[0].card, bears)
	assert_eq(_tapped(), ["Forest", "Fellwar Stone"])
	assert_eq(g.players[0].mana_pool.total(), 0, "nothing left floating")
	assert_eq(screen.mode, DuelScreen.Mode.NORMAL, "and the screen let go")
	assert_false(screen._auto_resume)


func test_cancelling_the_question_leaves_the_cast_waiting_for_its_mana() -> void:
	var g: MtgGame = screen.game
	var bears := _stage("Grizzly Bears", ["Forest", "Fellwar Stone"], ["Island", "Mountain"])
	_double_click(bears)
	assert_not_null(g.awaiting_choice)
	assert_eq(g.cancel_choice(), "")
	screen._refresh()
	assert_eq(g.stack.size(), 0)
	assert_eq(screen._pending_card, bears, "the cast is kept")
	assert_eq(screen.mode, DuelScreen.Mode.PAYING,
		"a plan short by one pip parks the cast for the player to finish by hand")
	assert_eq(_tapped(), ["Forest"], "the Stone is untapped, the Forest's mana floats")
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.G), 1)
	assert_false(screen._auto_resume)
	# ...and by hand it still works: tap the Stone, answer, cast.
	var stone: CardInstance = g.players[0].battlefield[1]
	screen._on_card_clicked(stone)
	assert_not_null(g.awaiting_choice, "the hand tap asks too")
	assert_eq(g.answer_choice(Mtg.ManaColor.U), "")
	screen._refresh()
	assert_eq(g.stack.size(), 1, "the retry picked the cast up")


func test_a_generic_only_cost_may_use_the_stone_but_still_asks() -> void:
	# *"Fellwar Stone should tap automatically only for a colourless mana
	# request"* — a {2} is such a request, so the gesture reaches for the
	# Stone; but with two colours on offer *"you should be asked upon
	# tapping"*, so the question is still the player's.
	var g: MtgGame = screen.game
	var stone_spell := _stage("Fellwar Stone", ["Forest", "Fellwar Stone"], ["Island", "Mountain"])
	_double_click(stone_spell)
	assert_not_null(g.awaiting_choice, "asked, not silently coloured")
	assert_eq(screen._pending_card, stone_spell)
	assert_eq(g.answer_choice(Mtg.ManaColor.U), "")
	screen._refresh()
	assert_eq(g.stack.size(), 1)
	assert_eq(_tapped(), ["Forest", "Fellwar Stone"])


# ------------------------------------- several colours: NEVER for a colour --

func test_a_coloured_pip_is_never_auto_tapped_from_a_stone_with_a_choice() -> void:
	# {R} with only the Stone, facing an Island and a Mountain: the Stone
	# COULD make red, so the name is yellow and the cast is reachable —
	# but the gesture does not pick a colour for the player. It leaves
	# the cast waiting for its mana with the Stone untouched.
	var g: MtgGame = screen.game
	var raiders := _stage("Mons's Goblin Raiders", ["Fellwar Stone"], ["Island", "Mountain"])
	assert_eq(screen._highlight_for(raiders), MiniCard.Highlight.CASTABLE,
		"the Stone can make red, so the name is yellow")
	_double_click(raiders)
	assert_eq(g.stack.size(), 0)
	assert_eq(_tapped(), [], "the Stone was not tapped for a colour of the gesture's choosing")
	assert_null(g.awaiting_choice)
	assert_eq(screen.mode, DuelScreen.Mode.PAYING, "the player finishes it by hand")
	assert_eq(screen._pending_card, raiders)
	# By hand: the tap asks, and the answer casts.
	screen._on_card_clicked(g.players[0].battlefield[0])
	assert_not_null(g.awaiting_choice)
	assert_eq(g.answer_choice(Mtg.ManaColor.R), "")
	screen._refresh()
	assert_eq(g.stack.size(), 1)


func test_the_gesture_prefers_lands_that_ask_nothing() -> void:
	var g: MtgGame = screen.game
	var bears := _stage("Grizzly Bears", ["Forest", "Fellwar Stone", "Forest"], ["Island", "Mountain"])
	_double_click(bears)
	assert_eq(g.stack.size(), 1, "cast in one gesture")
	assert_eq(_tapped(), ["Forest", "Forest"], "two Forests, the Stone untouched")
	assert_null(g.awaiting_choice, "and no question")


# --------------------------------------------- ONE colour: known, no question --

func test_a_stone_with_one_colour_on_offer_auto_taps_without_asking() -> void:
	# *"...or if we know the opponent only has land of the colour we know."*
	var g: MtgGame = screen.game
	var merfolk := _stage("Merfolk of the Pearl Trident", ["Fellwar Stone"], ["Island"])
	assert_eq(screen._highlight_for(merfolk), MiniCard.Highlight.CASTABLE)
	_double_click(merfolk)
	assert_null(g.awaiting_choice, "one colour is no choice")
	assert_eq(g.stack.size(), 1, "cast in one gesture")
	assert_eq(_tapped(), ["Fellwar Stone"])
	assert_eq(g.players[0].mana_pool.total(), 0)


func test_a_stone_with_one_colour_asks_nothing_by_hand_either() -> void:
	var g: MtgGame = screen.game
	_stage("Merfolk of the Pearl Trident", ["Fellwar Stone"], ["Island"])
	screen._on_card_clicked(g.players[0].battlefield[0])
	assert_null(g.awaiting_choice, "no one-button question")
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.U), 1)


# ------------------------------------------------- the model behind it --

func test_the_planner_lists_the_stone_once_per_colour_and_the_auto_tap_collapses_it() -> void:
	var g: MtgGame = screen.game
	_stage("Grizzly Bears", ["Fellwar Stone"], ["Island", "Mountain"])
	var colors: Array = []
	for row in ManaPlanner.sources(g, 0):
		colors.append(int(row[2]))
	assert_eq(colors, [Mtg.ManaColor.U, Mtg.ManaColor.R], "one row per colour on offer")
	var auto: Array = []
	for row in ManaPlanner.auto_tap_sources(g, 0):
		auto.append(int(row[2]))
	assert_eq(auto, [Mtg.ManaColor.C], "the gesture sees one generic-only row")
	assert_true(g.could_afford(0, CardRegistry.get_card("Mons's Goblin Raiders")),
		"the yellow name reads the full model")
	assert_true(ManaPlanner.plan_from(ManaPlanner.auto_tap_sources(g, 0),
		ManaCost.parse("{R}"), 0).is_empty(), "and the gesture cannot plan a colour from it")
