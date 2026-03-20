extends Node
## Spawns enemies around the player. Difficulty scales with run time.

var _player: Node2D
var _world: Node2D
var _spawn_timer: float = 0.0
var global_difficulty_mult: float = 1.0
const BASE_SPAWN_INTERVAL := 2.0
const MIN_SPAWN_INTERVAL := 0.3 # Even faster in survival
const SURVIVAL_TIME := 120.0 # 2 minutes
const BOSS_LEVEL_THRESHOLD := 10
var _boss_spawned: bool = false

var _enemy_drone: PackedScene
var _enemy_kamikaze: PackedScene
var _enemy_tank: PackedScene
var _enemy_ranged: PackedScene
var _enemy_interceptor: PackedScene
var _enemy_boss: PackedScene


func _ready() -> void:
	_enemy_drone = preload("res://scenes/enemies/enemy_drone.tscn")
	_enemy_kamikaze = preload("res://scenes/enemies/enemy_kamikaze.tscn")
	_enemy_tank = preload("res://scenes/enemies/enemy_tank.tscn")
	_enemy_ranged = preload("res://scenes/enemies/enemy_ranged.tscn")
	_enemy_interceptor = preload("res://scenes/enemies/enemy_interceptor.tscn")
	_enemy_boss = preload("res://scenes/enemies/enemy_boss.tscn")


func set_player(p: Node2D) -> void:
	_player = p


func set_world(w: Node2D) -> void:
	_world = w


func _get_spawn_interval() -> float:
	var progress: float = GameManager.run_time / SURVIVAL_TIME
	# After survival time, we enter extra time (progress > 1.0)
	var scale_factor: float = 1.0 - progress * 0.7 
	if progress > 1.0:
		scale_factor *= 0.5 # Double speed in survival
	scale_factor = clampf(scale_factor, 0.1, 1.0)
	# Difficulty upgrades make it even faster
	return clampf((BASE_SPAWN_INTERVAL * scale_factor) / global_difficulty_mult, MIN_SPAWN_INTERVAL, BASE_SPAWN_INTERVAL)


func _get_enemy_scene() -> PackedScene:
	var level: int = GameManager.run_level
	var roll: float = randf()
	
	# Levels 1-2: Mostly drones, few kamikazes
	if level <= 2:
		return _enemy_drone if roll < 0.8 else _enemy_kamikaze
	# Levels 3-4: Drones fade, kamikazes + ranged appear
	elif level <= 4:
		if roll < 0.3: return _enemy_drone
		elif roll < 0.6: return _enemy_kamikaze
		else: return _enemy_ranged
	# Levels 5-6: Drones rare, tanks appear
	elif level <= 6:
		if roll < 0.15: return _enemy_drone
		elif roll < 0.35: return _enemy_kamikaze
		elif roll < 0.65: return _enemy_ranged
		else: return _enemy_tank
	# Levels 7-8: No more drones, interceptors join
	elif level <= 8:
		if roll < 0.15: return _enemy_kamikaze
		elif roll < 0.40: return _enemy_ranged
		elif roll < 0.65: return _enemy_tank
		else: return _enemy_interceptor
	# Level 9+: Elite composition, heavy enemies only
	else:
		if roll < 0.05: return _enemy_kamikaze
		elif roll < 0.30: return _enemy_ranged
		elif roll < 0.60: return _enemy_tank
		else: return _enemy_interceptor


func _process(delta: float) -> void:
	if not GameManager.is_playing() or not _player:
		return
	_try_spawn_boss()
	_spawn_timer += delta
	var interval: float = _get_spawn_interval()
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_enemy()


func _try_spawn_boss() -> void:
	if _boss_spawned:
		return
	if GameManager.run_time < 120.0:
		return
	_boss_spawned = true
	if not _world or not _player:
		return
	var boss: CharacterBody2D = _enemy_boss.instantiate() as CharacterBody2D
	var offset: Vector2 = Vector2(250, 0)
	if randi() % 2 == 0:
		offset.x = -offset.x
	boss.global_position = _player.global_position + offset
	_world.add_child(boss)
	DebugLog.log_info("SPAWN", "Boss spawned at %s" % boss.global_position)
	EventBus.enemy_spawned.emit(boss)
	EventBus.boss_spawned.emit(boss)


func _spawn_enemy() -> void:
	if not _world or not _player:
		return
	var scene: PackedScene = _get_enemy_scene()
	var enemy: CharacterBody2D = scene.instantiate() as CharacterBody2D
	
	# Scale stats based on time-progress (0.0 to 1.0 and beyond)
	var progress: float = GameManager.run_time / SURVIVAL_TIME
	var time_scale = 1.0 + progress * 0.5 # 50% stronger at 2 min
	var total_scale = time_scale * global_difficulty_mult
	
	if enemy.has_method("apply_difficulty_scale"):
		enemy.apply_difficulty_scale(total_scale)
	elif "max_hp" in enemy:
		enemy.max_hp *= total_scale
		if "current_hp" in enemy: enemy.current_hp = enemy.max_hp
	
	var offset: Vector2 = Vector2(randf_range(200, 350), randf_range(-150, 150))
	if randi() % 2 == 0:
		offset.x = -offset.x
	if randi() % 2 == 0:
		offset.y = -offset.y
	enemy.global_position = _player.global_position + offset
	_world.add_child(enemy)
	DebugLog.log_info("SPAWN", "Spawned enemy at %s" % enemy.global_position)
	EventBus.enemy_spawned.emit(enemy)
