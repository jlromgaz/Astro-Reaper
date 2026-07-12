extends Node2D
## Parametric procedural pickup visual — neon vector-space style.
## XP is a spinning gem (rotated square), health is a pulsing cross.
## Colors resolve from Palette (see docs/art-style-guide.md).

enum Kind { XP, HEALTH }

@export var kind: Kind = Kind.XP
@export var body_radius: float = 6.0

var body_color: Color = Palette.XP_GEM
var _time := 0.0


func _ready() -> void:
	body_color = Palette.XP_GEM if kind == Kind.XP else Palette.HEALTH
	# Desync idle animations between pickups
	_time = randf() * TAU


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func _draw() -> void:
	match kind:
		Kind.XP:
			_draw_gem()
		Kind.HEALTH:
			_draw_cross()


func _draw_gem() -> void:
	var sparkle := 0.75 + 0.25 * sin(_time * 5.0)
	var spin := _time * 1.5
	var points := PackedVector2Array()
	for i in range(4):
		var angle := spin + TAU * float(i) / 4.0
		points.append(Vector2(cos(angle), sin(angle)) * body_radius)
	# Glow
	draw_circle(Vector2.ZERO, body_radius * 1.6, Color(body_color, 0.12 * sparkle))
	# Gem body
	draw_colored_polygon(points, Color(body_color, sparkle))
	# Facet highlight
	draw_line(points[0], points[2], Color(1, 1, 1, 0.5 * sparkle), 1.0)


func _draw_cross() -> void:
	var pulse := 0.8 + 0.2 * sin(_time * 4.0)
	var r := body_radius
	var arm := r * 0.4
	# Glow
	draw_circle(Vector2.ZERO, r * 1.8, Color(body_color, 0.15 * pulse))
	# Rounded body
	draw_circle(Vector2.ZERO, r, Color(body_color, pulse))
	# White cross
	draw_rect(Rect2(-arm / 2.0, -r * 0.65, arm, r * 1.3), Color(1, 1, 1, 0.95))
	draw_rect(Rect2(-r * 0.65, -arm / 2.0, r * 1.3, arm), Color(1, 1, 1, 0.95))
