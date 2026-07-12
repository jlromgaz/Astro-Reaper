extends GutTest
## Integration tests: virtual joystick must use circular drawn visuals,
## not ColorRect squares, while keeping the Control-based drag logic.


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
