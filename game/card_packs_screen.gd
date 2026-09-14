class_name CardPacksScreen
extends Control
## Options > Card Packs — availability, compatibility, enablement and the
## exact local folder. Pack ZIPs are user-built/user-supplied and are never
## release payloads.

const PANEL_WIDTH := 620.0

var _status: Label
var _enable: Button
var _disable: Button
var _warning: Control


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new()
	bg.color = Color(0.09, 0.08, 0.07)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var title_bg := GameSkin.texture("title_background")
	if title_bg != null:
		var art := TextureRect.new()
		art.texture = title_bg
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		art.set_anchors_preset(Control.PRESET_FULL_RECT)
		art.modulate = Color(0.5, 0.5, 0.5)
		add_child(art)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	content.add_child(UiChrome.body_label("Card Packs", 26))
	var folder := UiChrome.body_label(
		"Folder: %s" % GamePaths.shown(GamePaths.cardpacks_folder()), 13)
	folder.name = "CardPacksFolder"
	folder.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(folder)

	var tools := HBoxContainer.new()
	tools.add_theme_constant_override("separation", 10)
	var open := UiChrome.menu_button("Open Folder", Vector2(140, 32), 13)
	open.name = "OpenFolder"
	open.disabled = OS.has_feature("web")
	open.pressed.connect(CardPacks.open_folder)
	tools.add_child(open)
	var rescan := UiChrome.menu_button("Rescan", Vector2(110, 32), 13)
	rescan.name = "Rescan"
	rescan.pressed.connect(CardPacks.rescan)
	tools.add_child(rescan)
	content.add_child(tools)

	var heading := UiChrome.body_label("1-tDotP — Pack 1: DotP Complete", 18)
	heading.name = "Pack1Heading"
	content.add_child(heading)
	_status = UiChrome.body_label("", 14)
	_status.name = "Pack1Status"
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_status)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	_enable = UiChrome.menu_button("Enable", Vector2(120, 34), 13)
	_enable.name = "EnablePack1"
	_enable.pressed.connect(CardPacks.set_enabled.bind(CardPacks.ID, true))
	actions.add_child(_enable)
	_disable = UiChrome.menu_button("Disable", Vector2(120, 34), 13)
	_disable.name = "DisablePack1"
	_disable.pressed.connect(_request_disable)
	actions.add_child(_disable)
	content.add_child(actions)

	var local_only := UiChrome.body_label(
		"Pack 1 is not distributed with the game. Build it locally with "
		+ "tools/pack_1_dotp_complete.py, place the exact ZIP here, then Rescan.", 13)
	local_only.name = "LocalOnly"
	local_only.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(local_only)

	var back := UiChrome.menu_button("Back", Vector2(180, 40))
	back.name = "Back"
	back.pressed.connect(func() -> void:
		get_tree().change_scene_to_file("res://game/options.tscn"))
	var back_row := HBoxContainer.new()
	back_row.alignment = BoxContainer.ALIGNMENT_CENTER
	back_row.add_child(back)
	content.add_child(back_row)

	var panel := UiChrome.panel_around(content, 20.0)
	panel.custom_minimum_size.x = PANEL_WIDTH
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(panel)

	CardPacks.changed.connect(_on_pack_changed)
	CardPacks.rescanned.connect(_refresh)
	_refresh()


func _refresh() -> void:
	var state := CardPacks.status(CardPacks.ID)
	var available := bool(state.get("available", false))
	var enabled := bool(state.get("enabled", false))
	_enable.disabled = not available or enabled
	_disable.disabled = not available or not enabled
	if available:
		var counts: Dictionary = state.get("counts", {})
		_status.text = "Status: %s\nVersion: %s\nMinimum game version: %s\n" % [
			"Enabled" if enabled else "Disabled",
			String(state.get("version", "unknown")),
			String(state.get("minimum_game_version", "unknown"))]
		_status.text += "%s set entries · %d unique cards\n%s" % [
			_grouped(int(counts.get("named_set_entries", 0))),
			int(counts.get("distinct_cards", 0)),
			GamePaths.shown(String(state.get("path", "")))]
	else:
		_status.text = "Status: Not available\nExpected: %s\n%s\nReason: %s" % [
			CardPacks.FILE_NAME, GamePaths.shown(String(state.get("path", ""))),
			String(state.get("rejection", "not found"))]


func _on_pack_changed(_id: String, _enabled: bool) -> void:
	_refresh()


func _request_disable() -> void:
	var warning := CardPacks.disable_warning(CardPacks.ID)
	if warning == "":
		CardPacks.set_enabled(CardPacks.ID, false)
		return
	if is_instance_valid(_warning):
		return
	_warning = UiChrome.action_popup(self, "Current deck uses Pack 1", warning, [
		{"label": "Keep enabled", "name": "KeepEnabled"},
		{"label": "Disable anyway", "name": "DisableAnyway",
			"callable": CardPacks.set_enabled.bind(CardPacks.ID, false)},
	], 570.0)
	_warning.tree_exited.connect(func() -> void: _warning = null)


static func _grouped(value: int) -> String:
	var digits := str(value)
	var out := ""
	while digits.length() > 3:
		out = "," + digits.right(3) + out
		digits = digits.left(-3)
	return digits + out
