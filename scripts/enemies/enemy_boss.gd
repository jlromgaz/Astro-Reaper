extends CharacterBody2D
## Boss enemy - large, high HP, slow movement, telegraphed attack.
## When killed, triggers victory.

const SPEED := 25.0
const HP := 750.0
const DAMAGE := 16.0
const XP_VALUE := 20

var current_hp: float = HP
var max_hp: float = HP
var damage: float = DAMAGE
var spray_damage: float = SPRAY_DAMAGE
var pulse_damage: float = PULSE_DAMAGE
var _player: Node2D
var _is_final: bool = true

@onready var health_bar: ProgressBar = $HealthBar
@onready var hp_label: Label = $HealthBar/HPLabel


## Recurring Arcade wave bosses call set_final(false) so their death
## escalates difficulty instead of ending the run (see enemy_spawner.gd).
func set_final(value: bool) -> void:
	_is_final = value


func apply_difficulty_scale(p_scale: float) -> void:
	max_hp = HP * p_scale
	current_hp = max_hp
	damage = DAMAGE * p_scale
	spray_damage = SPRAY_DAMAGE * p_scale
	pulse_damage = PULSE_DAMAGE * p_scale
	if is_inside_tree() and health_bar:
		health_bar.max_value = max_hp
		health_bar.value = current_hp
		hp_label.text = "%d/%d" % [int(current_hp), int(max_hp)]
	DebugLog.log_info("ENEMY", "Boss scaled to %.1f HP" % max_hp)
const TELEGRAPH_DURATION := 1.2
const CHARGE_DURATION    := 0.5
const PRE_ATTACK_DELAY   := 0.4
const SPRAY_COOLDOWN     := 5.0
const PULSE_COOLDOWN     := 8.0
const SPRAY_DAMAGE       := 9.0
const PULSE_DAMAGE       := 6.0
const BULLET_SPEED       := 160.0
const SPRAY_COUNT        := 6
const PULSE_COUNT        := 8

var _telegraph_timer: float = 0.0
var _charge_dir: Vector2 = Vector2.ZERO
var _is_charging: bool = false
var _spray_timer: float = SPRAY_COOLDOWN
var _pulse_timer: float = PULSE_COOLDOWN + 4.0  # offset so attacks don't overlap

var _bullet_scene: PackedScene = preload("res://scenes/bullets/bullet_enemy.tscn")


func _ready() -> void:
	add_to_group("enemies")
	add_to_group("boss")
	call_deferred("_find_player")
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	hp_label.text = "%d/%d" % [int(current_hp), int(max_hp)]


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
	_spray_timer -= delta
	if _spray_timer <= 0.0:
		_spray_timer = SPRAY_COOLDOWN
		_start_spray_attack()

	_pulse_timer -= delta
	if _pulse_timer <= 0.0:
		_pulse_timer = PULSE_COOLDOWN
		_start_pulse_attack()

	var dir: Vector2 = (_player.global_position - global_position).normalized()
	velocity = dir * SPEED
	move_and_slide()
	if get_slide_collision_count() > 0:
		var col: KinematicCollision2D = get_slide_collision(0)
		if col.get_collider().is_in_group("player"):
			col.get_collider().take_damage(damage, self)


func _do_spray() -> void:
	if not _player:
		return
	var to_player: Vector2 = (_player.global_position - global_position).normalized()
	var spread_step: float = deg_to_rad(20.0)
	var start_angle: float = -spread_step * (SPRAY_COUNT / 2.0 - 0.5)
	for i in range(SPRAY_COUNT):
		_spawn_bullet(to_player.rotated(start_angle + i * spread_step), spray_damage)


func _do_pulse() -> void:
	for i in range(PULSE_COUNT):
		_spawn_bullet(Vector2.RIGHT.rotated(TAU / PULSE_COUNT * i), pulse_damage)


func _start_spray_attack() -> void:
	var vis := get_node_or_null("EnemyVisual")
	if vis and vis.has_method("start_telegraph"):
		vis.start_telegraph(PRE_ATTACK_DELAY)
	await get_tree().create_timer(PRE_ATTACK_DELAY).timeout
	if not is_instance_valid(self) or is_queued_for_deletion():
		return
	_do_spray()


func _start_pulse_attack() -> void:
	var vis := get_node_or_null("EnemyVisual")
	if vis and vis.has_method("start_telegraph"):
		vis.start_telegraph(PRE_ATTACK_DELAY)
	await get_tree().create_timer(PRE_ATTACK_DELAY).timeout
	if not is_instance_valid(self) or is_queued_for_deletion():
		return
	_do_pulse()


func _spawn_bullet(dir: Vector2, dmg: float) -> void:
	var b: Node = _bullet_scene.instantiate()
	b.global_position = global_position
	if b.has_method("setup"):
		b.setup(dmg, BULLET_SPEED, dir)
	get_parent().add_child(b)


func _start_charge_timer() -> void:
	await get_tree().create_timer(CHARGE_DURATION).timeout
	_is_charging = false


func _check_charge_collision() -> void:
	for i in range(get_slide_collision_count()):
		var col: KinematicCollision2D = get_slide_collision(i)
		if col.get_collider().is_in_group("player"):
			col.get_collider().take_damage(damage * 1.5, self)


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
	_spawn_xp()
	DebugLog.log_info("COMBAT", "Boss killed at %s" % global_position)
	EventBus.enemy_killed.emit(self, global_position)
	if _is_final:
		EventBus.boss_defeated.emit()
	else:
		EventBus.wave_boss_defeated.emit()
	queue_free()


func _spawn_xp() -> void:
	var xp_scene: PackedScene = preload("res://scenes/pickups/xp_pickup.tscn")
	var xp: Node = xp_scene.instantiate()
	xp.global_position = global_position
	if xp.has_method("set_value"):
		xp.set_value(XP_VALUE)
	get_parent().add_child(xp)
	EventBus.xp_dropped.emit(global_position, XP_VALUE)
