extends Node2D
## Procedural demon rune visual — pulsing red glow, inverted triangle with
## a rim and a blinking eye. Reads as DANGER (boss red family), clearly
## distinct from the golden loot chest.

const RUNE_RADIUS := 11.0
const ROTATION_SPEED := 0.5

var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	rotation = _time * ROTATION_SPEED
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 5.0)
	# Menacing glow so it pops against the dark backdrop
	draw_circle(Vector2.ZERO, 20.0 + 5.0 * pulse, Color(Palette.BOSS, 0.10 + 0.12 * pulse))
	# Inverted triangle rune
	var points := PackedVector2Array([
		Vector2(0, RUNE_RADIUS * 1.2),
		Vector2(-RUNE_RADIUS, -RUNE_RADIUS * 0.8),
		Vector2(RUNE_RADIUS, -RUNE_RADIUS * 0.8),
	])
	draw_colored_polygon(points, Color(Palette.BOSS, 0.85))
	# Rim
	var rim := points.duplicate()
	rim.append(points[0])
	draw_polyline(rim, Color(Palette.BOSS.lightened(0.4), 0.9), 1.5)
	# Blinking inner eye
	var blink := 0.2 + 0.8 * maxf(0.0, sin(_time * 3.0))
	draw_circle(Vector2(0, -RUNE_RADIUS * 0.2), 2.5, Color(Palette.HIT_FLASH, blink))
