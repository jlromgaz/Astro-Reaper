extends CharacterBody2D
## Mini-boss summoned by the demon icon — a tough 200 HP chaser that
## scatters a burst of XP gems on death. Unlike the final boss it never
## emits boss_defeated, so killing it rewards XP without ending the run.

const SPEED := 45.0
const HP := 200.0
const DAMAGE := 10.0
const XP_VALUE := 4
const XP_GEM_COUNT := 8
const XP_SCATTER_RADIUS := 30.0

var current_hp: float = HP
var max_hp: float = HP
var damage: float = DAMAGE
var _player: Node2D

@onready var health_bar: ProgressBar = $HealthBar
@onready var hp_label: Label = $HealthBar/HPLabel


func apply_difficulty_scale(p_scale: float) -> void:
	max_hp = HP * p_scale
	current_hp = max_hp
	damage = DAMAGE * p_scale
	if is_inside_tree() and health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp
		hp_label.text = "%d/%d" % [int(current_hp), int(max_hp)]
	DebugLog.log_info("ENEMY", "Mini-boss scaled to %.1f HP" % max_hp)


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("miniboss")
	call_deferred("_find_player")
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	hp_label.text = "%d/%d" % [int(current_hp), int(max_hp)]


func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player")
	if not _player:
		_player = get_parent().get_node_or_null("Player")


func _physics_process(_delta: float) -> void:
	if not _player or not GameManager.is_playing():
		return
	var dir: Vector2 = (_player.global_position - global_position).normalized()
	velocity = dir * SPEED
	move_and_slide()
	if get_slide_collision_count() > 0:
		var col: KinematicCollision2D = get_slide_collision(0)
		if col.get_collider().is_in_group("player"):
			col.get_collider().take_damage(damage, self)


func take_damage(amount: float) -> void:
	current_hp -= amount
	if health_bar:
		health_bar.value = current_hp
	if hp_label:
		hp_label.text = "%d/%d" % [int(max(current_hp, 0)), int(max_hp)]
	EventBus.enemy_damaged.emit(self, amount)
	if current_hp <= 0:
		_die()


func _die() -> void:
	call_deferred("_spawn_xp_gems")
	DebugLog.log_info("COMBAT", "Mini-boss killed at %s" % global_position)
	EventBus.enemy_killed.emit(self, global_position)
	queue_free()


func _spawn_xp_gems() -> void:
	var xp_scene: PackedScene = preload("res://scenes/pickups/xp_pickup.tscn")
	var parent: Node = get_parent()
	if not parent:
		return
	for i in range(XP_GEM_COUNT):
		var xp: Node2D = xp_scene.instantiate()
		var offset := Vector2(
			randf_range(-XP_SCATTER_RADIUS, XP_SCATTER_RADIUS),
			randf_range(-XP_SCATTER_RADIUS, XP_SCATTER_RADIUS)
		)
		xp.global_position = global_position + offset
		if xp.has_method("set_value"):
			xp.set_value(XP_VALUE)
		parent.add_child(xp)
	EventBus.xp_dropped.emit(global_position, XP_VALUE * XP_GEM_COUNT)
