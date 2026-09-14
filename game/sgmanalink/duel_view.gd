class_name SgDuelView
extends DuelScreen
## Transport adapter for the actual duel screen, not a second interface.
## All gameplay state comes from a filtered view; no client rules simulation.

signal action_requested(action: Dictionary)
signal reconnect_requested
signal exit_requested

var projection := SgDuelProjection.new()
var _room: Dictionary = {}
var _online := false
var _busy := false
var _built := false
var _presenting := false
var _sent_revision := -1
var _awaiting_ack := false
var _sent_op := ""
var _prepared_key := ""
var _auto_pay_requested := false
var _last_cue := -1
var _last_visual_event := -1
var _network_badge: Button
var _network_opening: OpeningWindow
var _network_dialog: OriginalDialog
var _opening_started := false
var _shown_choice: Dictionary = {}
var _result_seen := false
var _hosting := false


func _ready() -> void:
	# Never run the parent's local _new_game/setup. Wait for the filtered view.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func present(room: Dictionary, online: bool, busy: bool, hosting := false) -> void:
	_hosting = hosting
	_online = online
	_busy = busy
	if _presenting:
		projection.locked = true
		return
	if not SgViewProtocol.room(room) or room.is_empty() or room.game.is_empty(): return
	_presenting = true
	_room = room.duplicate(true)
	if _awaiting_ack and int(room.revision) > _sent_revision and not busy: _awaiting_ack = false
	projection.locked = not online or busy or _awaiting_ack or not (room.connected[0] and room.connected[1])
	projection.ingest(_room)
	hidden_hands.assign([] if projection.players[1].hand_revealed else [1])
	if not _built:
		game = projection
		config = DuelConfig.new()
		for remote in 2:
			var pid := projection.local_seat(remote)
			config.player_names[pid] = room.names[remote]
			config.deck_names[pid] = room.deck_names[remote]
		config.panel_colors = ["blue", "red"]
		config.decks[0] = room.deck.cards.duplicate() if not room.deck.is_empty() else []
		_humans[0] = HumanAgent.new()
		projection.action_requested.connect(_dispatch)
		_build_ui()
		_build_network_controls()
		_built = true
		_play_music()
	if _shown_choice != room.game.choice:
		_close_choice_overlay()
		_choice_picks.clear()
		_shown_choice = room.game.choice.duplicate(true)
	_present_visual_events()
	if not projection.locked: _sync_announcement()
	_refresh()
	_present_cues()
	if game.game_over and not _result_seen:
		_result_seen = true
		_on_game_over(game.winner)
	if game.mulligan_open and not _opening_started:
		_opening_started = true
		_toss_active = true
		if DisplayServer.get_name() == "headless": _run_opening_hand(projection.local_seat(int(room.game.presentation.toss)))
		else: _run_coin_toss(projection.local_seat(int(room.game.presentation.toss)))
	_update_opening()
	_presenting = false


func _dispatch(action: Dictionary) -> void:
	_sent_revision = int(_room.revision)
	_awaiting_ack = true
	_sent_op = action.op
	action_requested.emit(action)


func _send(action: Dictionary) -> void:
	var error := projection.send(action)
	if not error.is_empty(): _report(error)


func _is_human(pid: int) -> bool:
	return pid == 0


func _network_opponent() -> bool:
	return true


func _waiting_for_action() -> bool:
	return projection.locked


func _maybe_schedule_ai() -> void:
	pass


