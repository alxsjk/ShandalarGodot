extends GutTest
## THE COMBAT WINDOW — the 1997 lineup window titled `Your attack`
## (manual p.126, `Duel.hlp` topic "Combat"; game/duel/combat_window.gd).


var screen: DuelScreen
var _saved_position: Variant


func before_each() -> void:
	_saved_position = Settings.get_value(CombatWindow.POS_SETTING, null) \
		if Settings.has_value(CombatWindow.POS_SETTING) else null
	Settings.clear_value(CombatWindow.POS_SETTING)
	screen = load("res://game/duel/duel_screen.tscn").instantiate()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.game._step_index = Mtg.STEP_ORDER.find(Mtg.Step.DECLARE_ATTACKERS)
	screen.set_process(false)


func after_each() -> void:
	if _saved_position == null:
		Settings.clear_value(CombatWindow.POS_SETTING)
	else:
		Settings.set_value(CombatWindow.POS_SETTING, _saved_position)


func _drag_window(to: Vector2, release := true) -> void:
	var win := screen._combat_window
	var grip := Vector2(50, 12)
	var down := InputEventMouseButton.new()
	down.button_index = MOUSE_BUTTON_LEFT
	down.pressed = true
	down.global_position = win.global_position + grip
	win._on_bar_input(down)
	var move := InputEventMouseMotion.new()
	move.button_mask = MOUSE_BUTTON_MASK_LEFT
	move.global_position = to + grip
	win._on_bar_input(move)
	if release:
		var up := InputEventMouseButton.new()
		up.button_index = MOUSE_BUTTON_LEFT
		up.global_position = move.global_position
		win._on_bar_input(up)


func test_dragged_position_survives_refresh_phases_restore_and_next_combat() -> void:
	var g := screen.game
	var lion := _summon(g, "Savannah Lions", g.active_player)
	g.combat.attackers[lion.id] = true
	screen._refresh()
	var chosen := Vector2(40, 90)
	_drag_window(chosen)
	assert_eq(Settings.get_value(CombatWindow.POS_SETTING, null), chosen)
	for step in [Mtg.Step.DECLARE_ATTACKERS, Mtg.Step.DECLARE_BLOCKERS,
			Mtg.Step.COMBAT_DAMAGE, Mtg.Step.COMBAT_END]:
		g._step_index = Mtg.STEP_ORDER.find(step)
		screen._refresh()
		assert_true(screen._combat_window.visible)
		assert_eq(screen._combat_window.position, chosen, "refresh must not re-center")
	screen._on_combat_minimized(true)
	screen._on_window_icon_pressed()
	assert_eq(screen._combat_window.position, chosen, "minimize/restore keeps the position")
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.MAIN2)
	screen._refresh()
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.DECLARE_ATTACKERS)
	screen._refresh()
	assert_eq(screen._combat_window.position, chosen, "the next combat keeps it too")


func test_refresh_during_drag_does_not_snap_back_before_release() -> void:
	var g := screen.game
	var lion := _summon(g, "Savannah Lions", g.active_player)
	g.combat.attackers[lion.id] = true
	screen._refresh()
	_drag_window(Vector2(45, 100), false)
	screen._refresh()
	assert_eq(screen._combat_window.position, Vector2(45, 100))
	assert_false(Settings.has_value(CombatWindow.POS_SETTING), "not persisted until release")


func test_saved_position_survives_first_fit_and_stays_reachable() -> void:
	var win := screen._combat_window
	Settings.set_value(CombatWindow.POS_SETTING, Vector2(35, 80))
	win.restore_position()
	win.fit(screen._board_area())
	assert_eq(win.position, Vector2(35, 80), "first combat must not overwrite a saved position")
	Settings.set_value(CombatWindow.POS_SETTING, Vector2(9000, 9000))
	win.restore_position()
	win.fit(Rect2(0, 0, 400, 300))
	var room := win.get_viewport_rect().size
	assert_lte(win.position.x, room.x - CombatWindow.EDGE - 60.0)
	assert_lte(win.position.y, room.y - CombatWindow.EDGE - CombatWindow.TITLE_H)
	assert_eq(Settings.get_value(CombatWindow.POS_SETTING, null), Vector2(9000, 9000),
		"layout clamping must not rewrite the player's saved preference")


