extends Node2D
## One-shot death burst — expanding, fading particle ring in the
## entity's color. Self-frees after LIFETIME (docs/art-style-guide.md).

const LIFETIME := 0.35
const PARTICLE_COUNT := 8
const SPREAD := 22.0

var color: Color = Palette.EXPLOSION
var _age := 0.0
var _dirs: Array[Vector2] = []


func _ready() -> void:
	for i in range(PARTICLE_COUNT):
		var angle := TAU * float(i) / float(PARTICLE_COUNT) + randf_range(-0.2, 0.2)
		_dirs.append(Vector2.RIGHT.rotated(angle))


func _process(delta: float) -> void:
	_age += delta
	if _age >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := _age / LIFETIME
	var eased := t * (2.0 - t)  # ease-out
	for dir in _dirs:
		draw_circle(dir * SPREAD * eased, 3.0 * (1.0 - t), Color(color, 1.0 - t))
