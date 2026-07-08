extends Control
## Circular visual for the virtual joystick base and knob.
## Keeps the Control API (rect, position, size) the drag logic relies on.

@export var ring_color: Color = Color(0.2, 0.8, 1, 0.35)
@export var filled := false


func _draw() -> void:
	var center := size / 2.0
	var radius := minf(size.x, size.y) / 2.0
	if filled:
		draw_circle(center, radius, ring_color)
		draw_arc(center, radius - 1.0, 0.0, TAU, 32, Color(ring_color.lightened(0.3), ring_color.a), 1.5)
	else:
		draw_circle(center, radius, Color(ring_color, ring_color.a * 0.3))
		draw_arc(center, radius - 1.0, 0.0, TAU, 32, ring_color, 2.0)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		queue_redraw()
