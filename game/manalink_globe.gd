class_name ManalinkGlobe
extends Control
## [QoL] The Manalink mark: the owner's own picture, 2026-09-17 — a green
## wire globe and a starred violet sky sharing one disc, at
## `game/art/manalink_globe.png` (inventoried with its hash in
## `game/art/README.md`). It ships inside the pack like the rest of that
## folder, so a player who has imported nothing still gets it.
##
## The 2026-09-13 drawing — a green sphere with dark meridians and latitude
## lines, geometry only — stays underneath as the fallback for a build
## whose picture failed to load, so the button is never blank.

const PICTURE := "manalink_globe"
const GREEN := Color8(139, 187, 98)
const INK := Color8(29, 35, 27)
const STEPS := 96

## The picture with mipmaps of its own, built once. It is a 256 px file
## drawn at 52–56 px: a plain linear sample of that is a shimmer of
## meridians, and the import pipeline's `mipmaps/generate` lives in an
## ignored `.import` file, which is no place to keep a promise.
static var _picture: Texture2D = null
static var _looked := false


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


static func picture() -> Texture2D:
	if _looked:
		return _picture
	_looked = true
	var shipped := GameSkin.our_art(PICTURE)
	if shipped == null:
		return null
	var image := shipped.get_image()
	if image == null:
		_picture = shipped
		return _picture
	if image.is_compressed():
		image.decompress()
	image.generate_mipmaps()
	_picture = ImageTexture.create_from_image(image)
	return _picture


func _draw() -> void:
	var side := minf(size.x, size.y)
	if side <= 0.0:
		return
	var shipped := picture()
	if shipped != null:
		draw_texture_rect(shipped, Rect2((size - Vector2(side, side)) / 2.0, Vector2(side, side)), false)
		return
	var centre := size / 2.0
	var radius := side * 0.46
	var stroke := maxf(1.0, radius * 0.10)
	draw_circle(centre, radius, GREEN, true, -1.0, true)
	# Two ellipses give four meridians, all meeting at the poles.
	for width in [0.34, 0.73]:
		var points := PackedVector2Array()
		for i in STEPS + 1:
			var angle := TAU * float(i) / STEPS
			points.append(centre + radius * Vector2(width * sin(angle), cos(angle)))
		draw_polyline(points, INK, stroke, true)
	# The upper/lower parallels bow towards the equator. Their ends land
	# exactly on the sphere at (+/-sqrt(3)/2, +/-1/2).
	for sign_y in [-1.0, 1.0]:
		var points := PackedVector2Array()
		for i in STEPS + 1:
			var x := -1.0 + 2.0 * float(i) / STEPS
			points.append(centre + radius * Vector2(sqrt(3.0) * 0.5 * x,
				sign_y * (0.35 + 0.15 * x * x)))
		draw_polyline(points, INK, stroke, true)
	draw_line(centre - Vector2(radius, 0), centre + Vector2(radius, 0), INK, stroke, true)
	draw_arc(centre, radius, 0.0, TAU, STEPS, INK, stroke * 1.15, true)
