extends GutTest
## Tests for full keyboard navigation: menu ship selector, upgrade selection
## focus, and end-game/pause panel focus.

const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func after_each() -> void:
	get_tree().paused = false
	GameManager.current_state = GameManager.State.MENU


func _action(name: String) -> InputEventAction:
	var ev := InputEventAction.new()
	ev.action = name
	ev.pressed = true
	return ev


## --- Main menu ship selector ---

func test_arrow_down_selects_next_ship() -> void:
	var menu: CanvasLayer = add_child_autofree(MENU_SCENE.instantiate())
	await get_tree().process_frame
	menu._unhandled_input(_action("ui_down"))
	assert_eq(menu._selected_index, 1, "Down arrow must move to the next ship")


func test_arrow_up_wraps_to_last_ship() -> void:
	var menu: CanvasLayer = add_child_autofree(MENU_SCENE.instantiate())
	await get_tree().process_frame
	menu._unhandled_input(_action("ui_up"))
	assert_eq(menu._selected_index, menu._ships.size() - 1,
		"Up arrow from the first ship must wrap to the last")


func test_ship_buttons_do_not_steal_focus() -> void:
	var menu: CanvasLayer = add_child_autofree(MENU_SCENE.instantiate())
	await get_tree().process_frame
	for btn in menu.ship_list.get_children():
		assert_eq(btn.focus_mode, Control.FOCUS_NONE,
			"Ship buttons must not hijack arrow keys from the custom selector")


func test_enter_with_no_ships_does_not_crash() -> void:
	var menu: CanvasLayer = add_child_autofree(MENU_SCENE.instantiate())
	await get_tree().process_frame
	menu._ships.clear()
	menu._unhandled_input(_action("ui_accept"))
	assert_true(is_instance_valid(menu), "Enter with empty ship list must be a no-op")


## --- Upgrade selection focus ---

func test_first_upgrade_button_grabs_focus() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	hud._show_upgrade_selection()
	await get_tree().process_frame
	var first: Button = hud.upgrade_buttons.get_child(0)
	assert_true(first.has_focus(),
		"First upgrade option must be focused so arrows+Enter work")


func test_focus_works_on_second_level_up() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	hud._show_upgrade_selection()
	await get_tree().process_frame
	# Second level-up in the same run — old buttons must not steal get_child(0)
	hud._show_upgrade_selection()
	await get_tree().process_frame
	var first: Button = hud.upgrade_buttons.get_child(0)
	assert_true(is_instance_valid(first) and not first.is_queued_for_deletion(),
		"get_child(0) must be a fresh button, not a dying one")
	assert_true(first.has_focus(),
		"Keyboard focus must work on EVERY level-up, not just the first")


## --- End-game and pause panels ---

func test_play_again_grabs_focus_on_game_over() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	EventBus.game_ended.emit("death")
	await get_tree().process_frame
	assert_true(hud.play_again_btn.has_focus(),
		"Play Again must be focused when the end panel opens")


func test_resume_grabs_focus_on_pause() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	GameManager.current_state = GameManager.State.PLAYING
	hud._on_pause_toggle()
	await get_tree().process_frame
	assert_true(hud.resume_btn.has_focus(),
		"Resume must be focused when the pause panel opens")