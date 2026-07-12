extends GutTest
## Tests for HUD difficulty_bump wiring and end-game screen correctness.

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

var hud: CanvasLayer


func before_each() -> void:
	hud = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame


## --- difficulty_bump wiring ---

func test_difficulty_bump_emitted_on_upgrade_selection() -> void:
	watch_signals(EventBus)
	hud._on_upgrade_selected({"name": "Heal", "type": "heal", "is_weapon": false})
	assert_signal_emitted(EventBus, "difficulty_bump")


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
