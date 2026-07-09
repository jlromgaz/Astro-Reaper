extends Node2D
## Magnet visual — collapsing concentric rings suggest attraction.

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
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, Color(Palette.XP_GEM, 0.5 * t), 1.5)
	# Core gem
	draw_circle(Vector2.ZERO, 5.0, Palette.XP_GEM)
	draw_circle(Vector2.ZERO, 8.0, Color(Palette.XP_GEM, 0.2))
