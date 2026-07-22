extends GutTest
## Integration tests: virtual joystick must use circular drawn visuals,
## not ColorRect squares, while keeping the Control-based drag logic.

## Capture box: lambdas can't mutate outer Vector2 locals, but they can
## mutate an Object's property (Object = reference type).
class DirectionCapture:
	var value := Vector2.ZERO


func test_joystick_base_and_knob_are_not_colorrects() -> void:
	var joystick: Node = add_child_autofree(load("res://scenes/ui/virtual_joystick.tscn").instantiate())
	var base: Node = joystick.get_node("Base")
	var knob: Node = joystick.get_node("Knob")
	assert_false(base is ColorRect, "Base must not be a ColorRect square")
	assert_false(knob is ColorRect, "Knob must not be a ColorRect square")
	assert_true(base is Control, "Base must remain a Control for get_global_rect()")
	assert_true(knob is Control, "Knob must remain a Control for position/size logic")


func test_joystick_visuals_use_palette_accent() -> void:
	var joystick: Node = add_child_autofree(load("res://scenes/ui/virtual_joystick.tscn").instantiate())
	var base: Control = joystick.get_node("Base")
	var knob: Control = joystick.get_node("Knob")
	assert_eq(base.ring_color, Color(Palette.UI_ACCENT, 0.35), "Base ring must be dim accent")
	assert_eq(knob.ring_color, Color(Palette.UI_ACCENT, 0.85), "Knob must be bright accent")


func test_joystick_base_and_knob_hidden_at_start() -> void:
	var js: Control = add_child_autofree(load("res://scenes/ui/virtual_joystick.tscn").instantiate())
	await get_tree().process_frame
	var base: Control = js.get_node("Base")
	var knob: Control = js.get_node("Knob")
	assert_false(base.visible, "Base must be hidden at rest")
	assert_false(knob.visible, "Knob must be hidden at rest")


func test_show_at_positions_base_without_revealing_it() -> void:
	# By request: steering must work fully, but the two rings must never
	# actually render on screen, even while actively dragging.
	var js: Control = add_child_autofree(load("res://scenes/ui/virtual_joystick.tscn").instantiate())
	await get_tree().process_frame
	js._show_at(Vector2(300.0, 400.0))
	var base: Control = js.get_node("Base")
	assert_false(base.visible, "Base must stay invisible even while dragging")
	var base_center := base.position + base.size / 2.0
	assert_almost_eq(base_center.x, 300.0, 1.0, "Base still centered at touch X (positioning logic unchanged)")
	assert_almost_eq(base_center.y, 400.0, 1.0, "Base still centered at touch Y (positioning logic unchanged)")


func test_hide_conceals_both_rings() -> void:
	var js: Control = add_child_autofree(load("res://scenes/ui/virtual_joystick.tscn").instantiate())
	await get_tree().process_frame
	js._show_at(Vector2(300.0, 400.0))
	js._hide()
	assert_false(js.get_node("Base").visible, "Base hidden after _hide")
	assert_false(js.get_node("Knob").visible, "Knob hidden after _hide")


func test_direction_drag_up_emits_negative_y() -> void:
	var js: Control = add_child_autofree(load("res://scenes/ui/virtual_joystick.tscn").instantiate())
	await get_tree().process_frame
	js._base_center = Vector2(110.0, 110.0)
	var cap := DirectionCapture.new()
	js.input_changed.connect(func(d: Vector2) -> void: cap.value = d)
	js._update_knob(Vector2(110.0, 30.0))  # 80px above center
	assert_lt(cap.value.y, -0.5, "Dragging up must produce negative Y")
	assert_almost_eq(cap.value.x, 0.0, 0.1, "No horizontal component when dragging straight up")


func test_direction_drag_right_emits_positive_x() -> void:
	var js: Control = add_child_autofree(load("res://scenes/ui/virtual_joystick.tscn").instantiate())
	await get_tree().process_frame
	js._base_center = Vector2(110.0, 110.0)
	var cap := DirectionCapture.new()
	js.input_changed.connect(func(d: Vector2) -> void: cap.value = d)
	js._update_knob(Vector2(190.0, 110.0))  # 80px to the right
	assert_gt(cap.value.x, 0.5, "Dragging right must produce positive X")
	assert_almost_eq(cap.value.y, 0.0, 0.1, "No vertical component when dragging straight right")


func test_deadzone_swallows_tiny_movement() -> void:
	var js: Control = add_child_autofree(load("res://scenes/ui/virtual_joystick.tscn").instantiate())
	await get_tree().process_frame
	js._base_center = Vector2(110.0, 110.0)
	var cap := DirectionCapture.new()
	cap.value = Vector2(99.0, 99.0)  # sentinel — must become ZERO
	js.input_changed.connect(func(d: Vector2) -> void: cap.value = d)
	js._update_knob(Vector2(111.0, 110.3))  # ~1px nudge — inside deadzone (DEADZONE=0.06, range=30 → threshold=1.8px)
	assert_eq(cap.value, Vector2.ZERO, "Tiny movement inside deadzone must emit zero")


func test_magnitude_never_exceeds_one() -> void:
	var js: Control = add_child_autofree(load("res://scenes/ui/virtual_joystick.tscn").instantiate())
	await get_tree().process_frame
	js._base_center = Vector2(110.0, 110.0)
	var cap := DirectionCapture.new()
	js.input_changed.connect(func(d: Vector2) -> void: cap.value = d)
	js._update_knob(Vector2(610.0, 610.0))  # way beyond KNOB_RANGE
	assert_lte(cap.value.length(), 1.0, "Output magnitude must never exceed 1.0")
