extends GutTest
## main.gd's keyboard polling must never stomp joystick input.
##
## Mobile-web bug: OS.get_name() returns "Web" in a phone browser (never
## "Android"/"iOS"), so the old platform check let the keyboard fallback
## run on mobile — writing set_move_input(ZERO) every frame and erasing
## the joystick's held direction between drag events. Ships only moved
## while the finger was actively moving ("tironea y se para"), and only
## the 170-speed Interceptor was fast enough to mask it.

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

const MOVE_ACTIONS := ["move_up", "move_down", "move_left", "move_right"]


func after_each() -> void:
	for action in MOVE_ACTIONS:
		Input.action_release(action)
	get_tree().paused = false
	GameManager.current_state = GameManager.State.MENU


func _make_main() -> Node2D:
	var m: Node2D = add_child_autofree(MAIN_SCENE.instantiate())
	await get_tree().process_frame
	return m


func test_idle_keyboard_never_stomps_a_held_joystick_direction() -> void:
	var m := await _make_main()
	m.player.set_move_input(Vector2.RIGHT)  # joystick finger held still
	m._process(1.0 / 60.0)
	assert_eq(m.player._move_input, Vector2.RIGHT,
		"a frame with no keys pressed must leave the joystick's input untouched")


func test_pressed_keys_still_drive_movement() -> void:
	var m := await _make_main()
	Input.action_press("move_right")
	m._process(1.0 / 60.0)
	assert_eq(m.player._move_input, Vector2.RIGHT, "keyboard must still steer on desktop")


func test_releasing_all_keys_stops_the_ship() -> void:
	var m := await _make_main()
	Input.action_press("move_right")
	m._process(1.0 / 60.0)
	Input.action_release("move_right")
	m._process(1.0 / 60.0)
	assert_eq(m.player._move_input, Vector2.ZERO,
		"the release transition must write one zero so the ship stops on desktop")
