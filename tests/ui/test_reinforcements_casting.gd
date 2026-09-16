extends GutTest
## Playtest: graveyard picks must reach Reinforcements and the next draw.

var screen: DuelScreen

func before_each() -> void:
	CardPacks.set_enabled("pack-5", true)
	screen = load("res://game/duel/duel_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.set_process(false)
	screen.stops.clear_all()
	screen._toss_active = false
	screen.game.active_player = 0
	screen.game.priority_player = 0
	screen.game._step_index = Mtg.STEP_ORDER.find(Mtg.Step.MAIN1)
	screen.game.interactive_choices = true
	screen.game.set_agent(0, HumanAgent.new())
	screen.game.set_agent(1, DecisionAgent.new())


func after_each() -> void:
	CardPacks.set_enabled("pack-5", false)


func _card(name: String, graveyard := false) -> CardInstance:
	var g := screen.game
	var card := CardInstance.new(CardRegistry.get_card(name), g._next_instance_id, 0)
	g._next_instance_id += 1
	g._instances[card.id] = card
	card.zone = Mtg.Zone.HAND
	g.players[0].hand.append(card)
	if graveyard: g.card_to_graveyard_from_anywhere(card)
	return card


func test_graveyard_picks_reach_the_spell_and_next_draw(count = use_parameters([1, 2, 3])) -> void:
	var names := ["Grizzly Bears", "White Knight", "Serra Angel"]
	var returned: Array[CardInstance] = []
	for name in names.slice(0, count): returned.append(_card(name, true))
	var spell := _card("Reinforcements")
	var g := screen.game
	g.players[0].mana_pool.add(Mtg.ManaColor.W, 1)
	screen._click_hand_card(spell)
	assert_eq(screen.mode, DuelScreen.Mode.TARGETING)
	screen._on_grave_pile_clicked(0)
	assert_true(screen.graveyard_is_open())
	for card in returned:
		var shelf: Dictionary = screen._grave_view._shelves["%d:%d" % [Mtg.Zone.GRAVEYARD, 0]]
		var clicked := false
		for face in shelf.widgets:
			if face.instance == card:
				face.pressed.emit()
				clicked = true
				break
		assert_true(clicked)
	if count < 3:
		screen._close_graveyard()
		screen._on_done()
	assert_eq(g.stack.size(), 1)
	if g.stack.is_empty(): return
	assert_eq(g.stack.back().targets.size(), count)
	assert_eq(g.pass_priority(g.priority_player), "")
	assert_eq(g.pass_priority(g.priority_player), "")
	for card in returned:
		assert_not_null(g.awaiting_choice)
		if g.awaiting_choice == null: return
		var options := DuelScreen.choice_options(g.awaiting_choice)
		var pick := options.find(card.data.card_name)
		assert_gte(pick, 0)
		screen._on_choice_option(pick)
	assert_true(g.stack.is_empty())
	for card in returned:
		assert_eq(g.players[0].library.back(), card)
		g.draw_cards(0, 1)
		assert_eq(g.players[0].hand.back(), card)
	await get_tree().process_frame
	await get_tree().process_frame
