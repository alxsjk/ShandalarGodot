extends GutTest
## TWO MORE WINDOWS THAT STACKED, the siblings of the Verify overlay the
## 2026-09-17 hunt fixed (`tests/ui/test_draft_setup_one_verifier_2026_09_17.gd`).
##
## Both are the same shape: a panel with no blocker over the button that
## opened it, so the mouse is stopped and the KEYBOARD is not — the button
## keeps focus and the next Enter builds a second window on the first.
##
##  * Booster Draft's `Card pool…`, where the two choosers then saved the
##    eligible-card list over each other.
##  * A match's `Side&board...`, which is worse: only the newest window is
##    remembered, so `Done` closed that one and left the older sitting over
##    `Continue match` with nothing on screen able to close it.

var saved: Dictionary = {}


func before_each() -> void:
	CardRegistry.ensure_loaded()
	for key in [DraftPoolConfig.SETTING, DraftPoolConfig.OPTIONS, GamePaths.KEY_DRAFTS]:
		saved[key] = Settings.get_value(key, 0) if Settings.has_value(key) else null
		Settings.clear_value(key)


func after_each() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	for key in saved:
		if saved[key] == null: Settings.clear_value(key)
		else: Settings.set_value(key, saved[key], false)


# ------------------------------------------ Booster Draft: `Card pool…` --

func _choosers(setup: DraftSetup) -> Array:
	var out: Array = []
	for child in setup.get_children():
		if child is DraftPoolDialog and not child.is_queued_for_deletion(): out.append(child)
	return out


func test_pressing_card_pool_twice_opens_one_chooser() -> void:
	var setup := DraftSetup.new()
	add_child_autofree(setup)
	var button: Button = setup.find_child("DraftCardPool", true, false)
	assert_not_null(button)
	button.pressed.emit()
	button.pressed.emit()
	assert_eq(_choosers(setup).size(), 1, "one chooser, however often the button fires")


func test_card_pool_reopens_after_the_chooser_was_dismissed() -> void:
	var setup := DraftSetup.new()
	add_child_autofree(setup)
	var button: Button = setup.find_child("DraftCardPool", true, false)
	button.pressed.emit()
	var first: DraftPoolDialog = _choosers(setup)[0]
	first.dismiss()
	await get_tree().process_frame
	button.pressed.emit()
	var open := _choosers(setup)
	assert_eq(open.size(), 1, "a fresh chooser after the first closed")
	assert_ne(open[0], first)


func test_the_chooser_takes_keyboard_focus_from_the_setup() -> void:
	var setup := DraftSetup.new()
	add_child_autofree(setup)
	var button: Button = setup.find_child("DraftCardPool", true, false)
	button.grab_focus()
	button.pressed.emit()
	var owner: Control = get_viewport().gui_get_focus_owner()
	assert_not_null(owner, "the chooser took the keyboard")
	if owner != null:
		assert_true(_choosers(setup)[0].is_ancestor_of(owner),
			"Enter now lands inside the chooser, not on the button beneath")


# ----------------------------------------------- a match: `Sideboard...` --

func _match_config() -> DuelConfig:
	var config := DuelConfig.hotseat_default()
	config.best_of = 3
	config.sideboard_between_duels = true
	config.rng_seed = 31337
	# A shipped deck with real `SB:` lines, so the window has piles to show.
	var deck := DeckList.load_file("res://decks/white_knights.deck", true)
	config.decks[0] = deck.cards.duplicate()
	config.sideboards[0] = deck.sideboard.duplicate()
	return config


func _windows(runner: MatchScreen) -> Array:
	var out: Array = []
	for child in runner.get_children():
		if child is OriginalDialog and not child.is_queued_for_deletion(): out.append(child)
	return out


func _match() -> MatchScreen:
	var runner: MatchScreen = load("res://game/match_screen.tscn").instantiate()
	runner.config = _match_config()
	add_child_autofree(runner)
	return runner


func test_pressing_sideboard_twice_opens_one_window() -> void:
	var runner := _match()
	await get_tree().process_frame
	runner._open_sideboard(0)
	runner._open_sideboard(0)
	assert_eq(_windows(runner).size(), 1, "one sideboard window, however often the button fires")


func test_done_leaves_no_sideboard_window_behind() -> void:
	var runner := _match()
	await get_tree().process_frame
	runner._open_sideboard(0)
	runner._open_sideboard(0)
	runner._close_sideboard()
	await get_tree().process_frame
	assert_eq(_windows(runner).size(), 0,
		"Done closes the window it opened — nothing is left over Continue match")


func test_the_sideboard_window_takes_the_keyboard() -> void:
	var runner := _match()
	await get_tree().process_frame
	runner._open_sideboard(0)
	var owner: Control = get_viewport().gui_get_focus_owner()
	assert_not_null(owner, "the window took the keyboard")
	if owner != null:
		assert_true(runner._sb_dialog.is_ancestor_of(owner),
			"Enter answers this window rather than the button that opened it")
	runner._close_sideboard()


func test_the_sideboard_window_reopens_once_it_is_closed() -> void:
	var runner := _match()
	await get_tree().process_frame
	runner._open_sideboard(0)
	var first: OriginalDialog = runner._sb_dialog
	runner._close_sideboard()
	await get_tree().process_frame
	runner._open_sideboard(0)
	assert_eq(_windows(runner).size(), 1)
	assert_ne(runner._sb_dialog, first, "a fresh window, not the old one")
	runner._close_sideboard()
