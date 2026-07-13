extends GutTest
## Tests for the arcade initials entry panel (letter cycling and name output).

const PANEL_SCRIPT := preload("res://scripts/ui/name_entry_panel.gd")


func _make_panel() -> PanelContainer:
	var panel: PanelContainer = PANEL_SCRIPT.new()
	add_child_autofree(panel)
	return panel


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
