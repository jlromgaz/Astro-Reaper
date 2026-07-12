extends Node2D
## Procedural player ship visual — neon vector-space style.
## Per-ship silhouette pointing +X (parent body rotates toward aim),
## with engine flame, glow halo, shield ring, and hit flash.
## Replaces the old ColorRect placeholder. See docs/art-style-guide.md.

## One distinct silhouette per selectable ship (see data/ships/*.tres).
enum ShipShape { STELLAR, VANGUARD, INTERCEPTOR, PHANTOM }

const FLASH_DURATION := 0.15
const SHIELD_RADIUS := 20.0

var _shape: ShipShape = ShipShape.STELLAR
var _body_color: Color = Palette.PLAYER_CORE
var _flash_timer := 0.0
var _time := 0.0

@onready var _player: Node = get_parent()


func _ready() -> void:
	EventBus.player_damaged.connect(_on_player_damaged)


func set_ship_color(color: Color) -> void:
	_body_color = Color(color.r, color.g, color.b, 1.0)
	queue_redraw()


func set_ship_shape(ship_id: String) -> void:
	match ship_id:
		"stellar":
			_shape = ShipShape.STELLAR
		"vanguard":
			_shape = ShipShape.VANGUARD
		"interceptor":
			_shape = ShipShape.INTERCEPTOR
		"phantom":
			_shape = ShipShape.PHANTOM
		_:
			_shape = ShipShape.STELLAR
	queue_redraw()


## Body silhouette pointing +X so it aligns with the parent's rotation.
func _body_points() -> PackedVector2Array:
	match _shape:
		ShipShape.VANGUARD:
			# Broad blunt pentagon — tanky bruiser
			return PackedVector2Array([
				Vector2(12, 0), Vector2(3, 10), Vector2(-10, 7),
				Vector2(-10, -7), Vector2(3, -10),
			])
		ShipShape.INTERCEPTOR:
			# Long slim dart — speed
			return PackedVector2Array([
				Vector2(17, 0), Vector2(-9, 5), Vector2(-5, 0), Vector2(-9, -5),
			])
		ShipShape.PHANTOM:
			# Swept twin-prong chevron — evasive striker
			return PackedVector2Array([
				Vector2(13, 0), Vector2(-3, 4), Vector2(-11, 10),
				Vector2(-6, 0), Vector2(-11, -10), Vector2(-3, -4),
			])
		_:
			# STELLAR: original balanced arrow
			return PackedVector2Array([
				Vector2(14, 0), Vector2(-10, 9), Vector2(-6, 0), Vector2(-10, -9),
			])


func _on_player_damaged(_amount: float, _source: Node) -> void:
	_flash_timer = FLASH_DURATION


func _process(delta: float) -> void:
	_time += delta
	if _flash_timer > 0.0:
		_flash_timer -= delta
	queue_redraw()


func _draw() -> void:
	_draw_engine_flame()
	_draw_body()
	_draw_shield()


func _draw_engine_flame() -> void:
	var flicker := 0.7 + 0.3 * sin(_time * 40.0)
	var flame_len := 8.0 + 4.0 * flicker
	var flame: PackedVector2Array = [
		Vector2(-8, 4), Vector2(-8 - flame_len, 0), Vector2(-8, -4),
	]
	draw_colored_polygon(flame, Color(Palette.PLAYER_GLOW, 0.6 * flicker))


func _draw_body() -> void:
	var color := _body_color if _flash_timer <= 0.0 else Palette.HIT_FLASH
	var points := _body_points()
	draw_colored_polygon(points, color)
	# Rim outline for separation from background
	var rim := points.duplicate()
	rim.append(points[0])
	draw_polyline(rim, Color(color.lightened(0.4), 0.9), 1.5)
	# Cockpit dot
	draw_circle(Vector2(4, 0), 2.5, Color(0.95, 1.0, 1.0, 0.9))


func _draw_shield() -> void:
	if not _player or not "has_shield" in _player:
		return
	if _player.has_shield and _player.shield_hp > 0.0:
		var pulse := 0.75 + 0.25 * sin(_time * 6.0)
		draw_arc(Vector2.ZERO, SHIELD_RADIUS, 0.0, TAU, 40, Color(Palette.SHIELD, 0.35 * pulse), 2.0)
