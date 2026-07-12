extends Node2D
## Procedural comet visual — luminescent molten sphere wrapped in flickering
## flames, clearly distinct from enemy shapes (see docs/art-style-guide.md).
## Drawn pointing +X — the comet root rotates via setup(), so the flame trail
## streams behind the flight direction.

const FLASH_DURATION := 0.12
const BODY_RADIUS := 9.0
const FLAME_TONGUES := 7
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
	# Fire trail streaming behind the sphere
	for i in range(TRAIL_SEGMENTS):
		var t := float(i + 1) / float(TRAIL_SEGMENTS)
		var wobble := sin(_time * 20.0 + float(i) * 1.7) * 3.0 * t
		var tail_x := -BODY_RADIUS - 16.0 * t
		draw_circle(
			Vector2(tail_x, wobble),
			6.0 * (1.0 - t * 0.6),
			Color(Palette.EXPLOSION, 0.4 * (1.0 - t))
		)
	# Luminescent pulsing halo
	var pulse := 0.5 + 0.5 * sin(_time * 6.0)
	draw_circle(Vector2.ZERO, BODY_RADIUS * 2.4 + 4.0 * pulse, Color(body_color, 0.10 + 0.08 * pulse))
	# Flickering flame tongues around the sphere
	for i in range(FLAME_TONGUES):
		var flicker := 0.55 + 0.45 * sin(_time * 21.0 + float(i) * 1.7)
		var angle := TAU * float(i) / float(FLAME_TONGUES) + sin(_time * 13.0 + float(i) * 2.3) * 0.25
		var dir := Vector2(cos(angle), sin(angle))
		var side := dir.orthogonal() * BODY_RADIUS * 0.35
		var tip := dir * (BODY_RADIUS + 5.0 + 6.0 * flicker)
		var base := dir * BODY_RADIUS * 0.8
		draw_colored_polygon(PackedVector2Array([
			base + side, tip, base - side,
		]), Color(Palette.EXPLOSION, 0.55 * flicker))
	# Molten sphere body
	draw_circle(Vector2.ZERO, BODY_RADIUS, color)
	# White-hot flickering core
	var core := BODY_RADIUS * 0.45 + 1.5 * sin(_time * 17.0)
	draw_circle(Vector2.ZERO, core, Color(Palette.HIT_FLASH, 0.75))
