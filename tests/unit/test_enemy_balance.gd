extends GutTest
## Tests for enemy difficulty scaling and balance tuning.
## Covers speed scaling and difficulty_bump signal.

const DRONE_SCENE := preload("res://scenes/enemies/enemy_drone.tscn")
const KAMIKAZE_SCENE := preload("res://scenes/enemies/enemy_kamikaze.tscn")


## apply_difficulty_scale must scale move_speed in addition to HP.
## Before fix: only HP scales (move_speed property may not exist yet).
## After fix: drone gains a move_speed var that scales.
func test_drone_has_scalable_move_speed() -> void:
	var drone: CharacterBody2D = add_child_autofree(DRONE_SCENE.instantiate())
	assert_true("move_speed" in drone, "drone must expose a move_speed variable for scaling")


func test_drone_speed_increases_with_difficulty() -> void:
	var drone: CharacterBody2D = add_child_autofree(DRONE_SCENE.instantiate())
	if not "move_speed" in drone:
		fail_test("drone lacks move_speed — scale fix not yet applied")
		return
	var base: float = drone.move_speed
	drone.apply_difficulty_scale(1.5)
	assert_gt(drone.move_speed, base, "apply_difficulty_scale(1.5) must increase move_speed beyond base")


## Kamikaze must also expose and scale move_speed.
func test_kamikaze_speed_increases_with_difficulty() -> void:
	var k: CharacterBody2D = add_child_autofree(KAMIKAZE_SCENE.instantiate())
	if not "move_speed" in k:
		fail_test("kamikaze lacks move_speed — scale fix not yet applied")
		return
	var base: float = k.move_speed
	k.apply_difficulty_scale(1.5)
	assert_gt(k.move_speed, base, "kamikaze speed must scale with difficulty")


## EventBus.difficulty_bump must exist after adding the signal.
func test_difficulty_bump_signal_exists_on_event_bus() -> void:
	assert_true(
		EventBus.has_signal("difficulty_bump"),
		"EventBus must declare a difficulty_bump signal"
	)


## --- Chaser speed sanity: outrunnable at start, capped forever after ---
## The "glued orange enemy that never explodes" report was largely the
## INTERCEPTOR: 140 base speed (faster than the player's 120) with an
## UNCAPPED ramp — it overtakes the ship, sits inside it, and drains HP.

const INTERCEPTOR_SCENE := preload("res://scenes/enemies/enemy_interceptor.tscn")
const PLAYER_BASE_SPEED := 120.0


func test_interceptor_base_speed_is_below_the_players() -> void:
	var i: CharacterBody2D = autofree(INTERCEPTOR_SCENE.instantiate())
	assert_lt(i.SPEED, PLAYER_BASE_SPEED,
		"an uncatchable chaser is just a homing missile — the player must be able to outrun it")


func test_interceptor_speed_is_capped_at_high_difficulty() -> void:
	var i: CharacterBody2D = autofree(INTERCEPTOR_SCENE.instantiate())
	i.apply_difficulty_scale(9.0)
	assert_lt(i.move_speed, i.SPEED * 2.0, "interceptor ramp must be capped like the kamikaze's")


func test_drone_speed_is_capped_at_high_difficulty() -> void:
	var d: CharacterBody2D = autofree(DRONE_SCENE.instantiate())
	d.apply_difficulty_scale(9.0)
	assert_lt(d.move_speed, d.SPEED * 2.0, "drone ramp must be capped like the kamikaze's")


## --- Kamikaze spawn frequency ---

func test_early_game_kamikaze_share_is_reduced() -> void:
	# Statistical but decisive: 1000 samples at the old 20% rate virtually
	# never land under 15%; at the new ~10% rate they virtually never
	# exceed it. Direct check of the "too frequent" playtest complaint.
	var spawner: Node = add_child_autofree(
		load("res://scripts/systems/enemy_spawner.gd").new()
	)
	await get_tree().process_frame
	var prev_time: float = GameManager.run_time
	GameManager.run_time = 10.0  # early game bracket
	var kamikaze_scene: PackedScene = preload("res://scenes/enemies/enemy_kamikaze.tscn")
	var hits: int = 0
	for i in range(1000):
		if spawner._get_enemy_scene() == kamikaze_scene:
			hits += 1
	GameManager.run_time = prev_time
	assert_lt(hits, 150, "early-game kamikaze share must be ~10%%, not the old 20%% (got %d/1000)" % hits)
