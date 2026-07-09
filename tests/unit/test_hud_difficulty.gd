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
