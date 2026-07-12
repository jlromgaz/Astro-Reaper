extends Node2D
## Procedural chest visual — golden crate with a pulsing glow and a
## blinking keyhole so it reads as loot, not a threat.

const BODY_W := 18.0
const BODY_H := 13.0

var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	var pulse := 0.5 + 0.5 * sin(_time * 4.0)
	# Luminescent glow so it pops against the dark backdrop
	draw_circle(Vector2.ZERO, 22.0 + 4.0 * pulse, Color(Palette.CHEST, 0.10 + 0.10 * pulse))
	# Crate body
	var half_w := BODY_W * 0.5
	var half_h := BODY_H * 0.5
	draw_rect(Rect2(-half_w, -half_h, BODY_W, BODY_H), Color(Palette.CHEST, 0.9))
	# Lid seam and vertical strap
	draw_line(Vector2(-half_w, -half_h * 0.25), Vector2(half_w, -half_h * 0.25),
		Color(Palette.CHEST.darkened(0.5), 1.0), 1.5)
	draw_line(Vector2(0, -half_h), Vector2(0, half_h),
		Color(Palette.CHEST.darkened(0.5), 1.0), 1.5)
	# Blinking keyhole
	draw_circle(Vector2(0, half_h * 0.25), 2.0, Color(Palette.HIT_FLASH, 0.4 + 0.6 * pulse))
	# Rim
	draw_rect(Rect2(-half_w, -half_h, BODY_W, BODY_H),
		Color(Palette.CHEST.lightened(0.4), 0.9), false, 1.5)
