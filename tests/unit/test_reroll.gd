extends GutTest
## Tests for the Brotato-style reroll: re-shuffle the offered upgrades,
## limited uses per run.

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

var hud: CanvasLayer


func before_each() -> void:
	hud = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame


func after_each() -> void:
	get_tree().paused = false
	GameManager.current_state = GameManager.State.MENU


func _last_button() -> Button:
	return hud.upgrade_buttons.get_child(hud.upgrade_buttons.get_child_count() - 1)


func test_reroll_button_offered_with_uses_left() -> void:
	hud._show_upgrade_selection()
	assert_eq(hud.upgrade_buttons.get_child_count(), 4, "3 options + reroll")
	assert_true(_last_button().text.contains("REROLL"))


func test_reroll_decrements_and_reshuffles() -> void:
	hud._show_upgrade_selection()
	hud._on_reroll()
	assert_eq(hud._rerolls_left, hud.REROLLS_PER_RUN - 1)
	assert_true(hud.level_up_panel.visible, "Panel must stay open after reroll")
	assert_eq(hud.upgrade_buttons.get_child_count(), 4, "Options must be re-offered")


func test_no_reroll_button_when_exhausted() -> void:
	hud._rerolls_left = 0
	hud._show_upgrade_selection()
	assert_eq(hud.upgrade_buttons.get_child_count(), 3, "No reroll button at 0 uses")


func test_reroll_preserves_chest_multiplier() -> void:
	hud._show_upgrade_selection(3, 3)
	hud._on_reroll()
	assert_eq(hud._pending_multiplier, 3, "Reroll must not eat the chest x3")


func test_rerolls_reset_on_game_started() -> void:
	hud._rerolls_left = 0
	EventBus.game_started.emit()
	assert_eq(hud._rerolls_left, hud.REROLLS_PER_RUN)