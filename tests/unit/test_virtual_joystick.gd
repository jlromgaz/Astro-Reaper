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
