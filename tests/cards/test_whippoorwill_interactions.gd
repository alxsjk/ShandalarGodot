extends GameTest
## Whippoorwill: damage cannot be prevented or redirected; exile is a
## delayed DIES trigger, not Disintegrate's replacement (CR 603.7/615.12).


func _mark(victim: CardInstance) -> CardInstance:
	var bird := put_battlefield(0, "Whippoorwill")
	add_mana(0, Mtg.ManaColor.G, 2)
	assert_ok(g.activate_ability(0, bird, 0, [TargetRef.card(victim)]))
	resolve_stack()
	return bird


func test_fog_respects_each_recipient_under_both_editions() -> void:
	for edition in ["modern", "fifth"]:
		before_each()
		g.rules.set_edition(edition)
		var ogre := put_battlefield(0, "Gray Ogre")
		var bear := put_battlefield(1, "Grizzly Bears")
		advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
		assert_ok(g.declare_attackers(0, [ogre.id]))
		advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
		assert_ok(g.declare_blockers(1, {bear.id: ogre.id}))
		_mark(bear)
		var fog := give_hand(0, "Fog")
		add_mana(0, Mtg.ManaColor.G)
		assert_ok(g.cast_spell(0, fog, []))
		resolve_stack()
		advance_to_step(Mtg.Step.COMBAT_DAMAGE)
		assert_eq(bear.zone, Mtg.Zone.GRAVEYARD, edition)
		assert_eq(ogre.damage, 0, "Fog still protects the unmarked recipient")
		resolve_stack()
		assert_eq(bear.zone, Mtg.Zone.EXILE)


func test_death_is_observed_before_exile_and_outlives_the_bird() -> void:
	var vampire := put_battlefield(0, "Sengir Vampire")
	var sprite := put_battlefield(1, "Scryb Sprites")
	var bird := _mark(sprite)
	g.exile_permanent(bird)
	advance_to_step(Mtg.Step.DECLARE_ATTACKERS)
	assert_ok(g.declare_attackers(0, [vampire.id]))
	advance_to_step(Mtg.Step.DECLARE_BLOCKERS)
	assert_ok(g.declare_blockers(1, {sprite.id: vampire.id}))
	advance_to_step(Mtg.Step.COMBAT_DAMAGE)
	assert_eq(sprite.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.creatures_died_this_turn, 1)
	resolve_stack()
	assert_eq(sprite.zone, Mtg.Zone.EXILE)
	assert_eq(vampire.cur_power, 5, "the Vampire's dies-trigger was not suppressed")


func test_a_new_battlefield_incarnation_is_not_marked() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	_mark(bear)
	g.return_to_hand(bear)
	g._put_on_battlefield(bear, 1)  # setup a new incarnation of the same card
	g.destroy(bear)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)


func test_exile_trigger_does_not_follow_a_card_that_left_the_graveyard() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	_mark(bear)
	g.destroy(bear)
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	g.return_from_graveyard_to_hand(bear)
	g.discard_cards(1, [bear])
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD, "this is a new graveyard object")


func test_mark_expires_at_cleanup() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	_mark(bear)
	advance_to_next_turn()
	g.destroy(bear)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	assert_eq(g.delayed_triggers.size(), 0)


func test_source_side_prevention_does_not_override_the_mark() -> void:
	advance_to_step(Mtg.Step.MAIN1)
	var ogre := put_battlefield(0, "Gray Ogre")
	var bear := put_battlefield(1, "Grizzly Bears")
	_mark(bear)
	var form := give_hand(0, "Gaseous Form")
	add_mana(0, Mtg.ManaColor.U, 3)
	assert_ok(g.cast_spell(0, form, [TargetRef.card(ogre)]))
	resolve_stack()
	assert_eq(g.deal_damage(ogre, TargetRef.card(bear), 2, true), 2)
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
	resolve_stack()
	assert_eq(bear.zone, Mtg.Zone.EXILE)


func test_rock_hydra_counters_cannot_prevent_marked_damage() -> void:
	var hydra := put_battlefield(1, "Rock Hydra")
	g.add_counters(hydra, "+1/+1", 4)
	_mark(hydra)
	var ogre := put_battlefield(0, "Gray Ogre")
	assert_eq(g.deal_damage(ogre, TargetRef.card(hydra), 2), 2)
	assert_eq(hydra.damage, 2)
	assert_eq(int(hydra.counters.get("+1/+1", 0)), 4)


func test_source_redirect_and_martyr_do_not_move_marked_damage() -> void:
	var bear := put_battlefield(1, "Grizzly Bears")
	_mark(bear)
	var ogre := put_battlefield(0, "Gray Ogre")
	ogre.damage_all_redirect_to = 0  # setup Reverberation's replacement
	g.players[1].may_take_creature_damage = true  # Blood of the Martyr
	assert_eq(g.deal_damage(ogre, TargetRef.card(bear), 2), 2)
	assert_eq(g.players[0].life, 20)
	assert_eq(g.players[1].life, 20)
	assert_eq(bear.zone, Mtg.Zone.GRAVEYARD)
