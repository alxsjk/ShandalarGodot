extends GutTest
## Playtest: persistent hacks need visible, non-targetable reminder cards.

var screen: DuelScreen


func before_each() -> void:
	screen = load("res://game/duel/duel_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.stops.clear_all()
	screen.game.agents[0] = DecisionAgent.new()
	screen.game.agents[1] = DecisionAgent.new()


func _card(card_name: String, pid := 0) -> CardInstance:
	var g := screen.game
	var inst := CardInstance.new(CardRegistry.get_card(card_name), g._next_instance_id, pid)
	g._next_instance_id += 1
	g._instances[inst.id] = inst
	g._put_on_battlefield(inst, pid)
	return inst


func _faces(root: Node) -> Array[MiniCard]:
	var out: Array[MiniCard] = []
	if root is MiniCard:
		out.append(root)
	for child in root.get_children():
		out.append_array(_faces(child))
	return out


func _ghosts(root: Node) -> Array[MiniCard]:
	var out: Array[MiniCard] = []
	for face in _faces(root):
		if String(face.name).begins_with("TextChangeGhost"):
			out.append(face)
	return out


func _redraw() -> void:
	screen._refresh()
	for _frame in 3:
		await get_tree().process_frame


func test_each_hack_effect_draws_a_read_only_reminder(pid = use_parameters([0, 1])) -> void:
	var cases := [
		["Swamp", "land_type", "swamp", "island", "Magical Hack", "Swamp becomes Island"],
		["Black Knight", "color_word", Mtg.ManaColor.W, Mtg.ManaColor.G,
			"Sleight of Mind", "White becomes Green"],
		["Plains", "mana_color", Mtg.ManaColor.W, Mtg.ManaColor.C,
			"Quarum Trench Gnomes", "White becomes Colorless"],
	]
	for spec in cases:
		var host := _card(spec[0], pid)
		screen.game.change_text(host, spec[1], spec[2], spec[3])
		var widget := screen._make_widget(host)
		add_child_autofree(widget)
		var ghosts := _ghosts(widget)
		assert_eq(ghosts.size(), 1, spec[4] + " leaves a reminder")
		if ghosts.is_empty():
			continue
		var ghost := ghosts[0]
		assert_eq(ghost.instance.data.card_name, spec[4])
		assert_string_contains(ghost.tooltip_text, spec[5])
		assert_string_contains(ghost.tooltip_text, "not a permanent")
		assert_eq(ghost.instance.id, -1)
		assert_true(ghost.disabled)
		assert_eq(ghost.focus_mode, Control.FOCUS_NONE)
		assert_eq(ghost.size, MiniCard.SIZE)
		assert_eq(ghost.instance.controller_id, pid)
		assert_true(host.attachments.is_empty(), "the marker is not a rules attachment")
		assert_null(screen.game.find_instance(-1), "no extra engine object")
		ghost.mouse_entered.emit()
		assert_eq(screen._card_preview._shown, ghost.instance)
		assert_eq(screen._fan_steps(host), 1)
		assert_true(TargetSpec.new(TargetSpec.Kind.PERMANENT).legal_targets(screen.game, host).all(
			func(target: TargetRef) -> bool: return target.instance_id != -1))


func test_reminders_never_disclose_the_identity_of_a_face_down_target() -> void:
	var host := _card("Black Knight", 1)
	screen.game.change_text(host, "color_word", Mtg.ManaColor.W, Mtg.ManaColor.G)
	host.face_down = true
	var widget := screen._make_widget(host)
	add_child_autofree(widget)
	assert_true(_ghosts(widget).is_empty())
	assert_eq(screen._fan_steps(host), 0)
	host.face_down = false
	var revealed := screen._make_widget(host)
	add_child_autofree(revealed)
	assert_eq(_ghosts(revealed).size(), 1, "turning face up restores its still-recorded effect")


func test_a_hacked_land_keeps_its_marker_when_other_lands_form_a_pile() -> void:
	var host := _card("Swamp")
	_card("Forest")
	_card("Mountain")
	screen.game.change_text(host, "land_type", "swamp", "island")
	await _redraw()
	assert_eq(_ghosts(screen).size(), 1)
	var span := screen._placement_span(host)
	assert_eq(span.position.y, -DuelScreen.AURA_PEEK.y,
		"drag clamping includes the marker above its land")
	assert_true(host.has_subtype("island"), "the rules change is intact")


func test_repeated_hacks_coexist_with_real_auras_choice_and_shield() -> void:
	var host := _card("Aswan Jaguar")
	screen.game.stack.clear()
	host.memory["type"] = "elf"
	var aura := _card("Holy Strength")
	screen.game.attach_aura_from_anywhere(aura, host, 0)
	host.prevention = 3
	host.prevention_source = CardRegistry.get_card("Healing Salve")
	screen.game.change_text(host, "land_type", "swamp", "island")
	screen.game.change_text(host, "land_type", "island", "forest")
	var widget := screen._make_widget(host)
	add_child_autofree(widget)
	var ghosts := _ghosts(widget)
	assert_eq(ghosts.size(), 2, "each applied change stays inspectable in order")
	assert_eq(screen._fan_steps(host), 5)
	var positions: Array[Vector2] = []
	for face in _faces(widget):
		if face.instance.id == host.id:
			continue
		assert_false(positions.has(face.position), "no overlapping title strips")
		positions.append(face.position)
	assert_eq(positions.size(), 5)
	assert_eq(host.attachments, [aura.id], "only the real Aura is attached")


func test_hack_marker_survives_cleanup_but_not_leaving_and_returning() -> void:
	var host := _card("Swamp")
	screen.game.change_text(host, "land_type", "swamp", "island")
	screen.game._cleanup_step()
	await _redraw()
	assert_eq(_ghosts(screen).size(), 1, "not a one-turn effect")
	screen.game.return_to_hand(host)
	await _redraw()
	assert_true(host.text_changes.is_empty())
	assert_eq(_ghosts(screen).size(), 0)
	screen.game._put_on_battlefield(host, 0)
	await _redraw()
	assert_eq(_ghosts(screen).size(), 0, "a new object has no stale reminder")


func test_resolving_the_real_hack_spell_creates_the_reminder(
		spec = use_parameters([["Magical Hack", "Swamp"], ["Sleight of Mind", "Black Knight"]])) -> void:
	var g := screen.game
	var host := _card(spec[1], 1)
	var source := CardInstance.new(CardRegistry.get_card(spec[0]), g._next_instance_id, 0)
	g._next_instance_id += 1
	g._instances[source.id] = source
	source.zone = Mtg.Zone.HAND
	g.players[0].hand.append(source)
	var printed := source.data.oracle_text
	g.active_player = 0
	g.priority_player = 0
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.MAIN1)
	g.players[0].mana_pool.add(Mtg.ManaColor.U, 1)
	assert_eq(g.cast_spell(0, source, [TargetRef.card(host)]), "")
	var passes := 0
	while not g.stack.is_empty() and passes < 8:
		assert_eq(g.pass_priority(g.priority_player), "")
		passes += 1
	for _frame in 3:
		await get_tree().process_frame
	assert_eq(_ghosts(screen).size(), 1, "the engine's state signal redraws the hack")
	assert_eq(source.zone, Mtg.Zone.GRAVEYARD, "the instant still goes to the graveyard")
	assert_eq(CardRegistry.get_card(spec[0]).oracle_text, printed,
		"reminder text never mutates the printed definition")


