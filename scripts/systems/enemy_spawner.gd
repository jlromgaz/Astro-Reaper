extends Node
## Spawns enemies around the player. Difficulty scales with run time.

var _player: Node2D
var _world: Node2D
var _spawn_timer: float = 0.0
var global_difficulty_mult: float = 1.0
## Spawn-frequency-only multiplier — never feeds enemy HP/damage scaling.
## Bumped by the "+5% More Enemies" upgrade.
var enemy_density_mult: float = 1.0
var _undamaged_streak: float = 0.0
const BASE_SPAWN_INTERVAL := 2.0
const MIN_SPAWN_INTERVAL := 0.3
const SURVIVAL_TIME := 120.0
const BOSS_LEVEL_THRESHOLD := 10
const PRESSURE_THRESHOLD := 30.0
const PRESSURE_SPAWN_MULT := 1.3
var _boss_spawned: bool = false

# Arcade recurring wave boss: reuses enemy_boss.tscn but never ends the run.
const ARCADE_BOSS_INTERVAL := 120.0
const ARCADE_BOSS_SCALE_STEP := 0.6
const WAVE_BOSS_DIFFICULTY_MULT := 1.2
# Ceiling on global_difficulty_mult so the compounding per-kill bump ramps
# the run up meaningfully without individual enemy formulas blowing up
# (e.g. kamikazes felt "insane" once combined scale hit ~9x after 2 kills).
const GLOBAL_DIFFICULTY_CAP := 4.0
var _arcade_boss_timer: float = 0.0
var _arcade_boss_wave: int = 0

# Comet spawning
var _comet_timer: float = 0.0
var _comet_interval: float = 30.0
const COMET_MIN_INTERVAL := 15.0
const COMET_MAX_INTERVAL := 30.0
var _comet_scene: PackedScene

# Chest spawning (rarer than comets)
var _chest_timer: float = 0.0
var _chest_interval: float = 60.0
const CHEST_MIN_INTERVAL := 90.0
const CHEST_MAX_INTERVAL := 160.0
var _chest_scene: PackedScene

# Demon icon spawning (summonable mini-boss) — each summon is tougher.
var _demon_timer: float = 0.0
var _demon_interval: float = 70.0
const DEMON_MIN_INTERVAL := 50.0
const DEMON_MAX_INTERVAL := 90.0
const DEMON_SCALE_STEP := 0.4
const DEMON_SCALE_CAP := 5.0
var _demon_scene: PackedScene
var _demon_summon_count: int = 0

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
	_comet_scene = preload("res://scenes/world/comet.tscn")
	_comet_interval = randf_range(COMET_MIN_INTERVAL, COMET_MAX_INTERVAL)
	_chest_scene = preload("res://scenes/world/chest.tscn")
	_chest_interval = randf_range(CHEST_MIN_INTERVAL, CHEST_MAX_INTERVAL)
	_demon_scene = preload("res://scenes/world/demon_icon.tscn")
	_demon_interval = randf_range(DEMON_MIN_INTERVAL, DEMON_MAX_INTERVAL)
	EventBus.difficulty_bump.connect(_on_difficulty_bump)
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.enemy_killed.connect(_on_enemy_killed_drop)
	EventBus.wave_boss_defeated.connect(_on_wave_boss_defeated)
	EventBus.player_increased_enemy_density.connect(_on_player_increased_enemy_density)


func _on_difficulty_bump() -> void:
	global_difficulty_mult += 0.05
	DebugLog.log_info("SPAWNER", "Difficulty bump → global_mult=%.2f" % global_difficulty_mult)


func _on_wave_boss_defeated() -> void:
	# Multiplicative, not additive: each kill compounds on the last so the
	# run ramps much faster from the first boss onward instead of plateauing.
	# Capped so a long run keeps escalating meaningfully without runaway.
	global_difficulty_mult = minf(global_difficulty_mult * WAVE_BOSS_DIFFICULTY_MULT, GLOBAL_DIFFICULTY_CAP)


func _on_player_increased_enemy_density() -> void:
	enemy_density_mult *= 1.05
	DebugLog.log_info("SPAWNER", "Player chose +5%% more enemies → density_mult=%.2f" % enemy_density_mult)


func _on_player_damaged(_amount: float, _source: Node) -> void:
	_undamaged_streak = 0.0


func set_player(p: Node2D) -> void:
	_player = p


func set_world(w: Node2D) -> void:
	_world = w


