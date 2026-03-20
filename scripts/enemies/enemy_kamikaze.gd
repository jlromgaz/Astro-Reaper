extends CharacterBody2D
## Fast kamikaze - charges straight at player.

const SPEED := 120.0
const HP := 8.0
const DAMAGE := 8.0
const XP_VALUE := 1

var hp: float = HP
var _player: Node2D


func _ready() -> void:
	add_to_group("enemies")
	call_deferred("_find_player")


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if not _player:
		_player = get_parent().get_node_or_null("Player")


func _physics_process(delta: float) -> void:
	if not _player or not GameManager.is_playing():
		return
	var dir: Vector2 = (_player.global_position - global_position).normalized()
	velocity = dir * SPEED
	move_and_slide()
	if get_slide_collision_count() > 0:
		var col: KinematicCollision2D = get_slide_collision(0)
		if col.get_collider().is_in_group("player"):
			col.get_collider().take_damage(DAMAGE, self)


func take_damage(amount: float) -> void:
	hp -= amount
	EventBus.enemy_damaged.emit(self, amount)
	if hp <= 0:
		_die()


func _die() -> void:
	_spawn_xp()
	DebugLog.log_info("COMBAT", "Kamikaze killed at %s" % global_position)
	EventBus.enemy_killed.emit(self, global_position)
	queue_free()


func _spawn_xp() -> void:
	var xp_scene: PackedScene = preload("res://scenes/pickups/xp_pickup.tscn")
	var xp: Node = xp_scene.instantiate()
	xp.global_position = global_position
	if xp.has_method("set_value"):
		xp.set_value(XP_VALUE)
	get_parent().add_child(xp)
	EventBus.xp_dropped.emit(global_position, XP_VALUE)
