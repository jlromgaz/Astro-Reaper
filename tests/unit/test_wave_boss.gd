extends GutTest
## Tests for the recurring Arcade wave boss: reuses the final boss's attack
## patterns but never ends the run, spawns every ARCADE_BOSS_INTERVAL, and
## grows stronger (HP + damage) each time.

const BOSS_SCENE := preload("res://scenes/enemies/enemy_boss.tscn")
const SPAWNER_SCRIPT := preload("res://scripts/systems/enemy_spawner.gd")


func after_each() -> void:
	GameManager.game_mode = GameManager.GameMode.CLASSIC
	GameManager.current_state = GameManager.State.MENU


func _make_spawner_with_world() -> Array:
	var world := Node2D.new()
	add_child_autofree(world)
	var player := Node2D.new()
	world.add_child(player)
	var spawner: Node = add_child_autofree(SPAWNER_SCRIPT.new())
	await get_tree().process_frame
	spawner.set_world(world)
	spawner.set_player(player)
	return [spawner, world, player]


## --- enemy_boss: final vs. recurring wave boss ---

func test_final_boss_death_emits_boss_defeated() -> void:
	var boss: CharacterBody2D = add_child_autofree(BOSS_SCENE.instantiate())
	await get_tree().process_frame
	watch_signals(EventBus)
	boss.take_damage(boss.max_hp)
	assert_signal_emitted(EventBus, "boss_defeated")
	assert_signal_not_emitted(EventBus, "wave_boss_defeated")


func test_wave_boss_death_never_ends_the_run() -> void:
	var boss: CharacterBody2D = add_child_autofree(BOSS_SCENE.instantiate())
	await get_tree().process_frame
	boss.set_final(false)
	watch_signals(EventBus)
	boss.take_damage(boss.max_hp)
	assert_signal_emitted(EventBus, "wave_boss_defeated")
	assert_signal_not_emitted(EventBus, "boss_defeated",
		"Recurring wave boss must never trigger victory")


func test_apply_difficulty_scale_increases_damage_stats() -> void:
	var boss: CharacterBody2D = add_child_autofree(BOSS_SCENE.instantiate())
	await get_tree().process_frame
	boss.apply_difficulty_scale(2.0)
	assert_eq(boss.damage, boss.DAMAGE * 2.0, "charge/collision damage must scale")
	assert_eq(boss.spray_damage, boss.SPRAY_DAMAGE * 2.0, "spray damage must scale")
	assert_eq(boss.pulse_damage, boss.PULSE_DAMAGE * 2.0, "pulse damage must scale")


## --- Spawner: recurring cadence in Arcade only ---

func test_arcade_wave_boss_spawns_after_interval() -> void:
	var parts: Array = await _make_spawner_with_world()
	var spawner: Node = parts[0]
	var world: Node2D = parts[1]
	GameManager.game_mode = GameManager.GameMode.ARCADE
	var before: int = world.get_child_count()
	spawner._try_spawn_arcade_wave_boss(spawner.ARCADE_BOSS_INTERVAL)
	await get_tree().process_frame
	assert_eq(world.get_child_count() - before, 1, "must spawn exactly one wave boss after the interval")
	assert_eq(spawner._arcade_boss_wave, 1)


func test_classic_mode_never_spawns_arcade_wave_boss() -> void:
	var parts: Array = await _make_spawner_with_world()
	var spawner: Node = parts[0]
	GameManager.game_mode = GameManager.GameMode.CLASSIC
	spawner._try_spawn_arcade_wave_boss(999.0)
	assert_eq(spawner._arcade_boss_wave, 0, "Classic mode must not spawn recurring wave bosses")


func test_wave_boss_scales_up_each_time() -> void:
	var parts: Array = await _make_spawner_with_world()
	var spawner: Node = parts[0]
	var world: Node2D = parts[1]
	var player: Node2D = parts[2]
	GameManager.game_mode = GameManager.GameMode.ARCADE
	spawner._spawn_arcade_wave_boss()
	await get_tree().process_frame
	var first_boss: Node = null
	for c in world.get_children():
		if c != player and c.is_in_group("boss"):
			first_boss = c
	spawner._spawn_arcade_wave_boss()
	await get_tree().process_frame
	var second_boss: Node = null
	for c in world.get_children():
		if c != player and c != first_boss and c.is_in_group("boss"):
			second_boss = c
	assert_not_null(first_boss)
	assert_not_null(second_boss)
	assert_gt(second_boss.max_hp, first_boss.max_hp, "later wave bosses must have more HP")
	assert_gt(second_boss.damage, first_boss.damage, "later wave bosses must hit harder")


