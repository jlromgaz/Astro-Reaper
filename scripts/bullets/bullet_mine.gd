extends Area2D
## Proximity mine — arms after ARM_TIME, then explodes when an enemy enters
## its trigger radius, damaging every enemy within AOE_RADIUS. Fizzles after
## LIFETIME. Never emits EventBus.enemy_killed — dying enemies emit it.

const InterceptFlash := preload("res://scripts/fx/intercept_flash.gd")

const ARM_TIME := 0.5
const LIFETIME := 8.0
const AOE_RADIUS := 60.0
const FLASH_SCALE := 2.0

var damage: float = 20.0
var _age := 0.0
var _armed := false


func setup(dmg: float) -> void:
	damage = dmg
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_age += delta
	if not _armed and _age >= ARM_TIME:
		_armed = true
	if _age >= LIFETIME:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not _armed:
		return
	if not body.is_in_group("enemies"):
		return
	_explode()


func _explode() -> void:
	if is_queued_for_deletion():
		return
	for node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node2D
		if enemy == null or not is_instance_valid(enemy) or enemy.is_queued_for_deletion():
			continue
		if global_position.distance_to(enemy.global_position) > AOE_RADIUS:
			continue
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
	_spawn_flash()
	if has_node("/root/SoundManager"):
		get_node("/root/SoundManager").play_enemy_hit()
	queue_free()


func _spawn_flash() -> void:
	var parent := get_parent()
	if parent == null:
		return
	var flash: Node2D = InterceptFlash.new()
	flash.scale_mult = FLASH_SCALE
	parent.add_child(flash)
	flash.global_position = global_position
