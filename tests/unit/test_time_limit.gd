extends GutTest
## Arcade overtime limit: once the FIRST wave boss falls, the run has
## ARCADE_OVERTIME_LIMIT seconds left before it auto-ends ("time_up"),
## flowing into the normal save-score invitation. Kills the truly
## infinite god-run without touching the pre-boss game.

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func before_each() -> void:
	GameManager.start_game()


func after_each() -> void:
	get_tree().paused = false
	GameManager.current_state = GameManager.State.MENU
	GameManager.run_time = 0.0


func test_first_wave_boss_kill_arms_the_overtime_limit() -> void:
	GameManager.run_time = 120.0
	EventBus.wave_boss_defeated.emit()
	assert_eq(GameManager._time_limit, 120.0 + GameManager.ARCADE_OVERTIME_LIMIT,
		"the countdown must start at the first boss kill")


func test_later_boss_kills_do_not_extend_the_limit() -> void:
	GameManager.run_time = 120.0
	EventBus.wave_boss_defeated.emit()
	GameManager.run_time = 300.0
	EventBus.wave_boss_defeated.emit()
	assert_eq(GameManager._time_limit, 120.0 + GameManager.ARCADE_OVERTIME_LIMIT,
		"killing more bosses must never push the deadline back")


func test_no_boss_kill_means_no_limit() -> void:
	GameManager.run_time = 9999.0
	watch_signals(EventBus)
	GameManager._process(1.0 / 60.0)
	assert_signal_not_emitted(EventBus, "game_ended",
		"without a boss kill the run must stay uncapped")


func test_run_ends_with_time_up_when_the_limit_expires() -> void:
	GameManager.run_time = 120.0
	EventBus.wave_boss_defeated.emit()
	GameManager.run_time = GameManager._time_limit  # deadline reached
	watch_signals(EventBus)
	GameManager._process(1.0 / 60.0)
	assert_signal_emitted_with_parameters(EventBus, "game_ended", ["time_up"])
	assert_eq(GameManager.current_state, GameManager.State.GAME_OVER)


func test_starting_a_new_run_clears_the_old_limit() -> void:
	GameManager.run_time = 120.0
	EventBus.wave_boss_defeated.emit()
	GameManager.start_game()
	assert_eq(GameManager._time_limit, -1.0, "a fresh run must start uncapped")


func test_hud_shows_time_up_title() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	EventBus.game_ended.emit("time_up")
	assert_eq(hud.game_over_title.text, "TIME UP!")
