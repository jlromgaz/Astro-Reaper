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
