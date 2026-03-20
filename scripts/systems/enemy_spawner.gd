extends Node
## Spawns enemies around the player. Basic wave logic.

var _player: Node2D
var _world: Node2D
var _spawn_timer: float = 0.0
const SPAWN_INTERVAL := 2.0

var _enemy_drone: PackedScene
var _enemy_kamikaze: PackedScene


func _ready() -> void:
	_enemy_drone = preload("res://scenes/enemies/enemy_drone.tscn")
	_enemy_kamikaze = preload("res://scenes/enemies/enemy_kamikaze.tscn")


func set_player(p: Node2D) -> void:
	_player = p


func set_world(w: Node2D) -> void:
	_world = w


func _process(delta: float) -> void:
	if not GameManager.is_playing() or not _player:
		return
	_spawn_timer += delta
	if _spawn_timer >= SPAWN_INTERVAL:
		_spawn_timer = 0.0
		_spawn_enemy()


func _spawn_enemy() -> void:
	if not _world or not _player:
		return
	var choice := randi() % 2
	var scene: PackedScene = _enemy_drone if choice == 0 else _enemy_kamikaze
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
