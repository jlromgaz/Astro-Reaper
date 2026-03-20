extends CharacterBody2D
## Player ship. Movement via virtual joystick, auto-fire.

const BASE_SPEED := 120.0
const BASE_HP := 150.0

var max_hp: float = BASE_HP
var current_hp: float = BASE_HP
var damage_mult: float = 1.0
var fire_rate_mult: float = 1.0
var pickup_radius: float = 40.0

var _move_input := Vector2.ZERO
var _weapons: Array[Node2D] = []
var _fire_timer: float = 0.0
var _fire_interval: float = 0.5  # 2 shots/sec base
const INVINCIBILITY_TIME := 0.8  # Seconds immune after taking damage
var _invincibility_timer: float = 0.0


func _ready() -> void:
	DebugLog.log_info("PLAYER", "Player spawned")
	_add_weapon(preload("res://scripts/weapons/weapon_blaster.gd"))
	EventBus.player_spawned.emit(self)
	EventBus.game_started.connect(_on_game_started)


func _on_game_started() -> void:
	current_hp = max_hp
	_invincibility_timer = 0.0


func _physics_process(delta: float) -> void:
	if not GameManager.is_playing():
		return
	if _invincibility_timer > 0:
		_invincibility_timer -= delta
	velocity = _move_input * BASE_SPEED
	move_and_slide()
	_try_fire(delta)


func set_move_input(direction: Vector2) -> void:
	_move_input = direction.limit_length(1.0)


func _add_weapon(script: GDScript) -> void:
	var w: Node2D = script.new() as Node2D
	add_child(w)
	_weapons.append(w)


func add_weapon_laser() -> void:
	if _has_weapon("weapon_laser"):
		return
	_add_weapon(preload("res://scripts/weapons/weapon_laser.gd") as GDScript)


func add_weapon_missiles() -> void:
	if _has_weapon("weapon_missiles"):
		return
	_add_weapon(preload("res://scripts/weapons/weapon_missiles.gd") as GDScript)


func _has_weapon(name_prefix: String) -> bool:
	for w in _weapons:
		if w.get_script() and name_prefix in w.get_script().resource_path:
			return true
	return false


func _try_fire(delta: float) -> void:
	_fire_timer += delta
	var interval: float = _fire_interval / fire_rate_mult
	if _fire_timer >= interval:
		_fire_timer = 0.0
		for w in _weapons:
			if w and w.has_method("fire"):
				w.fire(self, damage_mult)


func take_damage(amount: float, _source: Node = null) -> void:
	if _invincibility_timer > 0:
		return  # Still invincible from previous hit
	current_hp -= amount
	_invincibility_timer = INVINCIBILITY_TIME
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
