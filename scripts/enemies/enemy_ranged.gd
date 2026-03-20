extends CharacterBody2D
## Ranged shooter - fires projectiles at player. 2 XP.

const SPEED := 40.0
const HP := 30.0
const DAMAGE := 8.0
const XP_VALUE := 2
const ATTACK_COOLDOWN := 1.2
const BULLET_SPEED := 180.0

var hp: float = HP
var _player: Node2D
var _attack_timer: float = 0.0
var _bullet_scene: PackedScene


func _ready() -> void:
	add_to_group("enemies")
	_bullet_scene = preload("res://scenes/bullets/bullet_enemy.tscn")
	call_deferred("_find_player")


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if not _player:
		_player = get_parent().get_node_or_null("Player")


func _physics_process(delta: float) -> void:
	if not _player or not GameManager.is_playing():
		return
	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * SPEED
	move_and_slide()
	_try_shoot(delta)


func _try_shoot(delta: float) -> void:
	_attack_timer += delta
	if _attack_timer >= ATTACK_COOLDOWN:
		_attack_timer = 0.0
		_shoot()


func _shoot() -> void:
	var bullet := _bullet_scene.instantiate()
	var dir := (_player.global_position - global_position).normalized()
	bullet.global_position = global_position + dir * 20
	if bullet.has_method("setup"):
		bullet.setup(DAMAGE, BULLET_SPEED, dir)
	get_parent().add_child(bullet)


func take_damage(amount: float) -> void:
	hp -= amount
	EventBus.enemy_damaged.emit(self, amount)
	if hp <= 0:
		_die()


func _die() -> void:
	_spawn_xp()
	DebugLog.log_info("COMBAT", "Ranged enemy killed at %s" % global_position)
	EventBus.enemy_killed.emit(self, global_position)
	queue_free()


func _spawn_xp() -> void:
	var xp_scene := preload("res://scenes/pickups/xp_pickup.tscn")
	var xp := xp_scene.instantiate()
	xp.global_position = global_position
	if xp.has_method("set_value"):
		xp.set_value(XP_VALUE)
	get_parent().add_child(xp)
	EventBus.xp_dropped.emit(global_position, XP_VALUE)