func test_wave_boss_defeat_bumps_global_difficulty() -> void:
	var spawner: Node = add_child_autofree(SPAWNER_SCRIPT.new())
	await get_tree().process_frame
	var before: float = spawner.global_difficulty_mult
	EventBus.wave_boss_defeated.emit()
	assert_almost_eq(
		spawner.global_difficulty_mult, before * spawner.WAVE_BOSS_DIFFICULTY_MULT, 0.001,
		"a wave boss kill must multiply difficulty, not just add a flat amount"
	)


func test_wave_boss_defeats_compound_difficulty() -> void:
	var spawner: Node = add_child_autofree(SPAWNER_SCRIPT.new())
	await get_tree().process_frame
	var start: float = spawner.global_difficulty_mult
	EventBus.wave_boss_defeated.emit()
	EventBus.wave_boss_defeated.emit()
	EventBus.wave_boss_defeated.emit()
	var expected: float = start * pow(spawner.WAVE_BOSS_DIFFICULTY_MULT, 3)
	assert_almost_eq(spawner.global_difficulty_mult, expected, 0.001,
		"repeated wave boss kills must compound, ramping much faster over time")


func test_global_difficulty_is_capped_after_many_wave_boss_kills() -> void:
	# Reported bug: kamikazes went "insane" right after clearing a wave
	# boss — uncapped ~1.5x-per-kill compounding could reach ~9x total
	# scale within 2 kills, blowing up per-enemy formulas that assume a
	# modest range. A hard ceiling keeps the ramp meaningful but sane.
	var spawner: Node = add_child_autofree(SPAWNER_SCRIPT.new())
	await get_tree().process_frame
	for i in range(20):
		EventBus.wave_boss_defeated.emit()
	assert_almost_eq(spawner.global_difficulty_mult, spawner.GLOBAL_DIFFICULTY_CAP, 0.001,
		"global difficulty must never run away unbounded, however many wave bosses are killed")


## --- Demon icon: each summon must be tougher than the last ---

func test_repeated_demon_icon_spawns_scale_up() -> void:
	var parts: Array = await _make_spawner_with_world()
	var spawner: Node = parts[0]
	var world: Node2D = parts[1]
	var player: Node2D = parts[2]
	spawner._spawn_demon_icon()
	await get_tree().process_frame
	var first_icon: Node = null
	for c in world.get_children():
		if c != player and c.is_in_group("demon_icons"):
			first_icon = c
	spawner._spawn_demon_icon()
	await get_tree().process_frame
	var second_icon: Node = null
	for c in world.get_children():
		if c != player and c != first_icon and c.is_in_group("demon_icons"):
			second_icon = c
	assert_not_null(first_icon)
	assert_not_null(second_icon)
	assert_gt(second_icon._miniboss_scale, first_icon._miniboss_scale,
		"each demon icon spawned must summon a tougher mini-boss than the last")


## --- Player-chosen "risky overclock" difficulty upgrade ---

func test_player_increased_difficulty_bumps_global_mult_by_5_percent() -> void:
	var spawner: Node = add_child_autofree(SPAWNER_SCRIPT.new())
	await get_tree().process_frame
	var before: float = spawner.global_difficulty_mult
	EventBus.player_increased_difficulty.emit()
	assert_almost_eq(spawner.global_difficulty_mult, before * 1.05, 0.001,
		"choosing the risky-overclock upgrade must raise difficulty by 5%")


func test_player_increased_difficulty_respects_the_cap() -> void:
	var spawner: Node = add_child_autofree(SPAWNER_SCRIPT.new())
	await get_tree().process_frame
	for i in range(50):
		EventBus.player_increased_difficulty.emit()
	assert_almost_eq(spawner.global_difficulty_mult, spawner.GLOBAL_DIFFICULTY_CAP, 0.001,
		"repeated overclock picks must never exceed the global difficulty ceiling")
