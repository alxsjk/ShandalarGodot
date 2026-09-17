class_name SgTournamentBracket
extends VBoxContainer
## [QoL] Scrollable, zoomable advancement diagram of actual random round draws.
## Its canvas connects published winners only. No hidden cards or future pairing.

const CARD_SIZE := Vector2(240, 104)
const COLUMN_GAP := 68.0
const ROW_GAP := 20.0
var _canvas: BracketCanvas
var _scroll: ScrollContainer
var _players: OptionButton
var _zoom_label: Label
var _fit_picker: OptionButton
var _fit := 1 # 0 = manual, 1 = width, 2 = whole draw.


class BracketCanvas extends Control:
	signal player_selected(pid: int)
	var view: Dictionary = {}
	var graph: Dictionary = {}
	var boxes: Dictionary = {}
	var extent := Vector2.ONE
	var zoom := 1.0
	var selected := 0
	var face: Font

	func configure(value: Dictionary) -> void:
		boxes.clear()
		view = value.duplicate(true)
		graph = SgTournamentResults.advancement(view)
		face = GameSkin.font("font_body")
		if face == null: face = get_theme_default_font()
		var indexed := {}
		var connected := {}
		for node: Dictionary in graph.nodes: indexed[node.id] = node
		for link: Dictionary in graph.links: connected[link.from] = true
		var roots: Array = []
		for node: Dictionary in graph.nodes:
			if not connected.has(node.id): roots.append(node)
		roots.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
			return a.round > b.round if a.round != b.round else a.id < b.id)
		var cursor: Array = [64.0]
		for node: Dictionary in roots: _place(node, indexed, cursor)
		extent = Vector2(maxi(1, graph.rounds) * (CARD_SIZE.x + COLUMN_GAP) - COLUMN_GAP + 28, maxf(160, cursor[0] - ROW_GAP + 16))
		set_zoom(zoom)

	func _place(node: Dictionary, indexed: Dictionary, cursor: Array) -> float:
		var y := 0.0
		if node.parents.is_empty():
			y = cursor[0]
			cursor[0] += CARD_SIZE.y + ROW_GAP
		else:
			var positions: Array = []
			for pid in node.parents: positions.append(_place(indexed[pid], indexed, cursor))
			y = (float(positions.front()) + float(positions.back())) / 2.0
		boxes[node.id] = Rect2(Vector2(14 + (node.round - 1) * (CARD_SIZE.x + COLUMN_GAP), y), CARD_SIZE)
		return y

	func set_zoom(value: float) -> void:
		zoom = clampf(value, 0.15, 1.5)
		custom_minimum_size = extent * zoom
		queue_redraw()

	func _name(pid: int) -> String:
		for player: Dictionary in view.entrants:
			if int(player.id) == pid: return player.name
		return "Bye"

	func _text(value: String, position: Vector2, size_value: int, color: Color, width := 210.0) -> void:
		draw_string(face, position, _elide(value, size_value, width), HORIZONTAL_ALIGNMENT_LEFT, width, size_value, color)

	func _elide(value: String, size_value: int, width: float) -> String:
		if face.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size_value).x <= width: return value
		var result := value
		while not result.is_empty():
			result = result.left(result.length() - 1)
			if face.get_string_size(result + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, size_value).x <= width: return result + "…"
		return ""

	func _draw() -> void:
		if face == null: return
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE * zoom)
		for r in graph.rounds:
			_text("ROUND %d" % (r + 1), Vector2(14 + r * (CARD_SIZE.x + COLUMN_GAP), 28), 18, SgLobbyStyle.PALE)
		for link: Dictionary in graph.links:
			var source: Rect2 = boxes[link.from]
			var target: Rect2 = boxes[link.to]
			var start := source.position + Vector2(CARD_SIZE.x, CARD_SIZE.y / 2)
			var end := target.position + Vector2(0, 41 + int(link.seat) * 24)
			var middle := (start.x + end.x) / 2
			var lit: bool = selected == 0 or selected == link.player
			var color := SgLobbyStyle.GOLD if lit else SgLobbyStyle.MUTED.darkened(0.65)
			draw_polyline(PackedVector2Array([start, Vector2(middle, start.y), Vector2(middle, end.y), end]), color, 3 if selected == link.player else 1.5, true)
			draw_colored_polygon(PackedVector2Array([end, end + Vector2(-7, -4), end + Vector2(-7, 4)]), color)
		for node: Dictionary in graph.nodes:
			var rect: Rect2 = boxes[node.id]
			var pair: Dictionary = node.pair
			var lit: bool = selected == 0 or int(pair.players[0]) == selected or int(pair.players[1]) == selected
			draw_rect(rect, SgLobbyStyle.PAPER if lit else SgLobbyStyle.PAPER.darkened(0.35))
			draw_rect(rect, SgLobbyStyle.GOLD if lit else SgLobbyStyle.DARK, false, 2)
			var ink := UiChrome.INK
			_text("DRAW %d" % SgTournament.table_number(node.id), rect.position + Vector2(10, 17), 12, ink)
			for seat in 2:
				var pid := int(pair.players[seat])
				var at := rect.position + Vector2(10, 43 + seat * 24)
				var winner: bool = int(pair.winner) == pid and pid != 0
				var color := Color8(39, 92, 47) if winner else ink
				_text(_name(pid), at, 17, color, CARD_SIZE.x - 48)
				if pid != 0: _text(str(int(pair.wins[seat])), at + Vector2(CARD_SIZE.x - 37, 0), 19, color, 24)
			var caption := "Awaiting ready" if pair.status == "waiting" else "Playing game %d" % int(pair.game)
			if pair.status == "bye": caption = "Bye · no game played"
			elif pair.status == "finished": caption = pair.reason
			elif view.phase == "cancelled": caption = "Cancelled"
			_text(caption, rect.position + Vector2(10, 91), 13, ink)

	func _get_tooltip(at: Vector2) -> String:
		for node: Dictionary in graph.nodes:
			if boxes[node.id].has_point(at / zoom):
				var pair: Dictionary = node.pair
				return "Round %d · Draw %d\n%s  %d : %d  %s\n%d drawn game(s). Click a player to follow their path." % [node.round,
					SgTournament.table_number(node.id), _name(int(pair.players[0])), int(pair.wins[0]), int(pair.wins[1]), _name(int(pair.players[1])), int(pair.draws)]
		return ""

	func _gui_input(event: InputEvent) -> void:
		if not event is InputEventMouseButton or not event.pressed or event.button_index != MOUSE_BUTTON_LEFT: return
		for node: Dictionary in graph.nodes:
			var rect: Rect2 = boxes[node.id]
			if not rect.has_point(event.position / zoom): continue
			var seat := 0 if event.position.y / zoom - rect.position.y < 51 else 1
			var pid := int(node.pair.players[seat])
			if pid != 0:
				player_selected.emit(pid)
				accept_event()
			return


