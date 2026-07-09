extends Area2D
## Counter-missile launched by the anti-missile weapon. Homes toward a
## pre-assigned enemy projectile and BOTH explode on contact.
## Never emits EventBus.enemy_killed — intercepts must not inflate kill stats.

const InterceptFlash := preload("res://scripts/fx/intercept_flash.gd")

const SPEED := 320.0
const HOMING_STRENGTH := 8.0
const LIFETIME := 2.0
const RETARGET_RANGE := 250.0
const GRACE_TIME := 0.5
const PROXIMITY_SQ := 64.0

var speed: float = SPEED
var _target: Node2D = null
var _velocity := Vector2.ZERO
var _lifetime_left: float = LIFETIME
var _grace_left: float = GRACE_TIME


func setup(spd: float, target: Node2D) -> void:
	speed = spd
	_velocity = Vector2.RIGHT.rotated(rotation) * speed
	area_entered.connect(_on_area_entered)
	_assign_target(target)


func _physics_process(delta: float) -> void:
	_lifetime_left -= delta
	if _lifetime_left <= 0.0:
		_fizzle()
		return

	if _target and (not is_instance_valid(_target) or _target.is_queued_for_deletion()):
		_target = null

	if _target:
		var to_target: Vector2 = (_target.global_position - global_position).normalized()
		_velocity = _velocity.lerp(to_target * speed, HOMING_STRENGTH * delta).limit_length(speed)
		# Proximity detonation — guards against tunneling past small shapes.
		if global_position.distance_squared_to(_target.global_position) < PROXIMITY_SQ:
			_detonate(_target)
			return
	else:
		_grace_left -= delta
		if _grace_left <= 0.0:
			_fizzle()
			return

	position += _velocity * delta
	rotation = _velocity.angle()


func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemy_projectiles"):
		return
	_detonate(area)


func _on_target_lost() -> void:
	if is_queued_for_deletion():
		return
	_target = null
	var candidate := _find_nearest_unclaimed()
	if candidate:
		candidate.set_meta("intercepted", true)
		_assign_target(candidate)


func _assign_target(target: Node2D) -> void:
	_target = target
	if _target:
		_grace_left = GRACE_TIME
		if not _target.tree_exiting.is_connected(_on_target_lost):
			_target.tree_exiting.connect(_on_target_lost)


func _find_nearest_unclaimed() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist := RETARGET_RANGE * RETARGET_RANGE
	for node in get_tree().get_nodes_in_group("enemy_projectiles"):
		var projectile := node as Node2D
		if projectile == null or not is_instance_valid(projectile) or projectile.is_queued_for_deletion():
			continue
		if projectile.has_meta("intercepted"):
			continue
		var dist := global_position.distance_squared_to(projectile.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = projectile
	return nearest


func _detonate(projectile: Node) -> void:
	if is_queued_for_deletion():
		return
	_spawn_flash(1.0)
	SoundManager.play_enemy_hit()
	if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
		projectile.queue_free()
	queue_free()


func _fizzle() -> void:
	if is_queued_for_deletion():
		return
	_spawn_flash(0.5)
	queue_free()


func _spawn_flash(flash_scale: float) -> void:
	var parent := get_parent()
	if parent == null:
		return
	var flash: Node2D = InterceptFlash.new()
	flash.scale_mult = flash_scale
	parent.add_child(flash)
	flash.global_position = global_position