func _refresh() -> void:
	if not _built: return
	# A received view can cross several engine transitions at once. Drop the
	# previous declaration before the shared refresh enters the next one.
	var gates := {Mode.ATTACKERS: "attack", Mode.BLOCKERS: "block", Mode.DISCARD: "discard", Mode.DAMAGE: "damage"}
	if gates.has(mode) and projection.view.mode != gates[mode]:
		mode = Mode.NORMAL
		_selected_attackers.clear()
		_block_map.clear()
		_selected_blocker = -1
		_discard_picks.clear()
		_damage_picks.clear()
	super._refresh()
	_pass_button.disabled = projection.locked or game.game_over
	_network_badge.text = "Online" if _online else "Reconnect"
	if not _room.connected[0] or not _room.connected[1]: _network_badge.text = "Suspended"
	if projection.locked and not game.game_over and not game.mulligan_open:
		_prompt_label.text = "Waiting for host…" if _online and _busy else "Waiting for connection…"


func _drive_advance() -> void:
	if projection.locked or game.mulligan_open: return
	super._drive_advance()


func _auto_pass_applies() -> bool:
	return not projection.locked and not game.mulligan_open and super._auto_pass_applies()


func _could_respond(pid: int) -> bool:
	return pid == 0 and projection.presentation.respond


func _has_affordable_fast_effect(pid: int) -> bool:
	return pid == 0 and projection.presentation.floating


func _attack_refusal(inst: CardInstance) -> String:
	return projection.attack_refusal(inst)


func _block_refusal(blocker: CardInstance, attacker: CardInstance, _defender: int) -> String:
	return projection.block_refusal(blocker, attacker)


func _on_done() -> void:
	if not projection.locked: super._on_done()


func _on_card_clicked(inst: CardInstance) -> void:
	if projection.locked: return
	if mode == Mode.NORMAL and inst.zone == Mtg.Zone.BATTLEFIELD and not _modal_open() and not _toss_active:
		_click_permanent(inst)
		return
	super._on_card_clicked(inst)


func _on_life_clicked(pid: int) -> void:
	if not projection.locked: super._on_life_clicked(pid)


func _click_hand_card(inst: CardInstance) -> void:
	if inst.owner_id != 0 or game.priority_player != 0: return
	if inst.is_land():
		_report(game.play_land(0, inst))
		return
	_pending_card = inst
	_pending_pid = 0
	_pending_ability_index = -1
	_pending_targets = []
	_pending_x = 0
	_pending_mode = 0
	_prepared_key = ""
	if inst.data.is_modal(): _open_mode_menu(inst)
	else: _continue_cast_chain()


func _continue_cast_chain() -> void:
	# Searches wait for a rule-authorized question from the referee.
	if _pending_card.data.cost.has_x: _open_x_dialog()
	else: _prepare()


func _prepare() -> void:
	if _pending_card == null: return
	_send({"op": "prepare", "card": projection.handle(_pending_card.id),
		"kind": "spell" if _pending_ability_index < 0 else "ability",
		"index": maxi(0, _pending_ability_index), "x": _pending_x, "mode": _pending_mode})


func _sync_announcement() -> void:
	var announcement: Dictionary = projection.view.announcement
	var draft: Dictionary = projection.presentation.draft
	if announcement.is_empty():
		if not _prepared_key.is_empty():
			_clear_pending(true)
			_prepared_key = ""
		return
	if mode == Mode.PAYING and not draft.reachable:
		_clear_pending()
		_send({"op": "cancel"})
		_report("Not enough available mana for this action.")
		return
	var key := "%s/%s/%d/%d/%d" % [draft.card, draft.kind, draft.index, draft.x, draft.mode]
	var starting := key != _prepared_key
	if starting:
		var target_count := _pending_target_count
		_clear_pending()
		_pending_target_count = target_count
		_pending_card = game.find_instance(projection.local_id(draft.card))
		if _pending_card == null: return
		_pending_pid = 0
		_pending_ability_index = -1 if draft.kind == "spell" else int(draft.index)
		_pending_x = int(draft.x)
		_pending_mode = int(draft.mode)
		_prepared_key = key
	var refs := {}
	for entry in projection.presentation.targets: refs[entry.token] = entry.ref
	_pending_slots.clear()
	_pending_specs.clear()
	for slot in announcement.slots:
		var spec := SgTargetSpec.new(int(slot.kind), slot.label)
		for candidate in slot.targets:
			var ref: Dictionary = refs.get(candidate.id, {})
			if ref.is_empty(): continue
			spec.candidates.append(projection.target(ref))
			spec.tokens.append(candidate.id)
		var minimum := int(slot.min)
		var maximum := int(slot.max)
		if _pending_target_count > 0 and maximum > 1:
			minimum = _pending_target_count
			maximum = _pending_target_count
		_pending_slots.append({"spec": spec, "min": minimum, "max": maximum, "divided": int(slot.divided)})
		_pending_specs.append(spec)
	if starting:
		_pending_groups.clear()
		for slot in _pending_slots: _pending_groups.append([])
		_pending_slot = 0
		if _auto_pay_requested:
			_auto_pay_requested = false
			_auto_tap_for_pending()
		else: _advance_pending()
	elif mode == Mode.NORMAL and _pending_card != null: _advance_pending()


