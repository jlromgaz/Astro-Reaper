extends CharacterBody2D
## Fast kamikaze - charges straight at player, explodes on contact.

const SPEED            := 75.0   # clearly outrunnable at start (player base: 120)
const HP               := 8.0
const EXPLOSION_DAMAGE := 14.0
const XP_VALUE         := 1
## Frame-checked backstop: the Area2D's body_entered is a one-shot edge
## event — if it is ever missed, this per-frame distance check still
## detonates the kamikaze, so it can never sit glued to the hull.
const DETONATION_RANGE := 16.0

const _FLASH_SCRIPT := preload("res://scripts/fx/intercept_flash.gd")

var current_hp: float = HP
var max_hp: float     = HP
var move_speed: float = SPEED

var _player: Node2D
var _is_dying := false   # guard against double-death


const MAX_SPEED_MULT := 1.8

func apply_difficulty_scale(p_scale: float) -> void:
	max_hp     = HP * p_scale
	current_hp = max_hp
	# Capped so a long, escalated run makes kamikazes tougher but never
	# outright unreactable — HP can climb freely, speed cannot.
	move_speed = SPEED * clampf(1.0 + (p_scale - 1.0) * 0.15, 1.0, MAX_SPEED_MULT)
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


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player = body
		_detonate()


## Single detonation path shared by the area signal and the per-frame
## proximity backstop in _physics_process.
func _detonate() -> void:
	if _is_dying:
		return
	velocity = Vector2.ZERO   # freeze — prevents drilling into ship
	if _player and _player.has_method("take_damage"):
		_player.take_damage(EXPLOSION_DAMAGE, self)
	_explode()


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


func _physics_process(_delta: float) -> void:
	if _is_dying or not _player or not GameManager.is_playing():
		return

	if global_position.distance_to(_player.global_position) <= DETONATION_RANGE:
		_detonate()
		return

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