func test_shamans_circle_change_includes_its_upkeep_reminder() -> void:
	var host := _card("Circle of Protection: Red")
	# Public state recorded by the Ice Age adaptation, separate from text_changes.
	host.memory["shaman_circle_color"] = Mtg.ManaColor.G
	await _redraw()
	var ghosts := _ghosts(screen)
	assert_eq(ghosts.size(), 1)
	if ghosts.is_empty():
		return
	assert_eq(ghosts[0].instance.data.card_name, "Balduvian Shaman")
	assert_string_contains(ghosts[0].tooltip_text, "Circle protection: Green")
	assert_string_contains(ghosts[0].tooltip_text, "Cumulative upkeep {1}")
	screen.game.return_to_hand(host)
	await _redraw()
	assert_eq(_ghosts(screen).size(), 0)


func test_hacked_spell_keeps_reminder_from_chain_to_battlefield() -> void:
	var g := screen.game
	var host := _card("Bog Wraith")
	g.return_to_hand(host)
	g.active_player = 0
	g.priority_player = 0
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.MAIN1)
	g.players[0].mana_pool.add(Mtg.ManaColor.B, 4)
	assert_eq(g.cast_spell(0, host), "")
	g.change_text(host, "land_type", "swamp", "island")
	await _redraw()
	assert_eq(_ghosts(screen._chain_box).size(), 1, "visible before the target resolves")
	var caption: Control = screen._chain_box.get_child(0).get_child(0)
	for ghost in _ghosts(screen._chain_box):
		assert_gte(ghost.get_global_rect().position.y, caption.get_global_rect().end.y,
			"the reminder never covers the spell-chain caption")
	for face in _faces(screen._chain_box):
		if face.instance.id == host.id:
			assert_gt(face.pressed.get_connections().size(), 0, "the real spell remains targetable")
			assert_string_contains(face.tooltip_text, g.stack[0].description)
	var passes := 0
	while not g.stack.is_empty() and passes < 8:
		assert_eq(g.pass_priority(g.priority_player), "")
		passes += 1
	await _redraw()
	assert_eq(host.zone, Mtg.Zone.BATTLEFIELD)
	assert_eq(_ghosts(screen).size(), 1, "same change, now on the battlefield")
	assert_true(host.cur_landwalk.has("island"))