func _submit_pending() -> void:
	if projection.locked or _pending_card == null: return
	var targets: Array = []
	for i in _pending_groups.size():
		for ref in _pending_groups[i]:
			var token := (_pending_slots[i].spec as SgTargetSpec).token_for(ref)
			if token.is_empty():
				_report("That target is no longer available. Choose again.")
				_pending_groups[i] = []
				_pending_slot = i
				_advance_pending()
				return
			targets.append([token, ref.amount])
	_send({"op": "submit", "targets": targets})


func show_notice(message: String) -> void:
	_awaiting_ack = false
	projection.locked = false
	if _sent_op == "submit" and MtgGame.is_unpaid_refusal(message) and _pending_card != null:
		mode = Mode.PAYING
		_paying_pool = game.players[0].mana_pool.total()
		_set_target_cursor(false)
		_set_prompt(GRAB_MANA_PROMPT % _pending_card.data.card_name)
		return
	if _sent_op == "prepare": _clear_pending()
	_report(message)


func _retry_payment() -> void:
	if not projection.locked: super._retry_payment()


func _auto_cast(inst: CardInstance) -> void:
	if _pending_card != inst:
		if projection.locked: return
		_click_hand_card(inst)
	if _pending_card != inst: return
	if _x_dialog != null:
		_x_spin.value = _option_detail().get("budget", 0)
		_on_x_confirmed()
	if projection.locked:
		_auto_pay_requested = true
		return
	_auto_tap_for_pending()


func _auto_tap_for_pending() -> void:
	if projection.locked or _prepared_key.is_empty():
		_auto_pay_requested = true
		return
	var excluded: Array = []
	for id in _no_auto_tap:
		var handle := projection.handle(id)
		if not handle.is_empty(): excluded.append(handle)
	_send({"op": "autopay", "excluded": excluded, "count": maxi(maxi(1, _pending_target_count), _flatten_pending_targets().size())})


func _option_detail() -> Dictionary:
	if _pending_card == null: return {}
	var detail: Dictionary = projection.details.get(projection.handle(_pending_card.id), {})
	for option in detail.get("abilities", []):
		if (_pending_ability_index < 0 and option.kind == "spell") \
			or (option.kind == "ability" and option.index == _pending_ability_index): return option
	return {}


func _open_x_dialog() -> void:
	var option := _option_detail()
	var cost := ManaCost.parse(option.get("cost", ""))
	var per_x := maxi(1, cost.x_count)
	var per_target := _pending_card.data.extra_cost_per_target if _pending_ability_index < 0 else 0
	_x_dialog = FireballDialog.window(_pending_card.data.card_name, int(option.get("budget", 0)), per_target, SgProtocol.MAX_CARDS, per_x)
	_x_spin = _x_dialog.get_meta("mana")
	_x_dialog.add_button("OK").pressed.connect(_on_x_confirmed)
	_x_dialog.add_button("Cancel").pressed.connect(_on_x_canceled)
	add_child(_x_dialog)


