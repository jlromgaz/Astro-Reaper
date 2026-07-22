extends GutTest
## Tests for HUD difficulty_bump wiring and end-game screen correctness.

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

var hud: CanvasLayer


func before_each() -> void:
	hud = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame


func after_each() -> void:
	# _on_level_up() emits player_leveled_up, which GameManager listens to
	# and uses to set run_level/pause the tree — must not leak between tests.
	get_tree().paused = false
	GameManager.run_level = 1
	GameManager.current_state = GameManager.State.MENU


## --- difficulty_bump wiring ---

func test_difficulty_bump_emitted_on_upgrade_selection() -> void:
	watch_signals(EventBus)
	hud._on_upgrade_selected({"name": "Heal", "type": "heal", "is_weapon": false})
	assert_signal_emitted(EventBus, "difficulty_bump")


## --- XP curve: increments must grow, not stay flat ---

func test_xp_requirement_increments_keep_growing() -> void:
	hud._on_level_up(2)
	var req_2: int = hud._xp_to_level
	hud._on_level_up(3)
	var req_3: int = hud._xp_to_level
	hud._on_level_up(4)
	var req_4: int = hud._xp_to_level
	var step_2_3: int = req_3 - req_2
	var step_3_4: int = req_4 - req_3
	assert_gt(step_3_4, step_2_3, "each level's XP requirement must grow by more than the last")


func test_xp_requirement_is_much_steeper_than_old_linear_curve() -> void:
	# Old curve was 5 + level*3 -> only 35 XP needed at level 10.
	hud._on_level_up(10)
	assert_gt(hud._xp_to_level, 100,
		"leveling up must be meaningfully harder late-run than the old linear curve")


func test_upgrade_history_grows_on_each_selection() -> void:
	hud._on_upgrade_selected({"name": "+Speed", "type": "speed", "is_weapon": false})
	hud._on_upgrade_selected({"name": "Heal", "type": "heal", "is_weapon": false})
	assert_eq(hud._chosen_upgrades.size(), 2)


func test_upgrade_history_stores_display_name() -> void:
	hud._on_upgrade_selected({"name": "+10% Damage", "type": "stat_damage", "is_weapon": false})
	assert_eq(hud._chosen_upgrades[0], "+10% Damage")


## --- upgrade button color coding ---

func _upgrade(type: String, is_weapon: bool) -> UpgradeData:
	var u := UpgradeData.new()
	u.type = type
	u.is_weapon = is_weapon
	return u


func test_weapon_upgrades_use_weapon_color() -> void:
	assert_eq(hud._upgrade_color(_upgrade("weapon_laser", true)), Palette.UPGRADE_WEAPON)
	assert_eq(hud._upgrade_color(_upgrade("shield", true)), Palette.UPGRADE_WEAPON)


func test_stat_upgrades_use_stat_color() -> void:
	assert_eq(hud._upgrade_color(_upgrade("stat_damage", false)), Palette.UPGRADE_STAT)
	assert_eq(hud._upgrade_color(_upgrade("projectile", false)), Palette.UPGRADE_STAT)


## --- Risky overclock: +5% difficulty upgrade ---

func test_difficulty_upgrade_uses_risk_color() -> void:
	assert_eq(hud._upgrade_color(_upgrade("stat_difficulty", false)), Palette.UPGRADE_RISK)


func test_difficulty_upgrade_is_in_the_pool() -> void:
	var found := false
	for u in hud._upgrade_pool:
		if u.type == "stat_difficulty":
			found = true
	assert_true(found, "the risky-overclock upgrade must be offerable on level-up")


func test_selecting_difficulty_upgrade_emits_player_increased_difficulty() -> void:
	var player: CharacterBody2D = autofree(CharacterBody2D.new())
	hud._player = player
	watch_signals(EventBus)
	hud._apply_upgrade("stat_difficulty")
	assert_signal_emitted(EventBus, "player_increased_difficulty")


func test_health_upgrades_use_health_color() -> void:
	assert_eq(hud._upgrade_color(_upgrade("heal", false)), Palette.HEALTH)
	assert_eq(hud._upgrade_color(_upgrade("stat_max_hp", false)), Palette.HEALTH)


## --- end-game screen ---

func test_game_over_panel_visible_on_player_died() -> void:
	EventBus.player_died.emit()
	assert_true(hud.game_over_panel.visible, "Game over panel must appear when player dies")


func test_death_title_on_game_ended_death() -> void:
	EventBus.game_ended.emit("death")
	assert_eq(hud.game_over_title.text, "GAME OVER")


func test_victory_title_on_game_ended_victory() -> void:
	EventBus.game_ended.emit("victory")
	assert_eq(hud.game_over_title.text, "VICTORY!")


func test_run_ended_title_on_voluntary_quit() -> void:
	EventBus.game_ended.emit("quit")
	assert_eq(hud.game_over_title.text, "RUN ENDED")


func test_summary_includes_chosen_upgrades() -> void:
	hud._on_upgrade_selected({"name": "+Laser", "type": "speed", "is_weapon": false})
	EventBus.game_ended.emit("death")
	assert_true(
		hud.game_over_summary.text.contains("+Laser"),
		"Summary must list upgrades chosen during the run"
	)


func test_game_over_panel_fits_inside_viewport() -> void:
	EventBus.player_died.emit()
	await get_tree().process_frame
	var rect: Rect2 = hud.game_over_panel.get_global_rect()
	var vp: Rect2 = Rect2(Vector2.ZERO, hud.game_over_panel.get_viewport_rect().size)
	assert_true(vp.encloses(rect),
		"Game over panel %s must fit inside viewport %s" % [rect, vp])


func test_game_over_panel_fits_with_long_upgrade_list() -> void:
	for i in range(10):
		hud._chosen_upgrades.append("+10% Fire Rate")
	EventBus.game_ended.emit("death")
	await get_tree().process_frame
	await get_tree().process_frame
	var rect: Rect2 = hud.game_over_panel.get_global_rect()
	var vp: Rect2 = Rect2(Vector2.ZERO, hud.game_over_panel.get_viewport_rect().size)
	assert_true(vp.encloses(rect),
		"Panel with a long upgrade list %s must still fit inside viewport %s" % [rect, vp])


func test_pause_panel_fits_inside_viewport() -> void:
	hud.pause_panel.show()
	await get_tree().process_frame
	var rect: Rect2 = hud.pause_panel.get_global_rect()
	var vp: Rect2 = Rect2(Vector2.ZERO, hud.pause_panel.get_viewport_rect().size)
	assert_true(vp.encloses(rect),
		"Pause panel %s must fit inside viewport %s" % [rect, vp])


func test_game_over_panel_has_play_again_button() -> void:
	assert_true(
		hud.play_again_btn is Button,
		"Game over panel must have a Play Again button"
	)


func test_play_again_button_is_wired() -> void:
	assert_true(
		hud.play_again_btn.pressed.is_connected(hud._on_play_again),
		"Play Again button must be connected to its handler"
	)


func test_summary_shows_score_line() -> void:
	EventBus.game_ended.emit("death")
	assert_true(
		hud.game_over_summary.text.contains("SCORE:"),
		"End-of-run summary must show the run score"
	)


func test_stats_label_shows_kill_count() -> void:
	var player := preload("res://scenes/player/player.tscn").instantiate()
	add_child_autofree(player)
	await get_tree().process_frame
	hud._player = player
	player.enemies_killed = 5
	hud._update_stats()
	assert_true(
		hud.stats_label.text.contains("5"),
		"Stats label must display the live kill count"
	)
