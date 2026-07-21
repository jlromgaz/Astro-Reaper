extends GutTest
## Tests for the arcade initials entry panel (letter cycling and name output).

const PANEL_SCRIPT := preload("res://scripts/ui/name_entry_panel.gd")


func _make_panel() -> PanelContainer:
	var panel: PanelContainer = PANEL_SCRIPT.new()
	add_child_autofree(panel)
	return panel


func _action(name: String) -> InputEventAction:
	var ev := InputEventAction.new()
	ev.action = name
	ev.pressed = true
	return ev


func test_default_name_is_aaa() -> void:
	var panel := _make_panel()
	assert_eq(panel.get_player_name(), "AAA")


func test_cycle_up_advances_letter() -> void:
	var panel := _make_panel()
	panel.cycle(0, 1)
	assert_eq(panel.get_player_name(), "BAA")


func test_cycle_down_wraps_to_z() -> void:
	var panel := _make_panel()
	panel.cycle(1, -1)
	assert_eq(panel.get_player_name(), "AZA")


func test_cycle_up_wraps_past_z() -> void:
	var panel := _make_panel()
	for i in range(26):
		panel.cycle(2, 1)
	assert_eq(panel.get_player_name(), "AAA")


func test_cycle_updates_visible_label() -> void:
	var panel := _make_panel()
	panel.cycle(0, 2)
	var label: Label = panel._labels[0]
	assert_eq(label.text, "C")


func test_ok_emits_submitted_with_name() -> void:
	var panel := _make_panel()
	panel.cycle(0, 2)  # C
	watch_signals(panel)
	panel.submitted.emit(panel.get_player_name())
	assert_signal_emitted_with_parameters(panel, "submitted", ["CAA"])


## --- Keyboard/gamepad navigation (WASD works via the shared ui_* actions) ---

func test_ui_up_cycles_current_slot_letter() -> void:
	var panel := _make_panel()
	panel._unhandled_input(_action("ui_up"))
	assert_eq(panel.get_player_name(), "BAA")


func test_ui_down_wraps_current_slot_letter() -> void:
	var panel := _make_panel()
	panel._unhandled_input(_action("ui_down"))
	assert_eq(panel.get_player_name(), "ZAA")


func test_ui_right_moves_to_next_slot() -> void:
	var panel := _make_panel()
	panel._unhandled_input(_action("ui_right"))
	panel._unhandled_input(_action("ui_up"))
	assert_eq(panel.get_player_name(), "ABA", "Right must move focus to the second slot")


func test_ui_left_wraps_to_last_slot() -> void:
	var panel := _make_panel()
	panel._unhandled_input(_action("ui_left"))
	panel._unhandled_input(_action("ui_up"))
	assert_eq(panel.get_player_name(), "AAB", "Left from the first slot must wrap to the last")


func test_ui_accept_emits_submitted() -> void:
	var panel := _make_panel()
	watch_signals(panel)
	panel._unhandled_input(_action("ui_accept"))
	assert_signal_emitted_with_parameters(panel, "submitted", ["AAA"])


func test_hidden_panel_ignores_input() -> void:
	var panel := _make_panel()
	panel.hide()
	panel._unhandled_input(_action("ui_up"))
	assert_eq(panel.get_player_name(), "AAA", "A hidden panel must not react to input")


func test_showing_panel_resets_focus_to_first_slot() -> void:
	var panel := _make_panel()
	panel._unhandled_input(_action("ui_right"))
	panel.hide()
	panel.show()
	assert_eq(panel._current_slot, 0, "Reopening must reset keyboard focus to the first letter")


## --- Regression: double score submission ---
## OK/SKIP could receive engine focus like any Button. If focused, Godot's
## own BaseButton also activates on ui_accept — on top of the panel's own
## _unhandled_input handling of the same event — emitting `submitted` twice
## for a single Enter press (reported as scores being saved twice).
func test_ok_and_skip_buttons_never_take_focus() -> void:
	var panel := _make_panel()
	for child in panel.find_children("*", "Button", true, false):
		assert_eq(child.focus_mode, Control.FOCUS_NONE,
			"Button '%s' must not accept focus — keyboard input is handled explicitly" % child.text)