func _on_x_confirmed() -> void:
	if _pending_card == null: return
	var per_x := maxi(1, ManaCost.parse(_option_detail().get("cost", "")).x_count)
	var per_target := _pending_card.data.extra_cost_per_target if _pending_ability_index < 0 else 0
	var count := int(_x_dialog.get_meta("targets").value) if _x_dialog.has_meta("targets") else 1
	var plan := FireballDialog.plan(int(_x_spin.value), int(_x_spin.value), count, per_target, per_x)
	_pending_x = int(plan.x)
	_pending_target_count = count if per_target > 0 else -1
	_x_dialog.dismiss()
	_x_dialog = null
	_prepare()


func _click_permanent(inst: CardInstance) -> void:
	var options: Array = projection.faces.get(projection.handle(inst.id), {}).get("actions", [])
	if options.size() == 1 and options[0].kind == "mana": _report(game.tap_for_mana(0, inst, int(options[0].index)))
	elif not options.is_empty(): _open_ability_menu(inst)


func _tap_for_payment(inst: CardInstance) -> void:
	_open_ability_menu(inst, true)


func _open_ability_menu(inst: CardInstance, mana_only := false) -> void:
	_ability_menu.clear()
	var options: Array = []
	for option in projection.faces.get(projection.handle(inst.id), {}).get("actions", []):
		if not mana_only or option.kind == "mana": options.append(option)
	if mana_only and options.size() == 1:
		_report(game.tap_for_mana(0, inst, int(options[0].index)))
		return
	if options.is_empty(): return
	for i in options.size(): _ability_menu.add_item(options[i].label, i)
	_ability_menu.set_meta("network_options", options)
	_ability_menu.set_meta("instance_id", inst.id)
	_ability_menu.position = Vector2i(_pointer())
	_ability_menu.popup()


func _on_ability_chosen(index: int) -> void:
	if projection.locked: return
	var inst := game.find_instance(int(_ability_menu.get_meta("instance_id")))
	var options: Array = _ability_menu.get_meta("network_options", [])
	if inst == null or index < 0 or index >= options.size(): return
	var option: Dictionary = options[index]
	if option.kind == "mana":
		_report(game.tap_for_mana(0, inst, int(option.index)))
		return
	_pending_card = inst
	_pending_pid = 0
	_pending_ability_index = int(option.index)
	_pending_x = 0
	_pending_mode = 0
	_prepared_key = ""
	if option.x: _open_x_dialog()
	else: _prepare()


func _on_cancel() -> void:
	if projection.locked: return
	if _pending_card != null and not _prepared_key.is_empty(): _send({"op": "cancel"})
	super._on_cancel()
	_prepared_key = ""
	_auto_pay_requested = false


func _highlight_for(inst: CardInstance) -> int:
	if mode == Mode.NORMAL and inst.zone == Mtg.Zone.HAND:
		var face: Dictionary = projection.faces.get(projection.handle(inst.id), {})
		var detail: Dictionary = projection.details.get(projection.handle(inst.id), {})
		return MiniCard.Highlight.OPTIONAL if face.get("playable", false) or detail.get("castable", false) else MiniCard.Highlight.NONE
	return super._highlight_for(inst)


func _can_act_on(inst: CardInstance) -> bool:
	if game.priority_player != 0: return false
	for option in projection.faces.get(projection.handle(inst.id), {}).get("actions", []):
		if option.kind == "ability": return true
	return false


func _open_choice_overlay() -> void:
	if _choice_overlay == null and game.awaiting_choice != null and game.awaiting_choice.pid == 0:
		_build_choice_overlay(game.awaiting_choice)


