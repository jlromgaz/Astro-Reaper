extends Node2D
## Visual effect for Pulse Wave - expanding fading ring.

var _max_radius := 100.0
var _current_radius := 0.0
var _color := Color(0.4, 0.8, 1.0, 0.4)
var _duration := 0.8
var _elapsed := 0.0

func setup(radius: float, color: Color) -> void:
	_max_radius = radius
	_color = color
	_color.a = 0.8
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	var t = _elapsed / _duration
	_current_radius = lerp(0.0, _max_radius, t)
	_color.a = lerp(0.8, 0.0, t)
	queue_redraw()
	
	if _elapsed >= _duration:
		queue_free()

func _draw() -> void:
	# Draw a thicker ring
	draw_arc(Vector2.ZERO, _current_radius, 0, TAU, 32, _color, 4.0, true)
	# Draw a very faint filled circle
	var fill_color = _color
	fill_color.a *= 0.3
	draw_circle(Vector2.ZERO, _current_radius, fill_color)
