extends GameTest
## Reinforcements: put up to three target creature cards from your graveyard
## on top of your library. They must be the next cards drawn, in chosen order.

func before_each() -> void:
	CardPacks.set_enabled("pack-5", true)
	super.before_each()
	advance_to_step(Mtg.Step.MAIN1)


func after_each() -> void:
	g = null
	CardPacks.set_enabled("pack-5", false)


func _bury(name: String, pid := 0) -> CardInstance:
	var card := give_hand(pid, name)
	g.card_to_graveyard_from_anywhere(card)
	return card


func _cast(targets: Array) -> CardInstance:
	var spell := give_hand(0, "Reinforcements")
	add_mana(0, Mtg.ManaColor.W)
	assert_ok(g.cast_spell(0, spell, targets))
	return spell


func test_reinforcements_cards_are_on_top_and_drawn_next(count = use_parameters([1, 2, 3])) -> void:
	var names := ["Grizzly Bears", "Serra Angel", "White Knight"]
	var cards: Array[CardInstance] = []
	var targets: Array = []
	for name in names.slice(0, count):
		var card := _bury(name)
		cards.append(card)
		targets.append(TargetRef.card(card))
	var size_before := g.players[0].library.size()
	var spell := _cast(targets)
	resolve_stack()
	assert_eq(spell.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.players[0].library.size(), size_before + count)
	for card in cards:
		assert_eq(card.zone, Mtg.Zone.LIBRARY)
		assert_false(g.players[0].graveyard.has(card))
	for _draw in count:
		var next: CardInstance = g.players[0].library.back()
		assert_has(cards, next, "the next draw is one of the returned creatures")
		g.draw_cards(0, 1)
		assert_eq(g.players[0].hand.back(), next)
		cards.erase(next)
	assert_true(cards.is_empty())


func test_reinforcements_human_orders_three_and_draws_them_on_next_turns() -> void:
	var bear := _bury("Grizzly Bears")
	var angel := _bury("Serra Angel")
	var knight := _bury("White Knight")
	g.set_agent(0, HumanAgent.new())
	g.interactive_choices = true
	var spell := _cast([TargetRef.card(bear), TargetRef.card(angel), TargetRef.card(knight)])
	assert_ok(g.pass_priority(g.priority_player))
	assert_ok(g.pass_priority(g.priority_player))
	var order := [knight, bear, angel]
	for card in order:
		assert_not_null(g.awaiting_choice, "the player chooses the next card from the top")
		if g.awaiting_choice == null: return
		assert_eq(g.awaiting_choice.pid, 0)
		assert_has(g.awaiting_choice.candidates, card)
		assert_eq(card.zone, Mtg.Zone.GRAVEYARD, "choice probes do not move the real card")
		assert_ok(g.answer_choice(card.id))
	assert_null(g.awaiting_choice)
	assert_true(g.stack.is_empty())
	assert_eq(spell.zone, Mtg.Zone.GRAVEYARD)
	for card in order:
		assert_eq(g.players[0].library.back(), card)
		advance_to_next_turn() # Opponent draws from their own library.
		advance_to_next_turn() # Our draw step takes this returned creature.
		assert_eq(g.players[0].hand.back(), card)
		assert_eq(card.zone, Mtg.Zone.HAND)


func test_reinforcements_rejects_noncreatures_opponents_and_four_targets() -> void:
	var cards: Array = []
	for name in ["Grizzly Bears", "Serra Angel", "White Knight", "Craw Wurm"]:
		cards.append(TargetRef.card(_bury(name)))
	var spell := give_hand(0, "Reinforcements")
	var land := _bury("Forest")
	var enemy := _bury("Grizzly Bears", 1)
	add_mana(0, Mtg.ManaColor.W)
	for targets in [[TargetRef.card(land)], [TargetRef.card(enemy)], cards, [cards[0], cards[0]]]:
		assert_refused(g.cast_spell(0, spell, targets))
	assert_eq(spell.zone, Mtg.Zone.HAND)
	assert_eq(g.players[0].mana_pool.amount_of(Mtg.ManaColor.W), 1)


func test_reinforcements_resolves_with_zero_targets_without_rearranging_library() -> void:
	var before := g.players[0].library.duplicate()
	var spell := _cast([])
	resolve_stack()
	assert_eq(g.players[0].library, before)
	assert_eq(spell.zone, Mtg.Zone.GRAVEYARD)


func test_reinforcements_skips_a_target_that_leaves_the_graveyard() -> void:
	var bear := _bury("Grizzly Bears")
	var angel := _bury("Serra Angel")
	_cast([TargetRef.card(bear), TargetRef.card(angel)])
	g.return_from_graveyard_to_hand(bear)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.HAND)
	assert_eq(g.players[0].library.back(), angel)
	g.draw_cards(0, 1)
	assert_eq(g.players[0].hand.back(), angel)