func _on_choice_option(index: int) -> void:
	if projection.locked or projection.view.choice.is_empty(): return
	var choice: Dictionary = projection.view.choice
	if index < 0 or index >= choice.options.size(): return
	if _choice_picks.has(index): _choice_picks.remove_at(_choice_picks.find(index))
	else: _choice_picks.append(index)
	if _choice_picks.size() == int(choice.count): _report(game.answer_choice(Array(_choice_picks)))
	else:
		_close_choice_overlay()
		_build_choice_overlay(game.awaiting_choice)


## Keep the shared splash, but never navigate into the offline setup from
## an online session. The child-owned wait also ends safely on disconnect.
func _run_intro() -> void:
	var intro := DuelIntro.new()
	intro.z_index = 260
	add_child(intro)
	intro.build(config, "Leave duel")
	_intro_overlay = intro
	intro.reconfigure_pressed.connect(_request_exit)
	await intro.go_pressed
	if is_instance_valid(intro): intro.queue_free()
	_intro_overlay = null


func _run_opening_hand(_winner: int) -> void:
	_network_opening = OpeningWindow.new()
	_network_opening.z_index = 230
	add_child(_network_opening)
	_network_opening.answered.connect(_opening_answer)
	_update_opening()
	_toss_active = false


func _update_opening() -> void:
	if _network_opening == null: return
	for row in _hand_rows: row.visible = not game.mulligan_open
	if not game.mulligan_open or game.game_over:
		_network_opening.close()
		_network_opening = null
		return
	var deciding := projection.local_seat(int(projection.view.actor)) == 0
	_network_opening.show_antes(game, 0)
	_network_opening.show_hand(game, 0, config.panel_colors[0])
	var ordered: bool = projection.presentation.order
	_network_opening.set_lead(("You will take the first turn" if projection.local_seat(int(projection.view.first)) == 0 else "%s will take the first turn" % config.player_names[1]) \
		if ordered else ("You won the coin toss" if deciding else "%s won the coin toss" % config.player_names[1]))
	_network_opening.set_status("" if deciding else "Waiting for %s" % config.player_names[1])
	_network_opening.set_answers([
		{"answer": 0, "label": "Take mulligan" if ordered else "Play first", "disabled": not deciding or projection.locked or (ordered and game.players[0].hand.is_empty())},
		{"answer": 1, "label": "Start the duel" if ordered else "Draw first", "disabled": not deciding or projection.locked}])


func _opening_answer(answer: int) -> void:
	if projection.locked: return
	if not projection.presentation.order: _send({"op": "order", "play": answer == 0})
	else: _send({"op": "mulligan" if answer == 0 else "keep"})


func _present_cues() -> void:
	for item in projection.presentation.cues:
		if _last_cue >= 0 and int(item.serial) > _last_cue: _play_sfx(item.cue)
	var cues: Array = projection.presentation.cues
	_last_cue = maxi(_last_cue, int(cues.back().serial)) if not cues.is_empty() else maxi(_last_cue, 0)


func _present_visual_events() -> void:
	for event in projection.presentation.events:
		if int(event.serial) <= _last_visual_event or _last_visual_event < 0: continue
		var card := game.find_instance(projection.local_id(event.card))
		if card == null: continue
		if event.kind == "draw" and card.owner_id == 0 and game.turn_number > 0:
			_card_preview.show_card(card)
		elif event.kind == "dies":
			game.event_occurred.emit(GameEvent.new(Mtg.EventType.DIES, {"instance": card, "sacrificed": event.sacrificed}))
	var events: Array = projection.presentation.events
	_last_visual_event = maxi(_last_visual_event, int(events.back().serial)) if not events.is_empty() else maxi(_last_visual_event, 0)


func _build_network_controls() -> void:
	_network_badge = UiChrome.menu_button("Online", Vector2(105, 30), 13)
	_network_badge.position = Vector2(4, 4)
	_network_badge.tooltip_text = "Unrated player-hosted duel. Your opponent's hidden hand and library are not sent to this client. The host runs the referee."
	_network_badge.pressed.connect(_show_connection)
	_qol_reserve.add_child(_network_badge)


