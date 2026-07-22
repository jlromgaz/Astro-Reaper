extends GutTest
## Regression tests for the game-over touch bug: joystick visuals must never
## consume GUI events, and a run ending must release any active drag.

const JOYSTICK_SCENE := preload("res://scenes/ui/virtual_joystick.tscn")


func test_root_and_visuals_ignore_mouse() -> void:
	# STOP-filter visuals on the top CanvasLayer swallowed taps aimed at the
	# game-over buttons — every joystick Control must be IGNORE.
	var joystick: Control = autofree(JOYSTICK_SCENE.instantiate())
	assert_eq(joystick.mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(joystick.get_node("Base").mouse_filter, Control.MOUSE_FILTER_IGNORE)
	assert_eq(joystick.get_node("Knob").mouse_filter, Control.MOUSE_FILTER_IGNORE)


## User request: keep steering fully working, but never show the two blue
## rings on screen (base + knob), even while actively dragging.
func test_joystick_visuals_never_show_even_while_dragging() -> void:
	var joystick: Control = add_child_autofree(JOYSTICK_SCENE.instantiate())
	await get_tree().process_frame
	joystick._show_at(Vector2(100, 100))
	assert_false(joystick.get_node("Base").visible, "Base ring must stay invisible while dragging")
	assert_false(joystick.get_node("Knob").visible, "Knob must stay invisible while dragging")


func test_joystick_still_reports_input_direction_while_invisible() -> void:
	var joystick: Control = add_child_autofree(JOYSTICK_SCENE.instantiate())
	await get_tree().process_frame
	joystick._show_at(Vector2(100, 100))
	watch_signals(joystick)
	joystick._update_knob(Vector2(130, 100))
	assert_signal_emitted(joystick, "input_changed")
	var args: Array = get_signal_parameters(joystick, "input_changed", 0)
	var dir: Vector2 = args[0]
	assert_gt(dir.x, 0.0, "steering must still work even though the rings are hidden")


func test_game_ended_force_releases_drag() -> void:
	var joystick: Control = JOYSTICK_SCENE.instantiate()
	add_child_autofree(joystick)
	await get_tree().process_frame
	joystick._show_at(Vector2(100, 100))
	joystick._dragging = true
	joystick._touch_index = 0
	EventBus.game_ended.emit("death")
	assert_false(joystick._dragging, "game_ended must release an active drag")
	assert_eq(joystick._touch_index, -1)
	assert_false(joystick.get_node("Base").visible, "visuals must hide on game over")
	GameManager.current_state = GameManager.State.MENU
	get_tree().paused = false
