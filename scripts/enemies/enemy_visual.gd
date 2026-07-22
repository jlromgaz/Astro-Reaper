extends Node2D
## Parametric procedural enemy visual — neon vector-space style.
## One script for every enemy: shape encodes role, hue encodes behavior
## class (see docs/art-style-guide.md). Colors resolve from Palette so
## scenes never hardcode Color literals.

enum ShapeType { CIRCLE, TRIANGLE, HEXAGON, DIAMOND, CHEVRON, BOSS }
enum ColorClass { CHASER, FAST, RANGED, ELITE, BOSS }

## Shapes that rotate to face the parent's velocity.
const DIRECTIONAL_SHAPES: Array[ShapeType] = [
	ShapeType.TRIANGLE, ShapeType.DIAMOND, ShapeType.CHEVRON,
]
const FLASH_DURATION := 0.12
const ORIENT_SMOOTHING := 0.15

@export var shape_type: ShapeType = ShapeType.CIRCLE
@export var color_class: ColorClass = ColorClass.CHASER
@export var body_radius: float = 12.0

var body_color: Color = Palette.ENEMY_CHASER
var _flash_timer := 0.0
var _telegraph_timer := 0.0
var _time := 0.0


func _ready() -> void:
	body_color = _resolve_color(color_class)
	EventBus.enemy_damaged.connect(_on_enemy_damaged)
	queue_redraw()  # initial draw — static shapes won't get another one


func _resolve_color(cls: ColorClass) -> Color:
	match cls:
		ColorClass.CHASER: return Palette.ENEMY_CHASER
		ColorClass.FAST: return Palette.ENEMY_FAST
		ColorClass.RANGED: return Palette.ENEMY_RANGED
		ColorClass.ELITE: return Palette.ENEMY_ELITE
		ColorClass.BOSS: return Palette.BOSS
	return Palette.ENEMY_CHASER


func _on_enemy_damaged(enemy: Node, _amount: float) -> void:
	if enemy == get_parent():
		_flash_timer = FLASH_DURATION
		queue_redraw()


func start_telegraph(duration: float) -> void:
	_telegraph_timer = duration
	queue_redraw()


## Most enemies (plain chasers/ranged) draw a fixed shape with no per-frame
## animation — redrawing them every frame just burns CPU rebuilding the same
## vector art (a real mobile stutter source with many enemies on screen).
## Only shapes with continuous motion (spin, flicker, telegraph pulse) need it.
func _needs_continuous_redraw() -> bool:
	if _telegraph_timer > 0.0:
		return true
	if color_class == ColorClass.FAST and shape_type in DIRECTIONAL_SHAPES:
		return true
	return shape_type == ShapeType.HEXAGON or shape_type == ShapeType.BOSS


func _process(delta: float) -> void:
	_time += delta
	var flash_was_active := _flash_timer > 0.0
	if _flash_timer > 0.0:
		_flash_timer -= delta
	if _telegraph_timer > 0.0:
		_telegraph_timer -= delta
	_orient_to_velocity()
	var flash_just_ended := flash_was_active and _flash_timer <= 0.0
	if _needs_continuous_redraw() or flash_just_ended:
		queue_redraw()


func _orient_to_velocity() -> void:
	if shape_type not in DIRECTIONAL_SHAPES:
		return
	var parent := get_parent()
	if parent is CharacterBody2D and parent.velocity.length_squared() > 1.0:
		rotation = lerp_angle(rotation, parent.velocity.angle(), ORIENT_SMOOTHING)


func _draw() -> void:
	var color: Color
	if _flash_timer > 0.0:
		color = Palette.HIT_FLASH
	elif _telegraph_timer > 0.0:
		color = body_color.lerp(Palette.TELEGRAPH_WARN, 0.5 + 0.5 * sin(_time * 25.0))
	else:
		color = body_color
	# Short trail for fast threats (style guide: Motion & FX)
	if color_class == ColorClass.FAST and shape_type in DIRECTIONAL_SHAPES:
		var flicker := 0.6 + 0.4 * sin(_time * 35.0)
		var tail := body_radius * (1.2 + 0.5 * flicker)
		draw_colored_polygon(PackedVector2Array([
			Vector2(-body_radius, body_radius * 0.4),
			Vector2(-body_radius - tail, 0),
			Vector2(-body_radius, -body_radius * 0.4),
		]), Color(body_color, 0.35 * flicker))
	# Glow halo (keeps body hue even while flashing)
	draw_circle(Vector2.ZERO, body_radius * 1.5, Color(body_color, 0.10))
	match shape_type:
		ShapeType.CIRCLE:
			_draw_closed(_circle_points(body_radius), color)
		ShapeType.TRIANGLE:
			_draw_closed(PackedVector2Array([
				Vector2(body_radius * 1.4, 0),
				Vector2(-body_radius, body_radius * 0.8),
				Vector2(-body_radius, -body_radius * 0.8),
			]), color)
		ShapeType.HEXAGON:
			_draw_closed(_regular_polygon(6, body_radius, _time * 0.5), color)
		ShapeType.DIAMOND:
			_draw_closed(PackedVector2Array([
				Vector2(body_radius, 0), Vector2(0, body_radius * 0.7),
				Vector2(-body_radius, 0), Vector2(0, -body_radius * 0.7),
			]), color)
		ShapeType.CHEVRON:
			_draw_closed(PackedVector2Array([
				Vector2(body_radius * 1.3, 0),
				Vector2(-body_radius * 0.7, body_radius * 0.9),
				Vector2(-body_radius * 0.2, 0),
				Vector2(-body_radius * 0.7, -body_radius * 0.9),
			]), color)
		ShapeType.BOSS:
			_draw_boss(color)


func _draw_closed(points: PackedVector2Array, color: Color) -> void:
	draw_colored_polygon(points, color)
	var rim := points.duplicate()
	rim.append(points[0])
	draw_polyline(rim, Color(color.lightened(0.4), 0.9), 1.5)


func _draw_boss(color: Color) -> void:
	# Core
	draw_circle(Vector2.ZERO, body_radius * 0.45, color)
	# Inner rotating hexagon
	draw_colored_polygon(_regular_polygon(6, body_radius * 0.75, _time * 0.8), Color(color, 0.35))
	# Outer counter-rotating ring
	var outer := _regular_polygon(6, body_radius, -_time * 0.5)
	outer.append(outer[0])
	draw_polyline(outer, Color(color.lightened(0.3), 0.9), 2.0)


func _regular_polygon(sides: int, radius: float, phase: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i in range(sides):
		var angle := phase + TAU * float(i) / float(sides)
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	return points


func _circle_points(radius: float) -> PackedVector2Array:
	return _regular_polygon(24, radius, 0.0)
