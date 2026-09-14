class_name CardPackBadges
extends HBoxContainer
## Small numbered gameplay-pack buttons beside the title's set badges.

signal pack_clicked(id: String)

# The owner's exact `1-tDotP` mark measures 71 px with the shared stone
# button's content margins. A 72 px square keeps the mark whole and aligns
# with the title's other small square control.
const SIZE := Vector2(72, 72)


func _ready() -> void:
	add_theme_constant_override("separation", 6)
	rebuild()
	CardPacks.changed.connect(_on_pack_changed)


func rebuild() -> void:
	for child in get_children():
		child.free()
	for id in CardPacks.available_ids():
		add_child(_badge(id))


func _badge(id: String) -> Button:
	var button := UiChrome.menu_button("1-tDotP", SIZE, 10, 0.04)
	button.name = "Pack1"
	button.custom_minimum_size = SIZE
	button.size = SIZE
	button.tooltip_text = "Pack 1 — DotP Complete (%s)" % (
		"enabled" if CardPacks.is_enabled(id) else "disabled")
	button.pressed.connect(pack_clicked.emit.bind(id))

	var dot := ColorRect.new()
	dot.name = "Status"
	dot.color = Color("54b86a") if CardPacks.is_enabled(id) else Color("77736b")
	dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dot.custom_minimum_size = Vector2(8, 8)
	dot.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	dot.position = Vector2(-11, 3)
	button.add_child(dot)
	return button


func _on_pack_changed(_id: String, _enabled: bool) -> void:
	rebuild()
