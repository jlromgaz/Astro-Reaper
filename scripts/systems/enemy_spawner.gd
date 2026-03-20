extends Node
## Spawns enemies around the player. Difficulty scales with run time.

var _player: Node2D
var _world: Node2D
var _spawn_timer: float = 0.0
const BASE_SPAWN_INTERVAL := 2.0
const MIN_SPAWN_INTERVAL := 0.8
const BOSS_TIME_THRESHOLD := 180.0
const BOSS_LEVEL_THRESHOLD := 5
var _boss_spawned: bool = false

var _enemy_drone: PackedScene
var _enemy_kamikaze: PackedScene
var _enemy_tank: PackedScene
var _enemy_ranged: PackedScene
var _enemy_boss: PackedScene


func _ready() -> void:
	_enemy_drone = preload("res://scenes/enemies/enemy_drone.tscn")
	_enemy_kamikaze = preload("res://scenes/enemies/enemy_kamikaze.tscn")
	_enemy_tank = preload("res://scenes/enemies/enemy_tank.tscn")
	_enemy_ranged = preload("res://scenes/enemies/enemy_ranged.tscn")
	_enemy_boss = preload("res://scenes/enemies/enemy_boss.tscn")


func set_player(p: Node2D) -> void:
	_player = p


func set_world(w: Node2D) -> void:
	_world = w


func _get_spawn_interval() -> float:
	var run_minutes := GameManager.run_time / 60.0
	var scale_factor := 1.0 - run_minutes * 0.04
	scale_factor = clampf(scale_factor, 0.4, 1.0)
	return clampf(BASE_SPAWN_INTERVAL * scale_factor, MIN_SPAWN_INTERVAL, BASE_SPAWN_INTERVAL)


func _get_enemy_scene() -> PackedScene:
	var run_time := GameManager.run_time
	var roll := randf()
	if run_time < 30.0:
		return _enemy_drone if roll < 0.6 else _enemy_kamikaze
	elif run_time < 60.0:
		if roll < 0.35:
			return _enemy_drone
		elif roll < 0.7:
			return _enemy_kamikaze
		elif roll < 0.85:
			return _enemy_ranged
		else:
			return _enemy_tank
	else:
		if roll < 0.25:
			return _enemy_drone
		elif roll < 0.5:
			return _enemy_kamikaze
		elif roll < 0.75:
			return _enemy_ranged
		else:
			return _enemy_tank


func _process(delta: float) -> void:
	if not GameManager.is_playing() or not _player:
		return
	_try_spawn_boss()
	_spawn_timer += delta
	var interval := _get_spawn_interval()
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_enemy()


func _try_spawn_boss() -> void:
	if _boss_spawned:
		return
	if GameManager.run_time < BOSS_TIME_THRESHOLD and GameManager.run_level < BOSS_LEVEL_THRESHOLD:
		return
	_boss_spawned = true
	if not _world or not _player:
		return
	var boss := _enemy_boss.instantiate() as CharacterBody2D
	var offset := Vector2(250, 0)
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
	var enemy := scene.instantiate() as CharacterBody2D
	var offset := Vector2(randf_range(200, 350), randf_range(-150, 150))
	if randi() % 2 == 0:
		offset.x = -offset.x
	if randi() % 2 == 0:
		offset.y = -offset.y
	enemy.global_position = _player.global_position + offset
	_world.add_child(enemy)
	DebugLog.log_info("SPAWN", "Spawned enemy at %s" % enemy.global_position)
	EventBus.enemy_spawned.emit(enemy)
