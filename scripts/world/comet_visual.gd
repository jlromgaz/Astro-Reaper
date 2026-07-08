extends Node2D
## Procedural comet visual — yellow triangle with a fading trail.
## The trail communicates trajectory (see docs/art-style-guide.md).
## Drawn pointing +X — the comet root rotates via setup().

const FLASH_DURATION := 0.12
const BODY_POINTS: PackedVector2Array = [
	Vector2(16, 0), Vector2(-8, -10), Vector2(-8, 10),
]
const TRAIL_SEGMENTS := 4

var body_color: Color = Palette.COMET
var _flash_timer := 0.0
var _time := 0.0


func _ready() -> void:
	EventBus.enemy_damaged.connect(_on_enemy_damaged)


func _on_enemy_damaged(enemy: Node, _amount: float) -> void:
	if enemy == get_parent():
		_flash_timer = FLASH_DURATION


func _process(delta: float) -> void:
	_time += delta
	if _flash_timer > 0.0:
		_flash_timer -= delta
	queue_redraw()


func _draw() -> void:
	var color := body_color if _flash_timer <= 0.0 else Palette.HIT_FLASH
	# Fading trail behind the body
	for i in range(TRAIL_SEGMENTS):
		var t := float(i + 1) / float(TRAIL_SEGMENTS)
		var wobble := sin(_time * 20.0 + float(i) * 1.7) * 2.0 * t
		var tail_x := -8.0 - 14.0 * t
		var alpha := 0.35 * (1.0 - t)
		draw_circle(Vector2(tail_x, wobble), 5.0 * (1.0 - t * 0.6), Color(body_color, alpha))
	# Glow
	draw_circle(Vector2.ZERO, 16.0, Color(body_color, 0.12))
	# Body
	draw_colored_polygon(BODY_POINTS, color)
	# Rim
	var rim := BODY_POINTS.duplicate()
	rim.append(BODY_POINTS[0])
	draw_polyline(rim, Color(color.lightened(0.4), 0.9), 1.5)
