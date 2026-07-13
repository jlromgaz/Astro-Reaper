extends GutTest
## Tests for GameManager.mode_key() — the per-mode leaderboard bucket id.

var _prev_mode: GameManager.GameMode
var _prev_difficulty: GameManager.Difficulty


func before_each() -> void:
	_prev_mode = GameManager.game_mode
	_prev_difficulty = GameManager.difficulty


func after_each() -> void:
	GameManager.game_mode = _prev_mode
	GameManager.difficulty = _prev_difficulty


func test_classic_keys_include_difficulty() -> void:
	GameManager.game_mode = GameManager.GameMode.CLASSIC
	GameManager.difficulty = GameManager.Difficulty.EASY
	assert_eq(GameManager.mode_key(), "classic-easy")
	GameManager.difficulty = GameManager.Difficulty.MEDIUM
	assert_eq(GameManager.mode_key(), "classic-medium")
	GameManager.difficulty = GameManager.Difficulty.HARD
	assert_eq(GameManager.mode_key(), "classic-hard")


func test_arcade_key_ignores_difficulty() -> void:
	GameManager.game_mode = GameManager.GameMode.ARCADE
	GameManager.difficulty = GameManager.Difficulty.HARD
	assert_eq(GameManager.mode_key(), "arcade")


func test_all_keys_are_ranking_panel_buckets() -> void:
	var panel_script := load("res://scripts/ui/ranking_panel.gd")
	GameManager.game_mode = GameManager.GameMode.CLASSIC
	for diff in [GameManager.Difficulty.EASY, GameManager.Difficulty.MEDIUM, GameManager.Difficulty.HARD]:
		GameManager.difficulty = diff
		assert_has(panel_script.MODES, GameManager.mode_key())
	GameManager.game_mode = GameManager.GameMode.ARCADE
	assert_has(panel_script.MODES, GameManager.mode_key())
