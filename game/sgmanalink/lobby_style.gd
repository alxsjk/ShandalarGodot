class_name SgLobbyStyle
extends RefCounted
## [QoL] SGManalink's restrained stone frame, parchment sections and shared controls.
## Reuses the game's fonts and chrome; no downloaded art or platform-native dialogs.

const PAPER := Color8(216, 203, 174)
const WELL := Color8(234, 223, 198)
const GOLD := Color8(187, 158, 98)
const PALE := Color8(235, 222, 191)
const MUTED := Color8(180, 180, 157)
const DARK := Color8(27, 34, 29)

static func label(text: String, size := 16, dark_surface := false) -> Label:
	var node := UiChrome.body_label(text, size)
	node.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	node.add_theme_color_override("font_color", PALE if dark_surface else UiChrome.INK)
	node.add_theme_color_override("font_shadow_color", Color(0,0,0,0))
	node.add_theme_constant_override("shadow_outline_size", 0)
	if size >= 24:
		var font := GameSkin.font("font_title")
		if font != null: node.add_theme_font_override("font", font)
	return node

static func panel(inner: Control, light := true, margin := 18.0) -> PanelContainer:
	var box := StyleBoxFlat.new()
	box.bg_color = PAPER if light else DARK
	box.border_color = GOLD.darkened(0.25)
	box.set_border_width_all(1)
	box.set_content_margin_all(margin)
	var node := PanelContainer.new()
	node.add_theme_stylebox_override("panel", box)
	node.add_child(inner)
	return node

static func column(parent: Node, title := "", light := true) -> VBoxContainer:
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	parent.add_child(panel(body, light))
	if not title.is_empty(): body.add_child(label(title, 22, not light))
	return body

static func row(parent: Node) -> HBoxContainer:
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", 12)
	parent.add_child(line)
	return line

static func button(text: String, callback: Callable, primary := false, minimum := Vector2(150, 40)) -> Button:
	var node := UiChrome.menu_button(text, minimum, 18) if primary else OriginalDialog.button(text)
	node.custom_minimum_size = minimum
	node.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	node.add_theme_color_override("font_focus_color", UiChrome.INK)
	node.pressed.connect(callback)
	return node

static func option(node: OptionButton) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = WELL
	box.border_color = GOLD.darkened(0.4)
	box.set_border_width_all(1)
	box.set_content_margin_all(9)
	for state in ["normal", "hover", "pressed", "disabled"]:
		node.add_theme_stylebox_override(state, box)
	node.add_theme_stylebox_override("focus", OriginalDialog.focus_ring())
	for state in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		node.add_theme_color_override(state, UiChrome.INK)
	node.add_theme_color_override("font_shadow_color", Color(0,0,0,0))
	node.add_theme_font_size_override("font_size", 17)
	var font := GameSkin.font("font_body")
	if font != null: node.add_theme_font_override("font", font)

static func field(edit: LineEdit) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = WELL
	box.border_color = GOLD.darkened(0.4)
	box.set_border_width_all(1)
	box.content_margin_left = 10
	box.content_margin_right = 10
	box.content_margin_top = 7
	box.content_margin_bottom = 7
	edit.add_theme_stylebox_override("normal", box)
	edit.add_theme_stylebox_override("read_only", box)
	var focus := box.duplicate() as StyleBoxFlat
	focus.border_color = UiChrome.ACCENT
	focus.set_border_width_all(2)
	edit.add_theme_stylebox_override("focus", focus)
	edit.add_theme_color_override("font_color", UiChrome.INK)
	edit.add_theme_color_override("font_uneditable_color", Color8(90,80,65))
	edit.add_theme_color_override("font_placeholder_color", Color8(106,97,79))
	edit.add_theme_color_override("caret_color", UiChrome.INK)
	edit.add_theme_color_override("selection_color", Color8(94,83,55))
	edit.add_theme_color_override("font_selected_color", Color.WHITE)
	edit.add_theme_font_size_override("font_size", 17)
	var font := GameSkin.font("font_body")
	if font != null: edit.add_theme_font_override("font", font)
	edit.custom_minimum_size.y = 40
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL

static func deck_list(list: ItemList) -> void:
	var box := StyleBoxFlat.new()
	box.bg_color = WELL
	box.set_content_margin_all(8)
	list.add_theme_stylebox_override("panel", box)
	var selected := StyleBoxFlat.new()
	selected.bg_color = Color8(77,85,57)
	selected.set_content_margin_all(6)
	list.add_theme_stylebox_override("selected", selected)
	list.add_theme_stylebox_override("selected_focus", selected)
	list.add_theme_color_override("font_color", UiChrome.INK)
	list.add_theme_color_override("font_selected_color", PALE)
	list.add_theme_font_size_override("font_size", 16)
	list.add_theme_constant_override("v_separation", 10)
	var font := GameSkin.font("font_body")
	if font != null: list.add_theme_font_override("font", font)

static func rich_text(node: RichTextLabel) -> void:
	node.add_theme_color_override("default_color", UiChrome.INK)
	node.add_theme_font_size_override("normal_font_size", 17)
	node.add_theme_constant_override("line_separation", 3)
	var font := GameSkin.font("font_body")
	if font != null: node.add_theme_font_override("normal_font", font)
