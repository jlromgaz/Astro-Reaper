extends GutTest
## Tests for ScoreManager: pure score formula, handler flow, and persistence.

const ScoreManagerScript := preload("res://scripts/core/score_manager.gd")
const TEST_SAVE_PATH := "user://test_scores.json"

var manager: Node


func before_each() -> void:
	manager = ScoreManagerScript.new()
	manager.save_path = TEST_SAVE_PATH
	add_child_autofree(manager)
	await get_tree().process_frame


func after_each() -> void:
	if FileAccess.file_exists(TEST_SAVE_PATH):
		DirAccess.remove_absolute(TEST_SAVE_PATH)


func _make_manager_with_same_path() -> Node:
	var m: Node = ScoreManagerScript.new()
	m.save_path = TEST_SAVE_PATH
	add_child_autofree(m)
	return m


## --- Pure formula: exact values ---

func test_death_score_is_kills_plus_level() -> void:
	# 100*100 + 8*50 = 10400; no victory bonuses on death
	assert_eq(ScoreManagerScript.calculate_score(100, 8, false, -1.0, 0.0), 10400)


func test_victory_score_full_breakdown() -> void:
	# kills 10000 + level 400 + base 10000 + speed (240-180)*50=3000 + hp 0.5*2000=1000
	assert_eq(ScoreManagerScript.calculate_score(100, 8, true, 180.0, 0.5), 24400)


func test_speed_bonus_clamps_to_zero_past_par_time() -> void:
	# 0 + 50 + 10000 + 0 (300s > 240s par) + 0
	assert_eq(ScoreManagerScript.calculate_score(0, 1, true, 300.0, 0.0), 10050)


func test_hp_ratio_is_clamped_to_one() -> void:
	# 0 + 50 + 10000 + 0 + 2000 (ratio 2.0 clamped to 1.0)
	assert_eq(ScoreManagerScript.calculate_score(0, 1, true, 240.0, 2.0), 12050)


## --- Invariants ---

func test_victory_always_outscores_death_with_equal_stats() -> void:
	var death: int = ScoreManagerScript.calculate_score(250, 15, false, -1.0, 0.0)
	var victory: int = ScoreManagerScript.calculate_score(250, 15, true, 239.9, 0.01)
	assert_gt(victory, death, "Victory must always beat death at equal kills/level")


func test_hp_bonus_zero_on_death() -> void:
	var with_hp: int = ScoreManagerScript.calculate_score(50, 5, false, -1.0, 1.0)
	var without_hp: int = ScoreManagerScript.calculate_score(50, 5, false, -1.0, 0.0)
	assert_eq(with_hp, without_hp, "HP ratio must not affect death scores")


## --- Handler flow (plain instance, handlers called directly) ---

func test_game_flow_builds_last_result() -> void:
	manager._on_game_started()
	for i in range(10):
		manager._on_enemy_killed(null, Vector2.ZERO)
	manager._on_boss_defeated()
	manager._on_game_ended("victory")
	assert_false(manager.last_result.is_empty(), "last_result must be built on game_ended")
	assert_true(manager.last_result.victory)
	assert_eq(manager.last_result.kills, 10)


func test_last_result_has_firebase_ready_keys() -> void:
	manager._on_game_started()
	manager._on_game_ended("death")
	for key in ["score", "kills", "run_time", "time_to_boss", "hp_ratio",
			"level", "ship_id", "victory", "date", "app_version"]:
		assert_true(manager.last_result.has(key), "Record must contain key: %s" % key)


func test_game_started_resets_tally() -> void:
	manager._on_enemy_killed(null, Vector2.ZERO)
	manager._on_game_started()
	manager._on_game_ended("death")
	assert_eq(manager.last_result.kills, 0, "game_started must reset the kill tally")


## --- Persistence ---

func test_high_score_roundtrip() -> void:
	manager._on_game_started()
	for i in range(10):
		manager._on_enemy_killed(null, Vector2.ZERO)
	manager._on_game_ended("death")
	var reloaded: Node = _make_manager_with_same_path()
	await get_tree().process_frame
	assert_eq(reloaded.get_high_score(), manager.last_result.score)


func test_lower_score_does_not_replace_high_score() -> void:
	manager._on_game_started()
	for i in range(10):
		manager._on_enemy_killed(null, Vector2.ZERO)
	manager._on_game_ended("death")
	var high: int = manager.get_high_score()
	manager._on_game_started()
	manager._on_enemy_killed(null, Vector2.ZERO)
	manager._on_game_ended("death")
	assert_eq(manager.get_high_score(), high, "A worse run must not replace the high score")
	assert_false(manager.last_result.get("is_high_score", true))


func test_corrupt_save_file_falls_back_to_defaults() -> void:
	var f := FileAccess.open(TEST_SAVE_PATH, FileAccess.WRITE)
	f.store_string("{not valid json!!")
	f.close()
	var m: Node = _make_manager_with_same_path()
	await get_tree().process_frame
	assert_eq(m.get_high_score(), 0, "Corrupt save must fall back to clean defaults")


func test_missing_file_gives_zero_high_score() -> void:
	assert_eq(manager.get_high_score(), 0)
