extends CharacterBody2D
## Fast kamikaze - charges straight at player, explodes on contact.

const SPEED            := 120.0
const HP               := 8.0
const DAMAGE           := 8.0
const EXPLOSION_DAMAGE := 14.0
const XP_VALUE         := 1

const _FLASH_SCRIPT := preload("res://scripts/fx/intercept_flash.gd")

var current_hp: float = HP
var max_hp: float     = HP
var move_speed: float = SPEED

var _player: Node2D
var _damage_timer      := 0.0
var _player_in_contact := false
var _is_dying          := false   # guard against double-death


func apply_difficulty_scale(p_scale: float) -> void:
	max_hp     = HP * p_scale
	current_hp = max_hp
	move_speed = SPEED * (1.0 + (p_scale - 1.0) * 0.3)
	DebugLog.log_info("ENEMY", "Kamikaze scaled to %.1f HP, %.1f spd" % [max_hp, move_speed])


func _ready() -> void:
	add_to_group("enemies")
	call_deferred("_find_player")
	_setup_damage_area()


func _setup_damage_area() -> void:
	var area  := Area2D.new()
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape   = circle
	area.add_child(shape)
	add_child(area)
	area.collision_layer = 0
	area.collision_mask  = 1
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	collision_mask &= ~1


func _on_body_entered(body: Node) -> void:
	if _is_dying:
		return
	if body.is_in_group("player"):
		_player_in_contact = true
		_player            = body
		velocity           = Vector2.ZERO   # freeze — prevents drilling into ship
		if _damage_timer <= 0.0:
			_player.take_damage(EXPLOSION_DAMAGE, self)
			_damage_timer = 0.5
			_explode()
		else:
			DebugLog.log_warn("ENEMY", "Kamikaze body_entered but damage_timer=%.2f — skipping explode" % _damage_timer)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_in_contact = false
		_damage_timer      = 0.0


func _explode() -> void:
	var flash: Node2D    = _FLASH_SCRIPT.new()
	flash.scale_mult     = 1.6
	flash.global_position = global_position
	get_parent().add_child(flash)
	_die()


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if not _player:
		_player = get_parent().get_node_or_null("Player")


func _physics_process(delta: float) -> void:
	if _is_dying or not _player or not GameManager.is_playing():
		return

	if _player_in_contact:
		_damage_timer -= delta
		if _damage_timer <= 0.0:
			if _player.has_method("take_damage"):
				_player.take_damage(DAMAGE, self)
			_damage_timer = 0.5
		return   # don't keep moving into the player

	var dir: Vector2 = (_player.global_position - global_position).normalized()
	velocity = dir * move_speed
	move_and_slide()


func take_damage(amount: float) -> void:
	if _is_dying:
		return
	current_hp -= amount
	EventBus.enemy_damaged.emit(self, amount)
	if current_hp <= 0.0:
		_die()


func _die() -> void:
	if _is_dying:
		return
	_is_dying = true
	set_physics_process(false)
	velocity  = Vector2.ZERO
	if randf() < 0.02:
		_spawn_health()
	call_deferred("_spawn_xp")
	DebugLog.log_info("COMBAT", "Kamikaze killed at %s" % global_position)
	EventBus.enemy_killed.emit(self, global_position)
	queue_free()


func _spawn_health() -> void:
	var hp_scene = load("res://scenes/pickups/pickup_health.tscn")
	var hp       = hp_scene.instantiate()
	hp.global_position = global_position
	get_parent().add_child(hp)


func _spawn_xp() -> void:
	var xp_scene: PackedScene = preload("res://scenes/pickups/xp_pickup.tscn")
	var xp: Node              = xp_scene.instantiate()
	xp.global_position = global_position
	if xp.has_method("set_value"):
		xp.set_value(XP_VALUE)
	get_parent().add_child(xp)
	EventBus.xp_dropped.emit(global_position, XP_VALUE)
