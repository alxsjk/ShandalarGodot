class_name DraftBuilder
extends DeckBuilderScreen
## [QoL] The ordinary builder with one pool, one slot and no outside-card doors.

signal finish_requested

const ALLOWED: Array[String] = ["Consolidate duplicate cards", "Clear deck", "Restore deck",
	"Sort deck", "Stats", "Music", "Sound Effects", "Move by color out of deck", "Filters",
	"Undo", "Big cards", "Add basic land", "Deck notes", "Sideboard", "Save deck", "Exit deck builder"]
var draft_counts: Dictionary = {}
var input_guard := Callable()


func _ready() -> void:
	# This screen is constructed in code, not from the ordinary builder's
	# full-rect .tscn. Set offsets too or the editing surface remains 0×0.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	super._ready()
	var pool := SealedPool.new()
	pool.counts = draft_counts.duplicate()
	_enter_sealed(pool, true)
	deck.deck_name = "Booster Draft"
	for button in _slot_buttons:
		button.hide()
	_command_row.get_node("LoadButton").hide()
	_dice_button.disabled = true
	_dice_button.tooltip_text = "Your dealt pool is locked for this session."
	_pool_button.disabled = true
	_pool_button.tooltip_text = _dice_button.tooltip_text
	refresh()


func _deck_rect() -> Rect2:
	var area := super._deck_rect()
	area.position.y += 60.0
	area.size.y = maxf(0, area.size.y - 60.0)
	return area


func _command_labels() -> Array[String]:
	return ALLOWED.duplicate()


func _run_command(label: String) -> void:
	if input_guard.is_valid() and input_guard.call(): return
	if not ALLOWED.has(label):
		_say("This draft uses only your dealt cards and one deck.", true)
		return
	super._run_command(label)


func _input(event: InputEvent) -> void:
	# Godot dispatches child input before the parent's. The Enter handler
	# must check the deadline itself, not wait for DraftSession._input.
	if input_guard.is_valid() and input_guard.call():
		get_viewport().set_input_as_handled()
		return
	super._input(event)


func _sealed_refusal(card_name: String) -> String:
	if input_guard.is_valid() and input_guard.call(): return "The draft is finished."
	return super._sealed_refusal(card_name)


func _switch_slot(_index: int) -> void:
	pass


func _on_dice_pressed() -> void:
	_dice_button.set_pressed_no_signal(true)


func _leave_sealed() -> void:
	pass


func _open_deck_menu() -> void:
	_open_mini_menu()


func _save_deck(_then := Callable()) -> void:
	finish_requested.emit()


func _exit() -> void:
	finish_requested.emit()


func _quit_game() -> void:
	finish_requested.emit()
