extends Node2D
## Aura — translucent damage field centered on the ship. Enemies inside take
## periodic tick damage. Radius grows with weapon level and with the owner's
## projectile_size_mult, so size upgrades enlarge the field too.

const BASE_RADIUS := 70.0
const RADIUS_PER_LEVEL := 0.15
const BASE_DAMAGE := 4.0
const TICK := 0.5

var _owner_ship: Node2D = null
var _damage_mult := 1.0
var _radius: float = BASE_RADIUS
var _tick_timer: float = TICK
var _field: Area2D
var _field_shape: CircleShape2D
var _time := 0.0


func _ready() -> void:
	_field = Area2D.new()
	_field.collision_layer = 4
	_field.collision_mask = 2
	var collision := CollisionShape2D.new()
	_field_shape = CircleShape2D.new()
	_field_shape.radius = _radius
	collision.shape = _field_shape
	_field.add_child(collision)
	add_child(_field)


func get_radius() -> float:
	return _radius


func fire(owner_ship: Node2D, damage_mult: float = 1.0, _target: Node2D = null) -> void:
	_owner_ship = owner_ship
	_damage_mult = damage_mult
	var level := 1
	if owner_ship.has_method("get_weapon_level"):
		level = maxi(owner_ship.get_weapon_level("weapon_aura"), 1)
	var size_mult := 1.0
	if "projectile_size_mult" in owner_ship:
		size_mult = owner_ship.projectile_size_mult
	_radius = BASE_RADIUS * (1.0 + RADIUS_PER_LEVEL * float(level - 1)) * size_mult
	if _field_shape:
		_field_shape.radius = _radius
	queue_redraw()


func _physics_process(delta: float) -> void:
	_time += delta
	_tick_timer -= delta
	queue_redraw()
	if _tick_timer > 0.0:
		return
	_tick_timer = TICK
	if not _field:
		return
	for body in _field.get_overlapping_bodies():
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(BASE_DAMAGE * _damage_mult)


func _draw() -> void:
	# Translucent field with a breathing rim so the reach is always readable
	var pulse := 0.5 + 0.5 * sin(_time * 3.0)
	draw_circle(Vector2.ZERO, _radius, Color(Palette.PLAYER_GLOW, 0.07))
	draw_arc(Vector2.ZERO, _radius, 0.0, TAU, 48,
		Color(Palette.PLAYER_GLOW, 0.25 + 0.15 * pulse), 1.5)
