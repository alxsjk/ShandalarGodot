class_name HotseatHand
extends StackHand
## A pass-and-play hand. The inactive seat has only a count; the
## deciding seat has anonymous card backs until Show hand is pressed.
## Hidden widgets never receive a CardInstance, hover callback or tooltip.

signal visibility_toggled

const GAP := 8.0
const BUTTON_WIDTH := 104.0
var seat := 0
var active := false
var revealed := false
var toggle_button: Button
var _backs: Control
var _count := 0
var _positioned := false


func _init() -> void:
	super()
	pinned = true
	# Reserve space for the button without stretching the original frame.
	for part in [_frame, _fallback, _title_bg]:
		part.anchor_right = 0.0
		part.offset_right = WIDTH
	_pile.anchor_right = 0.0
	_pile.offset_right = WIDTH - BORDER
	_backs = Control.new()
	_backs.position = Vector2(BORDER, TITLE_HEIGHT)
	_backs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_backs)
	toggle_button = UiChrome.menu_button("Show hand", Vector2(BUTTON_WIDTH, 32), 14)
	toggle_button.focus_mode = Control.FOCUS_NONE  # Enter/Space remain duel commands.
	toggle_button.position = Vector2(WIDTH + GAP, BAR_TOP)
	toggle_button.pressed.connect(func(): visibility_toggled.emit())
	add_child(toggle_button)


func present(hand: Array, deciding: bool, shown: bool, showcase: CardPreview,
		click_cb: Callable, highlight_cb: Callable) -> void:
	_count = hand.size()
	active = deciding
	revealed = deciding and shown
	preview = showcase if revealed else null
	populate(hand if revealed else [], false, click_cb, highlight_cb)


func _ready() -> void:
	get_viewport().size_changed.connect(_clamp_on_screen)


func populate(hand: Array, hidden: bool, click_cb: Callable,
		highlight_cb: Callable) -> void:
	super.populate(hand, hidden, click_cb, highlight_cb)
	_pile.visible = active and revealed
	for child in _backs.get_children():
		_backs.remove_child(child)
		child.queue_free()
	_backs.visible = active and not revealed
	if _backs.visible:
		var art := GameSkin.texture("card_back")
		var box: StyleBox
		if art != null:
			box = StyleBoxTexture.new()
			box.texture = art
		else:
			box = StyleBoxFlat.new()
			box.bg_color = Color(0.18, 0.11, 0.06)
			box.border_color = Color(0.07, 0.05, 0.03)
			box.set_border_width_all(4)
			box.set_corner_radius_all(5)
		for i in _count:
			var back := Panel.new()
			back.size = MiniCard.SIZE
			back.add_theme_stylebox_override("panel", box)
			back.mouse_filter = Control.MOUSE_FILTER_IGNORE
			back.focus_mode = Control.FOCUS_NONE
			back.position.y = i * CardPile.OVERLAP
			_backs.add_child(back)
		_backs.size = Vector2(CardPile.WIDTH, _pile.pile_height(_count))
		_backs.clip_contents = is_collapsed()
	_title.text = "Player %d (%d)" % [seat + 1, _count]
	_title_bg.tooltip_text = "%s — %d cards in hand" % [DuelConfig.seat_label(seat), _count]
	if not pinned:
		_title_bg.tooltip_text += "\nDrag the title bar to move this stack and its button."
	_title_bg.mouse_default_cursor_shape = Control.CURSOR_ARROW if pinned else Control.CURSOR_MOVE
	toggle_button.visible = active
	toggle_button.text = "Hide hand" if revealed else "Show hand"
	toggle_button.tooltip_text = "Hide these cards before passing control." if revealed \
		else "Reveal only when the other player has looked away."
	var height := TITLE_HEIGHT + FOOT + (_pile.pile_height(_count) if active else 0.0)
	custom_minimum_size = Vector2(WIDTH + GAP + BUTTON_WIDTH, height)
	size = custom_minimum_size
	_clamp_on_screen()


func _remember_position() -> void:
	# Each floating seat keeps its own position for this duel. Neither
	# overwrites the single-player hand preference or the other seat.
	_positioned = true


func _clamp_on_screen() -> void:
	if pinned or get_parent() == null:
		return
	var view := get_viewport_rect().size
	var width := WIDTH + GAP + BUTTON_WIDTH
	if not _positioned:
		var opening_height := TITLE_HEIGHT + FOOT + _pile.pile_height(7)
		position = Vector2(view.x - width - 8.0,
			view.y * (0.5 if seat == 1 else 1.0) - opening_height - 8.0)
		_positioned = true
	position.x = clampf(position.x, 0.0, maxf(0.0, view.x - width))
	position.y = clampf(position.y, 0.0, maxf(0.0, view.y - TITLE_HEIGHT - FOOT))
