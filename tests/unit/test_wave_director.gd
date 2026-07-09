extends GutTest
## Tests for dynamic wave director: pressure gauge based on undamaged streak.

var spawner: Node


func before_each() -> void:
	spawner = add_child_autofree(
		load("res://scripts/systems/enemy_spawner.gd").new()
	)
	await get_tree().process_frame


## --- Streak state ---

func test_undamaged_streak_starts_at_zero() -> void:
	assert_eq(spawner._undamaged_streak, 0.0)


func test_streak_resets_on_player_damaged() -> void:
	spawner._undamaged_streak = 50.0
	EventBus.player_damaged.emit(5.0, null)
	assert_eq(spawner._undamaged_streak, 0.0, "Streak must reset when player takes damage")


## --- Spawn interval under pressure ---

func test_spawn_interval_shorter_under_pressure() -> void:
	# Without pressure
	spawner._undamaged_streak = 0.0
	var normal_interval: float = spawner._get_spawn_interval()
	# With pressure (streak exceeds threshold)
	spawner._undamaged_streak = spawner.PRESSURE_THRESHOLD + 1.0
	var pressure_interval: float = spawner._get_spawn_interval()
	assert_lt(pressure_interval, normal_interval, "Spawn interval must be shorter under sustained pressure")


func test_pressure_does_not_breach_min_interval() -> void:
	spawner._undamaged_streak = 9999.0
	spawner.global_difficulty_mult = 10.0
	var interval: float = spawner._get_spawn_interval()
	assert_gte(interval, spawner.MIN_SPAWN_INTERVAL, "Pressure must never push interval below the hard minimum")


func test_no_pressure_below_threshold() -> void:
	spawner._undamaged_streak = spawner.PRESSURE_THRESHOLD - 1.0
	var below_interval: float = spawner._get_spawn_interval()
	spawner._undamaged_streak = 0.0
	var zero_interval: float = spawner._get_spawn_interval()
	assert_eq(below_interval, zero_interval, "Interval must not change until streak crosses the threshold")