func test_untouched_window_still_centers_when_board_size_changes() -> void:
	var win := screen._combat_window
	for area in [Rect2(100, 50, 1000, 700), Rect2(70, 30, 600, 500)]:
		win.fit(area)
		assert_eq(win.position + win.size * 0.5, area.get_center())
	assert_false(Settings.has_value(CombatWindow.POS_SETTING))


# ----------------------------------------------------------- the title --

func test_the_title_is_the_1997_window_title() -> void:
	# @WINDOWTITLES, shandalar-src/Program/UIStrings.txt:155.
	assert_eq(CombatWindow.title_for(0, 0, "You"), "Your attack")
	assert_eq(CombatWindow.title_for(1, 0, "AI Wizard"), "AI Wizard Attack")


# ------------------------------------------------------- when it opens --

func test_the_window_opens_on_the_first_attacker_and_not_before() -> void:
	# "As soon as you add the first creature to the attack, the Combat
	# window opens" (manual p.126).
	var g: MtgGame = screen.game
	screen._refresh()
	assert_false(screen._combat_window.visible,
		"a combat with no attacker has no window")
	var lion := _summon(g, "Savannah Lions", g.active_player)
	g.awaiting_attackers = true
	screen.mode = DuelScreen.Mode.ATTACKERS
	screen._selected_attackers = [lion.id]
	screen._refresh()
	assert_true(screen._combat_window.visible,
		"the first creature added opens the window")


func test_a_declaration_the_engine_stopped_waiting_for_is_dropped() -> void:
	# §3.5 / s30 duel.go:1629-1656 — a step that moved under us must not
	# leave phantom attackers in the Combat window.
	var g: MtgGame = screen.game
	var lion := _summon(g, "Savannah Lions", g.active_player)
	g.awaiting_attackers = true
	screen.mode = DuelScreen.Mode.ATTACKERS
	screen._selected_attackers = [lion.id]
	screen._refresh()
	assert_true(screen._combat_window.visible)
	# The step moves under us — anything but our own confirm or cancel.
	g.awaiting_attackers = false
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.MAIN2)
	screen._refresh()
	assert_eq(screen._selected_attackers, [] as Array[int],
		"the stale lineup is dropped")
	assert_eq(screen.mode, DuelScreen.Mode.NORMAL)
	assert_false(screen._combat_window.visible, "and its window closes")


func test_the_window_closes_when_combat_ends() -> void:
	var g: MtgGame = screen.game
	var lion := _summon(g, "Savannah Lions", g.active_player)
	g.combat.attackers[lion.id] = true
	screen._refresh()
	assert_true(screen._combat_window.visible)
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.MAIN2)
	screen._refresh()
	assert_false(screen._combat_window.visible,
		"post-combat main has no lineup to show")


# --------------------------------------------------------- the lineup --

func test_attackers_line_up_on_the_attacking_players_own_side() -> void:
	# "Your attackers line up on your side, and the space on the other side
	# is reserved for (potential) blockers" (manual p.126).
	var g: MtgGame = screen.game
	g.active_player = 0                       # the human attacks
	var mine := _summon(g, "Savannah Lions", 0)
	var theirs := _summon(g, "Savannah Lions", 1)
	g.combat.attackers[mine.id] = true
	g.combat.blocks[theirs.id] = mine.id
	screen._refresh()
	var lanes: Array = screen._combat_window.lane_ids()
	assert_eq(lanes[1], [mine.id], "the player's attackers take the LOWER lane")
	assert_eq(lanes[0], [theirs.id], "the blockers face them from the upper")


