extends CharacterBody2D
## Player ship. Movement via virtual joystick, auto-fire.

const BASE_SPEED := 120.0
const BASE_HP := 100.0

var max_hp: float = BASE_HP
var current_hp: float = BASE_HP
var damage_mult: float = 1.0
var fire_rate_mult: float = 1.0
var pickup_radius: float = 40.0

var _move_input := Vector2.ZERO
var _weapon_scene: PackedScene
var _weapon_instance: Node2D
var _fire_timer: float = 0.0
var _fire_interval: float = 0.5  # 2 shots/sec base


func _ready() -> void:
	DebugLog.log_info("PLAYER", "Player spawned")
	_add_weapon_blaster()
	EventBus.player_spawned.emit(self)
	EventBus.game_started.connect(_on_game_started)


func _on_game_started() -> void:
	current_hp = max_hp


func _physics_process(delta: float) -> void:
	if not GameManager.is_playing():
		return
	velocity = _move_input * BASE_SPEED
	move_and_slide()
	_try_fire(delta)


func set_move_input(direction: Vector2) -> void:
	_move_input = direction.clamp_length(1.0)


func _add_weapon_blaster() -> void:
	var blaster := preload("res://scripts/weapons/weapon_blaster.gd")
	_weapon_instance = blaster.new()
	add_child(_weapon_instance)


func _try_fire(delta: float) -> void:
	_fire_timer += delta
	var interval := _fire_interval / fire_rate_mult
	if _fire_timer >= interval:
		_fire_timer = 0.0
		if _weapon_instance and _weapon_instance.has_method("fire"):
			_weapon_instance.fire(self, damage_mult)


func take_damage(amount: float, _source: Node = null) -> void:
	current_hp -= amount
	DebugLog.log_info("COMBAT", "Player took %.0f damage, HP: %.0f" % [amount, current_hp])
	EventBus.player_damaged.emit(amount, _source)
	if current_hp <= 0:
		_die()


func _die() -> void:
	DebugLog.log_info("COMBAT", "Player died")
	EventBus.player_died.emit()
	GameManager.end_game("death")


func get_pickup_radius() -> float:
	return pickup_radius
