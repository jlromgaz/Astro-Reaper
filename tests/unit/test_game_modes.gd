extends GutTest
## Tests for game modes: Arcade (endless, no boss) vs Classic (with difficulty).

const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")
const ScoreManagerScript := preload("res://scripts/core/score_manager.gd")


func after_each() -> void:
	GameManager.game_mode = GameManager.GameMode.CLASSIC
	GameManager.difficulty = GameManager.Difficulty.MEDIUM
	GameManager.run_time = 0.0
	GameManager.current_state = GameManager.State.MENU


func _action(name: String) -> InputEventAction:
	var ev := InputEventAction.new()
	ev.action = name
	ev.pressed = true
	return ev


## --- GameManager mode/difficulty state ---

func test_defaults_are_classic_medium() -> void:
	assert_eq(GameManager.game_mode, GameManager.GameMode.CLASSIC)
	assert_eq(GameManager.difficulty, GameManager.Difficulty.MEDIUM)


func test_difficulty_multipliers() -> void:
	GameManager.difficulty = GameManager.Difficulty.EASY
	assert_eq(GameManager.get_difficulty_mult(), 0.75)
	GameManager.difficulty = GameManager.Difficulty.MEDIUM
	assert_eq(GameManager.get_difficulty_mult(), 1.0)
	GameManager.difficulty = GameManager.Difficulty.HARD
	assert_eq(GameManager.get_difficulty_mult(), 1.3)


## --- Spawner: no boss in arcade ---

func test_arcade_never_spawns_boss() -> void:
	var spawner: Node = add_child_autofree(
		load("res://scripts/systems/enemy_spawner.gd").new()
	)
	await get_tree().process_frame
	GameManager.game_mode = GameManager.GameMode.ARCADE
	GameManager.run_time = 130.0
	spawner._try_spawn_boss()
	assert_false(spawner._boss_spawned, "Arcade mode must never trigger the boss")


func test_classic_boss_trigger_still_works() -> void:
	var spawner: Node = add_child_autofree(
		load("res://scripts/systems/enemy_spawner.gd").new()
	)
	await get_tree().process_frame
	GameManager.game_mode = GameManager.GameMode.CLASSIC
	GameManager.run_time = 130.0
	spawner._try_spawn_boss()
	assert_true(spawner._boss_spawned, "Classic mode must keep the boss trigger")


## --- Single-page menu: Arcade Endless only ---

func test_menu_starts_on_ship_page() -> void:
	var menu: CanvasLayer = add_child_autofree(MENU_SCENE.instantiate())
	await get_tree().process_frame
	assert_true(menu.ship_list.visible)
	assert_false(menu.mode_list.visible, "Mode selection page was removed — only Arcade Endless remains")


func test_prepare_arcade_launch_always_sets_arcade() -> void:
	var menu: CanvasLayer = add_child_autofree(MENU_SCENE.instantiate())
	await get_tree().process_frame
	GameManager.game_mode = GameManager.GameMode.CLASSIC
	GameManager.difficulty = GameManager.Difficulty.HARD
	menu._prepare_arcade_launch()
	assert_eq(GameManager.game_mode, GameManager.GameMode.ARCADE)
	assert_eq(GameManager.difficulty, GameManager.Difficulty.MEDIUM)


func test_ranking_button_always_opens_arcade_bucket() -> void:
	var menu: CanvasLayer = add_child_autofree(MENU_SCENE.instantiate())
	await get_tree().process_frame
	menu._open_ranking()
	assert_true(menu.ranking_panel.visible)
	assert_eq(menu.ranking_panel.MODES[menu.ranking_panel._mode_index], "arcade")


## --- HUD mode label ---

func test_hud_shows_current_mode() -> void:
	GameManager.game_mode = GameManager.GameMode.CLASSIC
	GameManager.difficulty = GameManager.Difficulty.HARD
	var hud: CanvasLayer = add_child_autofree(
		preload("res://scenes/ui/hud.tscn").instantiate()
	)
	await get_tree().process_frame
	EventBus.game_started.emit()
	assert_true(hud.mode_label.text.contains("HARD"),
		"HUD must show the active mode and difficulty")
	GameManager.game_mode = GameManager.GameMode.ARCADE
	EventBus.game_started.emit()
	assert_true(hud.mode_label.text.contains("ARCADE"))


## --- Scoring ---

func test_arcade_time_bonus_pure() -> void:
	assert_eq(ScoreManagerScript.arcade_time_bonus(60.0), 1500)
	assert_eq(ScoreManagerScript.arcade_time_bonus(0.0), 0)


func test_arcade_run_scores_time_bonus_and_records_mode() -> void:
	var manager: Node = ScoreManagerScript.new()
	manager.save_path = "user://test_scores_modes.json"
	add_child_autofree(manager)
	await get_tree().process_frame
	GameManager.game_mode = GameManager.GameMode.ARCADE
	manager._on_game_started()
	GameManager.run_time = 60.0
	manager._on_game_ended("death")
	assert_eq(manager.last_result.mode, "arcade")
	assert_true(manager.last_result.has("difficulty"))
	# level 1 death scores nothing base — only the 1500 arcade time bonus
	assert_eq(manager.last_result.score, 1500)
	if FileAccess.file_exists("user://test_scores_modes.json"):
		DirAccess.remove_absolute("user://test_scores_modes.json")