func test_an_opponents_attack_fills_the_upper_lane() -> void:
	var g: MtgGame = screen.game
	g.active_player = 1
	var theirs := _summon(g, "Savannah Lions", 1)
	var mine := _summon(g, "Savannah Lions", 0)
	g.combat.attackers[theirs.id] = true
	g.combat.blocks[mine.id] = theirs.id
	screen._refresh()
	var lanes: Array = screen._combat_window.lane_ids()
	assert_eq(lanes[0], [theirs.id], "their attackers take the UPPER lane")
	assert_eq(lanes[1], [mine.id], "our blockers take the lower")


func test_a_blocker_picked_but_not_yet_aimed_is_already_in_the_window() -> void:
	# "To make one of your creatures a blocker, click on it. Next, click on
	# the attacker you want your blocker to block."
	var g: MtgGame = screen.game
	g.active_player = 1
	var theirs := _summon(g, "Savannah Lions", 1)
	var mine := _summon(g, "Savannah Lions", 0)
	g.combat.attackers[theirs.id] = true
	screen._selected_blocker = mine.id
	screen._refresh()
	assert_eq(screen._combat_window.lane_ids()[1], [mine.id])


func test_a_creature_in_combat_leaves_its_territory() -> void:
	# The Manalink patch patch_not_in_combat_window_if_no_longer_attacking.pl
	# is only worth writing if the window normally takes them OUT of the
	# territory — and one widget per card is what keeps the arrows honest.
	var g: MtgGame = screen.game
	var lion := _summon(g, "Savannah Lions", g.active_player)
	var homebody := _summon(g, "Savannah Lions", g.active_player)
	g.combat.attackers[lion.id] = true
	screen._refresh()
	var on_board := _field_ids(g.active_player)
	assert_false(on_board.has(lion.id), "the attacker is in the window now")
	assert_true(on_board.has(homebody.id), "the one that stayed home is home")
	assert_eq(_widget_count(lion.id), 1,
		"exactly one widget per card, wherever it lives")


# --------------------------------------------------- minimise / restore --

func test_minimising_folds_the_window_into_the_phase_bars_window_icon() -> void:
	# "you can minimize the Combat window by clicking in its upper right
	# corner. To restore the minimized window, click on the window icon in
	# the center area of the Phase Bar." (manual p.126)
	var g: MtgGame = screen.game
	var lion := _summon(g, "Savannah Lions", g.active_player)
	g.combat.attackers[lion.id] = true
	screen._refresh()
	screen._on_combat_minimized(true)
	assert_false(screen._combat_window.visible, "the window is away")
	if screen._window_icon != null:
		assert_true(screen._window_icon.visible,
			"the dagger appears in the strip's centre band")
	assert_true(_field_ids(g.active_player).has(lion.id),
		"[QoL] a minimised lineup drops back onto the board rather than "
		+ "vanishing inside the icon")
	screen._on_window_icon_pressed()
	assert_true(screen._combat_window.visible, "Restore brings it back")
	if screen._window_icon != null:
		assert_false(screen._window_icon.visible)


func test_a_new_attack_always_opens_its_own_window() -> void:
	var g: MtgGame = screen.game
	var lion := _summon(g, "Savannah Lions", g.active_player)
	g.combat.attackers[lion.id] = true
	screen._refresh()
	screen._on_combat_minimized(true)
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.MAIN2)
	g.combat.clear()
	screen._refresh()
	assert_false(screen._combat_minimized,
		"leaving combat forgets the minimised state")
	assert_false(screen._combat_window.minimized,
		"and so does the window itself — a flag left stuck true would make "
		+ "the next attack's minimise button a no-op")
	# The next attack really does open, and really can be minimised again.
	g._step_index = Mtg.STEP_ORDER.find(Mtg.Step.DECLARE_ATTACKERS)
	g.combat.attackers[lion.id] = true
	screen._refresh()
	assert_true(screen._combat_window.visible)
	screen._combat_window._on_minimize_pressed()
	assert_true(screen._combat_minimized, "the gadget still fires")