func _get_spawn_interval() -> float:
	var progress: float = GameManager.run_time / SURVIVAL_TIME
	var scale_factor: float = 1.0 - progress * 0.7
	if progress > 1.0:
		scale_factor *= 0.5
	scale_factor = clampf(scale_factor, 0.1, 1.0)
	var pressure_mult: float = PRESSURE_SPAWN_MULT if _undamaged_streak > PRESSURE_THRESHOLD else 1.0
	return clampf(
		(BASE_SPAWN_INTERVAL * scale_factor) / (global_difficulty_mult * pressure_mult * enemy_density_mult),
		MIN_SPAWN_INTERVAL,
		BASE_SPAWN_INTERVAL
	)


func _get_enemy_scene() -> PackedScene:
	var t: float = GameManager.run_time
	var roll: float = randf()
	
	# 0-30s: Mostly drones, some kamikazes
	if t < 30.0:
		return _enemy_drone if roll < 0.8 else _enemy_kamikaze
	# 30-60s: Drones fade, ranged appear
	elif t < 60.0:
		if roll < 0.40: return _enemy_drone
		elif roll < 0.70: return _enemy_kamikaze
		else: return _enemy_ranged
	# 60-90s: Drones rare, tanks appear, interceptors begin (10%)
	elif t < 90.0:
		if roll < 0.10: return _enemy_drone
		elif roll < 0.35: return _enemy_kamikaze
		elif roll < 0.70: return _enemy_ranged
		elif roll < 0.90: return _enemy_tank
		else: return _enemy_interceptor
	# 90-120s: Interceptors join, mix of everything
	elif t < 120.0:
		if roll < 0.10: return _enemy_drone
		elif roll < 0.30: return _enemy_kamikaze
		elif roll < 0.60: return _enemy_ranged
		elif roll < 0.85: return _enemy_tank
		else: return _enemy_interceptor
	# 120s+ (boss wave): Elite composition, drones minimal
	else:
		if roll < 0.05: return _enemy_drone
		elif roll < 0.20: return _enemy_kamikaze
		elif roll < 0.45: return _enemy_ranged
		elif roll < 0.65: return _enemy_tank
		else: return _enemy_interceptor


func _process(delta: float) -> void:
	if not GameManager.is_playing() or not _player:
		return
	_undamaged_streak += delta
	_try_spawn_boss()
	_try_spawn_arcade_wave_boss(delta)
	_try_spawn_comet(delta)
	_try_spawn_chest(delta)
	_try_spawn_demon_icon(delta)
	_spawn_timer += delta
	var interval: float = _get_spawn_interval()
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		_spawn_enemy()


func _try_spawn_comet(delta: float) -> void:
	_comet_timer += delta
	if _comet_timer >= _comet_interval:
		_comet_timer = 0.0
		_comet_interval = randf_range(COMET_MIN_INTERVAL, COMET_MAX_INTERVAL)
		_spawn_comet()


func _spawn_comet() -> void:
	if not _world or not _player:
		DebugLog.log_warn("SPAWNER", "_spawn_comet: world or player not set — skipping")
		return
	var comet = _comet_scene.instantiate()
	# Spawn at edge, fly diagonally across
	var angle := randf() * TAU
	var spawn_offset := Vector2(300, 0).rotated(angle)
	comet.global_position = _player.global_position + spawn_offset
	var fly_dir := -spawn_offset.normalized().rotated(randf_range(-0.5, 0.5))
	if comet.has_method("setup"):
		comet.setup(fly_dir)
	_world.add_child(comet)
	DebugLog.log_info("SPAWN", "Comet spawned at %s" % comet.global_position)


func _try_spawn_chest(delta: float) -> void:
	_chest_timer += delta
	if _chest_timer >= _chest_interval:
		_chest_timer = 0.0
		_chest_interval = randf_range(CHEST_MIN_INTERVAL, CHEST_MAX_INTERVAL)
		_spawn_chest()


func _spawn_chest() -> void:
	if not _world or not _player:
		DebugLog.log_warn("SPAWNER", "_spawn_chest: world or player not set — skipping")
		return
	var chest: Area2D = _chest_scene.instantiate()
	var offset: Vector2 = Vector2(randf_range(180, 300), 0).rotated(randf() * TAU)
	chest.global_position = _player.global_position + offset
	_world.add_child(chest)
	DebugLog.log_info("SPAWN", "Chest spawned at %s" % chest.global_position)


