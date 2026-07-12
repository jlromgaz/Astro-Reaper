extends Node2D
## Parametric procedural bullet visual — neon vector-space style.
## Readability rule (docs/art-style-guide.md): player projectiles are
## elongated and cyan-family; enemy projectiles are round and hot.
## Drawn pointing +X — the bullet root node handles rotation.

enum Style { BOLT, BEAM, MISSILE, ORB, MINE }

@export var style: Style = Style.BOLT
@export var length: float = 0.0  # 0 = use per-style default
@export var width: float = 0.0   # 0 = use per-style default

var body_color: Color = Palette.BULLET_PLAYER
var _time := 0.0

const DEFAULTS := {
	Style.BOLT: {"length": 10.0, "width": 4.0},
	Style.BEAM: {"length": 250.0, "width": 8.0},
	Style.MISSILE: {"length": 12.0, "width": 6.0},
	Style.ORB: {"length": 10.0, "width": 10.0},
	Style.MINE: {"length": 12.0, "width": 12.0},
}


func _ready() -> void:
	match style:
		Style.ORB:
			body_color = Palette.BULLET_ENEMY
		Style.MINE:
			body_color = Palette.EXPLOSION
		_:
			body_color = Palette.BULLET_PLAYER
	if length <= 0.0:
		length = DEFAULTS[style]["length"]
	if width <= 0.0:
		width = DEFAULTS[style]["width"]


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	match style:
		Style.BOLT:
			_draw_bolt()
		Style.BEAM:
			_draw_beam()
		Style.MISSILE:
			_draw_missile()
		Style.ORB:
			_draw_orb()
		Style.MINE:
			_draw_mine()


func _draw_bolt() -> void:
	var half := length / 2.0
	# Glow
	draw_rect(Rect2(-half - 2.0, -width, length + 4.0, width * 2.0), Color(body_color, 0.20))
	# Body
	draw_rect(Rect2(-half, -width / 2.0, length, width), body_color)
	# Hot core line
	draw_line(Vector2(-half, 0), Vector2(half, 0), Color(1, 1, 1, 0.9), 1.5)


func _draw_beam() -> void:
	var half := length / 2.0
	var pulse := 0.8 + 0.2 * sin(_time * 30.0)
	# Outer glow
	draw_rect(Rect2(-half, -width, length, width * 2.0), Color(body_color, 0.20 * pulse))
	# Body
	draw_rect(Rect2(-half, -width / 2.0, length, width), Color(body_color, 0.85 * pulse))
	# Hot core
	draw_rect(Rect2(-half, -width * 0.15, length, width * 0.3), Color(1, 1, 1, 0.9 * pulse))


func _draw_missile() -> void:
	var half := length / 2.0
	var hw := width / 2.0
	# Exhaust flame (flickers)
	var flicker := 0.6 + 0.4 * sin(_time * 45.0)
	var flame_len := 6.0 + 4.0 * flicker
	draw_colored_polygon(PackedVector2Array([
		Vector2(-half, hw * 0.7), Vector2(-half - flame_len, 0), Vector2(-half, -hw * 0.7),
	]), Color(Palette.EXPLOSION, 0.8 * flicker))
	# Glow
	draw_circle(Vector2.ZERO, length * 0.8, Color(body_color, 0.12))
	# Body with nose cone
	draw_colored_polygon(PackedVector2Array([
		Vector2(half, 0), Vector2(half * 0.4, hw), Vector2(-half, hw),
		Vector2(-half, -hw), Vector2(half * 0.4, -hw),
	]), body_color)


func _draw_orb() -> void:
	var radius := width / 2.0
	var pulse := 0.7 + 0.3 * sin(_time * 12.0)
	# Glow — generous so enemy shots are unmissable
	draw_circle(Vector2.ZERO, radius * 2.2, Color(body_color, 0.18))
	# Body
	draw_circle(Vector2.ZERO, radius, body_color)
	# Pulsing warning ring
	draw_arc(Vector2.ZERO, radius * 1.6, 0.0, TAU, 20, Color(body_color.lightened(0.3), 0.6 * pulse), 1.5)
	# Hot core
	draw_circle(Vector2.ZERO, radius * 0.4, Color(1, 1, 0.9, 0.9))


func _draw_mine() -> void:
	var radius := width / 2.0
	var pulse := 0.6 + 0.4 * sin(_time * 6.0)
	# Soft proximity glow — pulses to telegraph the trigger radius
	draw_circle(Vector2.ZERO, radius * 2.0, Color(body_color, 0.10 + 0.08 * pulse))
	# Shell outline
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 16, body_color, 2.0)
	# Contact spikes
	for i in range(4):
		var dir := Vector2.RIGHT.rotated(TAU * i / 4.0)
		draw_line(dir * radius, dir * (radius + 3.0), body_color, 2.0)
	# Pulsing core
	draw_circle(Vector2.ZERO, radius * 0.45 * pulse + 1.0, Color(body_color.lightened(0.2), 0.9))
