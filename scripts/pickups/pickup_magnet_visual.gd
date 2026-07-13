extends Node2D
## Magnet visual — violet horseshoe icon with collapsing rings.
## Distinct color from XP gems so the rare drop reads at a glance.

const RING_COUNT := 3
const MAX_RING := 18.0

var _time := 0.0


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	# Rings shrink toward the core in a loop (pull-inward motion cue)
	for i in range(RING_COUNT):
		var t := fmod(_time * 0.8 + float(i) / float(RING_COUNT), 1.0)
		var radius := MAX_RING * (1.0 - t)
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, Color(Palette.MAGNET, 0.5 * t), 1.5)

	# Horseshoe magnet icon: arc opening downward + two legs with white tips
	draw_arc(Vector2(0, -1.5), 5.5, PI, TAU, 16, Palette.MAGNET, 4.0)
	draw_line(Vector2(-5.5, -1.5), Vector2(-5.5, 4.0), Palette.MAGNET, 4.0)
	draw_line(Vector2(5.5, -1.5), Vector2(5.5, 4.0), Palette.MAGNET, 4.0)
	draw_line(Vector2(-5.5, 4.0), Vector2(-5.5, 6.5), Palette.HIT_FLASH, 4.0)
	draw_line(Vector2(5.5, 4.0), Vector2(5.5, 6.5), Palette.HIT_FLASH, 4.0)