func present(view: Dictionary, saved: Dictionary = {}) -> void:
	var toolbar := SgLobbyStyle.row(self)
	var minus := SgLobbyStyle.button("−", func() -> void: _zoom_by(-0.1), Vector2(38, 34))
	minus.tooltip_text = "Zoom out"
	toolbar.add_child(minus)
	_zoom_label = SgLobbyStyle.label("100%", 16, true)
	_zoom_label.custom_minimum_size.x = 42
	_zoom_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	toolbar.add_child(_zoom_label)
	var plus := SgLobbyStyle.button("+", func() -> void: _zoom_by(0.1), Vector2(38, 34))
	plus.tooltip_text = "Zoom in"
	toolbar.add_child(plus)
	_fit_picker = OptionButton.new()
	_fit_picker.name = "AdvancementFit"
	for caption in ["Manual zoom", "Fit width", "Whole draw"]: _fit_picker.add_item(caption)
	SgLobbyStyle.option(_fit_picker)
	toolbar.add_child(_fit_picker)
	_fit_picker.item_selected.connect(func(index: int) -> void:
		_fit = index
		_fit_view())
	_players = OptionButton.new()
	_players.name = "AdvancementPlayer"
	_players.add_item("All players", 0)
	for player: Dictionary in view.entrants: _players.add_item(player.name, int(player.id))
	_players.fit_to_longest_item = false
	_players.custom_minimum_size.x = 170
	_players.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	SgLobbyStyle.option(_players)
	toolbar.add_child(_players)
	_players.item_selected.connect(func(index: int) -> void: follow(_players.get_item_id(index)))
	_scroll = ScrollContainer.new()
	_scroll.name = "AdvancementScroll"
	_scroll.custom_minimum_size.y = 360
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_scroll)
	_canvas = BracketCanvas.new()
	_canvas.name = "AdvancementCanvas"
	_scroll.add_child(_canvas)
	_canvas.configure(view)
	_canvas.player_selected.connect(follow)
	_fit = int(saved.get("fit", 1))
	_fit_picker.select(_fit)
	_canvas.selected = int(saved.get("player", 0))
	_players.select(maxi(0, _players.get_item_index(_canvas.selected)))
	_canvas.set_zoom(float(saved.get("zoom", 1.0)))
	_scroll.resized.connect(func() -> void:
		if _fit != 0: _fit_view())
	_restore.call_deferred(saved)


func _restore(saved: Dictionary) -> void:
	if _fit != 0: _fit_view()
	_update_zoom_label()
	_scroll.scroll_horizontal = int(saved.get("x", 0))
	_scroll.scroll_vertical = int(saved.get("y", 0))
	if saved.get("follow", false): follow(_canvas.selected)


func _fit_view() -> void:
	if _fit == 0 or _scroll.size.x <= 0: return
	var scale := (_scroll.size.x - 20) / _canvas.extent.x
	if _fit == 2: scale = minf(scale, (_scroll.size.y - 20) / _canvas.extent.y)
	_canvas.set_zoom(scale)
	if _fit == 2:
		_scroll.scroll_horizontal = 0
		_scroll.scroll_vertical = 0
	_update_zoom_label()


func _zoom_by(amount: float) -> void:
	_fit = 0
	_fit_picker.select(0)
	_canvas.set_zoom(_canvas.zoom + amount)
	_update_zoom_label()


func _update_zoom_label() -> void:
	_zoom_label.text = "%d%%" % roundi(_canvas.zoom * 100)


func follow(pid: int) -> void:
	_canvas.selected = pid
	_players.select(maxi(0, _players.get_item_index(pid)))
	_canvas.queue_redraw()
	var target := Rect2()
	for node: Dictionary in _canvas.graph.nodes:
		if int(node.pair.players[0]) == pid or int(node.pair.players[1]) == pid: target = _canvas.boxes[node.id]
	if target.size == Vector2.ZERO: return
	_scroll.scroll_horizontal = maxi(0, roundi(target.get_center().x * _canvas.zoom - _scroll.size.x / 2))
	_scroll.scroll_vertical = maxi(0, roundi(target.get_center().y * _canvas.zoom - _scroll.size.y / 2))


func capture_state() -> Dictionary:
	return {"fit": _fit, "zoom": _canvas.zoom, "player": _canvas.selected,
		"x": _scroll.scroll_horizontal, "y": _scroll.scroll_vertical}
