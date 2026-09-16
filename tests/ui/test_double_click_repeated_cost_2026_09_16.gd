extends GutTest
## THE DOUBLE-CLICK AND A REPEATED ADDITIONAL COST. Taste of Paradise
## ({3}{G}, *"You may pay an additional {1}{G} any number of times"*) asks
## the same X question a Fireball does, but its X counts PAYMENTS, not
## mana: the window ([method DuelScreen._open_x_dialog]) already turns the
## generic budget into a payment count against the engine's own bill,
## while the double-click ([method DuelScreen._auto_x_budget]) handed the
## raw generic budget to the spin — seven Forests became "3 additional
## payments", a ten-mana bill the auto-tapper could not meet, and the
## gesture left the cast open in [constant DuelScreen.Mode.PAYING].

var screen: DuelScreen


func before_each() -> void:
	CardPacks.set_enabled("pack-5", true)
	screen = load("res://game/duel/duel_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame


func after_each() -> void:
	CardPacks.set_enabled("pack-5", false)


## A clean main phase for seat 0: the spell in hand, [param lands] Forests
## on the table, nothing floating (the casting-flow stage).
func _stage(card_name: String, lands: int) -> CardInstance:
	var g: MtgGame = screen.game
	g.active_player = 0
	g._enter_step(Mtg.STEP_ORDER.find(Mtg.Step.MAIN1))
	g.priority_player = 0
	g.players[0].hand.clear()
	g.players[0].mana_pool.clear()
	g.players[0].battlefield.clear()
	screen.mode = DuelScreen.Mode.NORMAL
	var inst := CardInstance.new(CardRegistry.get_card(card_name), 94001, 0)
	inst.zone = Mtg.Zone.HAND
	g._instances[inst.id] = inst
	g.players[0].hand.append(inst)
	for i in lands:
		var forest := CardInstance.new(CardRegistry.get_card("Forest"),
			94010 + i, 0)
		g._instances[forest.id] = forest
		g._put_on_battlefield(forest, 0)
	screen._refresh()
	return inst


func _tapped_count() -> int:
	var tapped := 0
	for land in screen.game.players[0].battlefield:
		if land.tapped:
			tapped += 1
	return tapped


func test_the_double_click_counts_payments_not_mana() -> void:
	var g: MtgGame = screen.game
	var taste := _stage("Taste of Paradise", 8)
	screen._on_card_clicked(taste)      # opens the X question
	assert_not_null(screen._x_dialog, "the window is the payment question")
	screen._auto_cast(taste)            # ...which the gesture answers
	assert_eq(screen._pending_x, 2,
		"eight Forests: four pay {3}{G}, the other four buy two {1}{G}")
	assert_eq(g.stack.size(), 1, "on the chain, in one gesture")
	assert_eq(_tapped_count(), 8, "every Forest went into it")
	assert_eq(screen.mode, DuelScreen.Mode.NORMAL,
		"nothing left open — the spell had no target to pick")


func test_a_spare_forest_stays_untapped() -> void:
	# Seven Forests: {3}{G} and ONE extra payment is six; the seventh
	# cannot buy half of a {1}{G}.
	var g: MtgGame = screen.game
	var taste := _stage("Taste of Paradise", 7)
	screen._on_card_clicked(taste)
	screen._auto_cast(taste)
	assert_eq(screen._pending_x, 1, "one payment; the seventh Forest buys nothing")
	assert_eq(g.stack.size(), 1)
	assert_eq(_tapped_count(), 6, "the auto-tapper takes only what the bill says")


func test_the_window_and_the_gesture_agree() -> void:
	# The bound printed on the window is the same count the gesture
	# reaches for, so the two can never disagree about a point of X.
	var taste := _stage("Taste of Paradise", 8)
	screen._on_card_clicked(taste)
	assert_eq(int(screen._x_spin.max_value), 2, "the window offers two payments")
	assert_eq(screen._auto_x_budget(), 2, "and the gesture takes the same two")


func test_a_locked_land_is_left_out_of_the_count() -> void:
	# "Don't Auto Tap" keeps a Forest out of the double-click's reach, so
	# with eight Forests and one locked the gesture can afford one payment
	# less than the window, which the player answers by hand.
	var g: MtgGame = screen.game
	var taste := _stage("Taste of Paradise", 8)
	var locked: CardInstance = g.players[0].battlefield[0]
	screen._no_auto_tap[locked.id] = true
	screen._on_card_clicked(taste)
	assert_eq(int(screen._x_spin.max_value), 2, "the window still counts the locked Forest")
	assert_eq(screen._auto_x_budget(), 1, "the gesture does not")
	screen._auto_cast(taste)
	assert_eq(screen._pending_x, 1)
	assert_eq(g.stack.size(), 1)
	assert_false(locked.tapped, "the locked land was not touched")
