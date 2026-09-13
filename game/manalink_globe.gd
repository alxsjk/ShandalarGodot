class_name ManalinkGlobe
extends Control
## [QoL] A green retro-network globe for the future Manalink entry.
## Original geometric drawing inspired by the owner's reference, 2026-09-13:
## a green sphere with dark meridians and latitude lines. No photo pixels
## or third-party artwork are bundled. Native vector drawing stays crisp
## in every export and needs neither a skin pack nor a raster asset.

const GREEN := Color8(139, 187, 98)
const INK := Color8(29, 35, 27)
const STEPS := 96


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	focus_mode = Control.FOCUS_NONE


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()


func _draw() -> void:
	var centre := size / 2.0
	var radius := minf(size.x, size.y) * 0.46
	if radius <= 0.0:
		return
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
