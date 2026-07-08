extends Area2D
## Homing missile - seeks nearest enemy and damages on hit.

var damage: float = 35.0
var speed: float = 180.0
var _target: Node2D = null
var _target_search_timer: float = 0.0
const TARGET_TIMEOUT := 2.0
var _velocity := Vector2.ZERO
const HOMING_STRENGTH := 4.0
const LIFETIME := 4.0
var _lifetime_left: float = LIFETIME
var _owner_ship: Node2D


func setup(dmg: float, spd: float, owner_ship: Node2D) -> void:
	damage = dmg
	speed = spd
	_owner_ship = owner_ship
	_velocity = Vector2.RIGHT.rotated(rotation) * speed
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	_lifetime_left -= delta
	if _lifetime_left <= 0:
		queue_free()
		return

	# Re-acquire target every frame when we don't have one.
	if not _target:
		_target = _find_nearest_enemy()
		if _target:
			_target.tree_exiting.connect(_on_target_lost)

	# Check if target is still valid
	if _target and (not is_instance_valid(_target) or _target.is_queued_for_deletion()):
		_target = null

	# Steer toward target if we have one; otherwise fly straight.
	if _target:
		var target_pos: Vector2 = _target.global_position
		var to_target: Vector2 = (target_pos - global_position).normalized()
		_velocity = _velocity.lerp(to_target * speed, HOMING_STRENGTH * delta).limit_length(speed)

	position += _velocity * delta
	rotation = _velocity.angle()


func _on_target_lost() -> void:
	_target = null


func _find_nearest_enemy() -> Node2D:
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist: float = INF
	for node in enemies:
		var body: Node2D = node as Node2D
		if not is_instance_valid(body):
			continue
		var d: float = global_position.distance_squared_to(body.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = body
	return nearest


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		_damage_entity(body)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		_damage_entity(area)

func _damage_entity(entity: Node) -> void:
	if entity.has_method("take_damage"):
		entity.take_damage(damage)
	queue_free()