func _show_connection() -> void:
	var dialog := _network_window("SGManalink · Friendly duel")
	var column := VBoxContainer.new()
	column.position = Vector2(24, 54)
	column.custom_minimum_size.x = 510
	column.add_child(OriginalDialog.label("Connected to the host" if _online else "Reconnecting to the host…", 16))
	for entry in [["Revealed information", _show_information], ["Special actions", _show_specials],
		["Reconnect", reconnect_requested.emit], ["Duel menu", _toggle_pause]]:
		var button := OriginalDialog.choice_line(entry[0])
		var callback: Callable = entry[1]
		button.pressed.connect(func() -> void:
			dialog.dismiss()
			callback.call())
		column.add_child(button)
	dialog.add_child(column)


func _show_information() -> void:
	var dialog := _network_window("Revealed information")
	var lines: Array[String] = []
	for player in projection.view.players:
		if not player.top.is_empty(): lines.append("%s — revealed library top: %s" % [_room.names[int(player.seat)], player.top])
		if not player.revealed.is_empty():
			var names: Array[String] = []
			for card in player.revealed: names.append(card.name)
			lines.append("%s — currently revealed hand cards\n%s" % [_room.names[int(player.seat)], ", ".join(names)])
	for info in projection.view.information: lines.append(info.title + "\n" + ", ".join(info.cards))
	if lines.is_empty(): lines.append("No cards have been revealed by an effect.")
	var text := OriginalDialog.label("\n\n".join(lines), 14)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(24, 54)
	scroll.size = Vector2(510, 300)
	text.custom_minimum_size.x = 490
	scroll.add_child(text)
	dialog.add_child(scroll)


func _show_specials() -> void:
	var dialog := _network_window("Special actions")
	var column := VBoxContainer.new()
	column.position = Vector2(24, 54)
	column.size = Vector2(510, 280)
	for i in projection.view.specials.size():
		var button := OriginalDialog.choice_line(projection.view.specials[i])
		button.disabled = projection.locked or game.priority_player != 0
		button.pressed.connect(func() -> void:
			dialog.dismiss()
			_send({"op": "special", "index": i}))
		column.add_child(button)
	if column.get_child_count() == 0: column.add_child(OriginalDialog.label("No special actions available.", 14))
	dialog.add_child(column)


func _network_window(title: String) -> OriginalDialog:
	if is_instance_valid(_network_dialog): _network_dialog.dismiss()
	_network_dialog = OriginalDialog.create(title, Vector2(560, 420))
	_network_dialog.z_index = 280
	_network_dialog.add_button("Close").pressed.connect(_network_dialog.dismiss)
	add_child(_network_dialog)
	return _network_dialog


func _modal_open() -> bool:
	return is_instance_valid(_network_dialog) or is_instance_valid(_network_opening) or super._modal_open()


func toggle_menu() -> void:
	_toggle_pause()


func focus_action() -> void:
	if _built and not _pass_button.disabled: _pass_button.grab_focus()


func _on_pause_chosen(action: int) -> void:
	if action in [DuelPause.Action.EXIT_DUEL, DuelPause.Action.MAIN_MENU, DuelPause.Action.QUIT]:
		_close_pause()
		_request_exit()
	else: super._on_pause_chosen(action)


func _request_exit() -> void:
	var dialog := _network_window("Leave SGManalink?")
	var label := OriginalDialog.label("Closing the host disconnects both players and ends this hosted session." if _hosting else "Closing forgets this seat. Concede first if you want to record a result.", 16)
	label.position = Vector2(24, 60)
	label.size = Vector2(510, 180)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog.add_child(label)
	dialog.add_button("Confirm close").pressed.connect(exit_requested.emit)


func _on_game_over_dismissed() -> void:
	super._on_game_over_dismissed()
	exit_requested.emit()
