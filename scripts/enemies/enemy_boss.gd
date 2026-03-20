extends CharacterBody2D
## Boss enemy - large, high HP, slow movement, telegraphed attack.
## When killed, triggers victory.

const SPEED := 25.0
const HP := 500.0
const DAMAGE := 25.0
const XP_VALUE := 20

var hp: float = HP
var _player: Node2D
var _telegraph_timer: float = 0.0
const TELEGRAPH_DURATION := 1.2
const CHARGE_DURATION := 0.5
var _charge_dir: Vector2 = Vector2.ZERO
var _is_charging: bool = false


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	call_deferred("_find_player")


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if not _player:
		_player = get_parent().get_node_or_null("Player")


func _physics_process(delta: float) -> void:
	if not _player or not GameManager.is_playing():
		return
	if _is_charging:
		velocity = _charge_dir * SPEED * 2.0
		move_and_slide()
		_check_charge_collision()
		return
	_telegraph_timer += delta
	if _telegraph_timer >= TELEGRAPH_DURATION:
		_telegraph_timer = 0.0
		_charge_dir = (_player.global_position - global_position).normalized()
		_is_charging = true
		call_deferred("_start_charge_timer")
		return
	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * SPEED
	move_and_slide()
	if get_slide_collision_count() > 0:
		var col := get_slide_collision(0)
		if col.get_collider().is_in_group("player"):
			col.get_collider().take_damage(DAMAGE, self)


func _start_charge_timer() -> void:
	await get_tree().create_timer(CHARGE_DURATION).timeout
	_is_charging = false


func _check_charge_collision() -> void:
	for i in range(get_slide_collision_count()):
		var col := get_slide_collision(i)
		if col.get_collider().is_in_group("player"):
			col.get_collider().take_damage(DAMAGE * 1.5, self)


func take_damage(amount: float) -> void:
	hp -= amount
	EventBus.enemy_damaged.emit(self, amount)
	if hp <= 0:
		_die()


func _die() -> void:
	_spawn_xp()
	DebugLog.log_info("COMBAT", "Boss killed at %s" % global_position)
	EventBus.enemy_killed.emit(self, global_position)
	GameManager.end_game("victory")
	queue_free()


func _spawn_xp() -> void:
	var xp_scene := preload("res://scenes/pickups/xp_pickup.tscn")
	var xp := xp_scene.instantiate()
	xp.global_position = global_position
	if xp.has_method("set_value"):
		xp.set_value(XP_VALUE)
	get_parent().add_child(xp)
	EventBus.xp_dropped.emit(global_position, XP_VALUE)