# ------------------------------------------------------------ the art --

func test_the_window_is_the_grounds_own_888x316() -> void:
	# Winbk_Attack.pic is 888x316, and 316 is exactly a title bar over two
	# lanes of 140 — the box a TAPPED mini-card turns inside.
	assert_eq(CombatWindow.ART_SIZE, Vector2(888.0, 316.0))
	assert_eq(CombatWindow.LANE_H, MiniCard.SIZE.x + 8.0)
	assert_eq(CombatWindow.HEIGHT, CombatWindow.ART_SIZE.y,
		"the layout adds up to the ground's own height")


func test_the_lane_markers_decode_from_the_1997_image_mask_pairs() -> void:
	if GameSkin.texture("attack_sword") == null:
		pass_test("no original skin imported")
		return
	var sword := MiniCard.masked_sprite("attack_sword")
	var shield := MiniCard.masked_sprite("attack_shield")
	assert_not_null(sword)
	assert_eq(sword.get_width(), 28, "56x132 halves into a 28-wide sword")
	assert_eq(shield.get_width(), 22, "44x128 halves into a 22-wide shield")
	# The mask's own corner is background, so the corner must come out
	# CLEAR — the polarity these files use is the opposite of Damage.pic's.
	assert_almost_eq(sword.get_image().get_pixel(0, 0).a, 0.0, 0.01,
		"the sword's corner is transparent, not a white box")


func test_the_bone_strip_splits_top_image_over_bottom_mask() -> void:
	if GameSkin.texture("attack_bones") == null:
		pass_test("no original skin imported")
		return
	var bones := MiniCard.masked_sprite("attack_bones", true)
	assert_not_null(bones)
	assert_eq(bones.get_width(), 777, "the strip keeps its full width")
	assert_eq(bones.get_height(), 35, "777x70 splits into image over mask")


func test_the_window_sits_above_the_board_but_under_the_arrows() -> void:
	# A mini-card's name label carries z_index 2, so a window at 0 would be
	# painted through; and since 2026-09-07 the board's rows and its free
	# layer stand on a ladder (`ROW_Z_STEP`), so the window must start
	# above the free layer's tallest card, not merely above zero. The
	# arrows in turn run between the window's lanes.
	assert_eq(screen._combat_window.z_index, 30)
	assert_gt(screen._combat_window.z_index,
		DuelScreen.FREE_LAYER_Z + DuelScreen.ROW_Z_STEP,
		"the window clears the free layer and a pile's name band on it")
	assert_gt(screen._arrows.z_index, screen._combat_window.z_index + 2,
		"arrows draw over the window AND over its cards' name bands")


# ----------------------------------------------------------- helpers --

func _summon(g: MtgGame, card_name: String, pid: int) -> CardInstance:
	var data := CardRegistry.get_card(card_name)
	var inst := CardInstance.new(data, g._next_instance_id, pid)
	g._next_instance_id += 1
	g._instances[inst.id] = inst
	g._put_on_battlefield(inst, pid)
	return inst


## Instance ids rendered in one seat's own territory rows.
func _field_ids(pid: int) -> Array:
	var out: Array = []
	for row in screen._field_rows[pid]:
		_collect(screen._field_rows[pid][row], out)
	return out


func _collect(node: Node, out: Array) -> void:
	if node.is_queued_for_deletion():
		return
	if node is MiniCard and (node as MiniCard).instance != null:
		out.append((node as MiniCard).instance.id)
	for child in node.get_children():
		_collect(child, out)


func _widget_count(instance_id: int) -> int:
	var all: Array = []
	_collect(screen, all)
	return all.count(instance_id)
