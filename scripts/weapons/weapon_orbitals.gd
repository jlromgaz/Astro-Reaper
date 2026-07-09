extends Node2D
## Orbital blades — persistent blades orbiting the owner ship, damaging
## enemies on contact. fire() only syncs the blade count with the weapon
## level; blades are never spawned per shot and free with this node.

const BASE_DAMAGE := 8.0
const ORBIT_RADIUS := 55.0
const ANGULAR_SPEED := 2.5
const MAX_BLADES := 6
const BLADE_RADIUS := 7.0
const HIT_COOLDOWN := 0.4
const COOLDOWN_META := "hit_cooldown"

var _owner_ship: Node2D = null
var _damage_mult := 1.0
var _angle := 0.0
var _blades: Array[Area2D] = []


func fire(owner_ship: Node2D, damage_mult: float = 1.0, _target: Node2D = null) -> void:
	_owner_ship = owner_ship
	_damage_mult = damage_mult
	var level := 1
	if owner_ship.has_method("get_weapon_level"):
		level = maxi(owner_ship.get_weapon_level("weapon_orbitals"), 1)
	_sync_blade_count(mini(1 + level, MAX_BLADES))


func _physics_process(delta: float) -> void:
	if _blades.is_empty():
		return
	_angle = wrapf(_angle + ANGULAR_SPEED * delta, 0.0, TAU)
	var count := _blades.size()
	for i in range(count):
		var blade := _blades[i]
		blade.position = Vector2.RIGHT.rotated(_angle + TAU * float(i) / float(count)) * ORBIT_RADIUS
		var cooldown: float = blade.get_meta(COOLDOWN_META, 0.0)
		if cooldown > 0.0:
			blade.set_meta(COOLDOWN_META, maxf(cooldown - delta, 0.0))


func _sync_blade_count(target_count: int) -> void:
	while _blades.size() > target_count:
		_blades.pop_back().queue_free()
	while _blades.size() < target_count:
		_blades.append(_create_blade())
	# Re-space immediately so a new blade never overlaps an existing one.
	var count := _blades.size()
	for i in range(count):
		_blades[i].position = Vector2.RIGHT.rotated(_angle + TAU * float(i) / float(count)) * ORBIT_RADIUS


func _create_blade() -> Area2D:
	var blade := Area2D.new()
	blade.collision_layer = 4
	blade.collision_mask = 2
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = BLADE_RADIUS
	collision.shape = circle
	blade.add_child(collision)
	blade.add_child(BladeVisual.new())
	blade.set_meta(COOLDOWN_META, 0.0)
	blade.body_entered.connect(_on_blade_body_entered.bind(blade))
	add_child(blade)
	return blade


func _on_blade_body_entered(body: Node2D, blade: Area2D) -> void:
	if not body.is_in_group("enemies"):
		return
	if not body.has_method("take_damage"):
		return
	if blade.get_meta(COOLDOWN_META, 0.0) > 0.0:
		return
	blade.set_meta(COOLDOWN_META, HIT_COOLDOWN)
	body.take_damage(BASE_DAMAGE * _damage_mult)


## Spinning diamond blade in the player projectile color.
class BladeVisual:
	extends Node2D

	const SPIN_SPEED := 8.0
	const HALF_LENGTH := 7.0
	const HALF_WIDTH := 3.5

	func _process(delta: float) -> void:
		rotation = wrapf(rotation + SPIN_SPEED * delta, 0.0, TAU)

	func _draw() -> void:
		# Glow halo
		draw_circle(Vector2.ZERO, HALF_LENGTH * 1.6, Color(Palette.BULLET_PLAYER, 0.15))
		# Diamond body
		draw_colored_polygon(PackedVector2Array([
			Vector2(HALF_LENGTH, 0), Vector2(0, HALF_WIDTH),
			Vector2(-HALF_LENGTH, 0), Vector2(0, -HALF_WIDTH),
		]), Palette.BULLET_PLAYER)
		# Hot core line
		draw_line(Vector2(-HALF_LENGTH * 0.6, 0), Vector2(HALF_LENGTH * 0.6, 0), Color(1, 1, 1, 0.9), 1.0)