const MAGNET_DROP_CHANCE := 0.006
var _magnet_scene: PackedScene = preload("res://scenes/pickups/pickup_magnet.tscn")


func _on_enemy_killed_drop(_enemy: Node2D, position: Vector2) -> void:
	if not _world or randf() >= MAGNET_DROP_CHANCE:
		return
	_drop_magnet(position)


func _drop_magnet(position: Vector2) -> void:
	if not _world:
		return
	var magnet: Area2D = _magnet_scene.instantiate()
	magnet.global_position = position
	_world.add_child.call_deferred(magnet)
	DebugLog.log_info("SPAWN", "XP magnet dropped at %s" % position)


func _try_spawn_demon_icon(delta: float) -> void:
	_demon_timer += delta
	if _demon_timer >= _demon_interval:
		_demon_timer = 0.0
		_demon_interval = randf_range(DEMON_MIN_INTERVAL, DEMON_MAX_INTERVAL)
		_spawn_demon_icon()


func _spawn_demon_icon() -> void:
	_demon_summon_count += 1
	if not _world or not _player:
		DebugLog.log_warn("SPAWNER", "_spawn_demon_icon: world or player not set — skipping")
		return
	var icon: Area2D = _demon_scene.instantiate()
	var offset: Vector2 = Vector2(randf_range(200, 320), 0).rotated(randf() * TAU)
	icon.global_position = _player.global_position + offset
	if icon.has_method("set_miniboss_scale"):
		var scale: float = minf(1.0 + (_demon_summon_count - 1) * DEMON_SCALE_STEP, DEMON_SCALE_CAP)
		icon.set_miniboss_scale(scale)
	_world.add_child(icon)
	DebugLog.log_info("SPAWN", "Demon icon spawned at %s" % icon.global_position)


func _try_spawn_boss() -> void:
	if _boss_spawned:
		return
	if GameManager.game_mode == GameManager.GameMode.ARCADE:
		return
	if GameManager.run_time < 120.0:
		return
	_boss_spawned = true
	if not _world or not _player:
		DebugLog.log_warn("SPAWNER", "_try_spawn_boss: world or player not set — skipping")
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


func _try_spawn_arcade_wave_boss(delta: float) -> void:
	if GameManager.game_mode != GameManager.GameMode.ARCADE:
		return
	_arcade_boss_timer += delta
	if _arcade_boss_timer < ARCADE_BOSS_INTERVAL:
		return
	_arcade_boss_timer = 0.0
	_spawn_arcade_wave_boss()


func _spawn_arcade_wave_boss() -> void:
	_arcade_boss_wave += 1
	if not _world or not _player:
		DebugLog.log_warn("SPAWNER", "_spawn_arcade_wave_boss: world or player not set — skipping")
		return
	var boss: CharacterBody2D = _enemy_boss.instantiate() as CharacterBody2D
	if boss.has_method("set_final"):
		boss.set_final(false)
	var offset: Vector2 = Vector2(250, 0)
	if randi() % 2 == 0:
		offset.x = -offset.x
	boss.global_position = _player.global_position + offset
	_world.add_child(boss)
	var wave_scale: float = (1.0 + _arcade_boss_wave * ARCADE_BOSS_SCALE_STEP) * global_difficulty_mult
	if boss.has_method("apply_difficulty_scale"):
		boss.apply_difficulty_scale(wave_scale)
	DebugLog.log_info(
		"SPAWN",
		"Arcade wave boss #%d spawned at %s (scale=%.2f)" % [_arcade_boss_wave, boss.global_position, wave_scale]
	)
	EventBus.enemy_spawned.emit(boss)
	EventBus.boss_spawned.emit(boss)


func _spawn_enemy() -> void:
	if not _world or not _player:
		DebugLog.log_warn("SPAWNER", "_spawn_enemy: world or player not set — skipping")
		return
	var scene: PackedScene = _get_enemy_scene()
	var enemy: CharacterBody2D = scene.instantiate() as CharacterBody2D
	if not enemy:
		DebugLog.log_error("SPAWNER", "_spawn_enemy: scene.instantiate() returned null")
		return
	
	# Scale stats based on time-progress (0.0 to 1.0 and beyond)
	var progress: float = GameManager.run_time / SURVIVAL_TIME
	var time_scale = 1.0 + progress * 0.5 # 50% stronger at 2 min
	var total_scale = time_scale * global_difficulty_mult * GameManager.get_difficulty_mult()
	
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
