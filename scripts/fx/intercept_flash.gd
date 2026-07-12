extends Node2D
## One-shot intercept flash — expanding ring plus shrinking hot core in the
## explosion color. Self-frees after LIFETIME (docs/art-style-guide.md).

const LIFETIME := 0.25
const RING_RADIUS := 18.0
const CORE_RADIUS := 6.0

@export var scale_mult := 1.0

var _age := 0.0


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := _age / LIFETIME
	var eased := t * (2.0 - t)  # ease-out
	var fade := Color(Palette.EXPLOSION, 1.0 - t)
	draw_arc(Vector2.ZERO, maxf(RING_RADIUS * eased * scale_mult, 0.5), 0.0, TAU, 24, fade, 2.0)
	draw_circle(Vector2.ZERO, CORE_RADIUS * (1.0 - t) * scale_mult, fade)