func test_hacked_attacker_has_the_reminder_in_combat() -> void:
	var host := _card("Bog Wraith")
	host.summoning_sick = false
	screen.game.change_text(host, "land_type", "swamp", "island")
	screen.game.active_player = 0
	screen.game._step_index = Mtg.STEP_ORDER.find(Mtg.Step.DECLARE_ATTACKERS)
	screen.game.awaiting_attackers = true
	assert_eq(screen.game.declare_attackers(0, [host.id]), "")
	await _redraw()
	assert_eq(_ghosts(screen._combat_window).size(), 1)


func test_tapped_hacked_land_keeps_the_fan_at_its_visible_corner() -> void:
	var host := _card("Swamp")
	screen.game.change_text(host, "land_type", "swamp", "island")
	host.tapped = true
	var widget := screen._make_widget(host)
	add_child_autofree(widget)
	var ghosts := _ghosts(widget)
	assert_eq(ghosts.size(), 1)
	if ghosts.is_empty():
		return
	var corner := (MiniCard.TURN_HOLDER_SIZE - Vector2(MiniCard.SIZE.y, MiniCard.SIZE.x)) / 2.0
	assert_eq(ghosts[0].position, corner + Vector2(DuelScreen.AURA_PEEK.x, -DuelScreen.AURA_PEEK.y))


func test_hack_reminders_are_not_clipped_at_either_territorys_top_edge() -> void:
	for pid in [0, 1]:
		var host := _card("Swamp", pid)
		screen.game.change_text(host, "land_type", "swamp", "island")
		await _redraw()
		var half: Rect2 = screen._free_layers[pid].get_global_rect()
		for ghost in _ghosts(screen):
			if ghost.instance.controller_id == pid:
				assert_true(half.encloses(ghost.get_global_rect()),
					"the full reminder fits inside its clipped territory")
		screen.game.return_to_hand(host)
		await _redraw()
		assert_eq(screen._half_rows[pid].offset_top, DuelScreen.BOARD_INSET_V,
			"ordinary spacing returns when the hack is gone")
