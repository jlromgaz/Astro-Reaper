extends GutTest
## Tests for the per-mode ranking panel rendering (populate/error/empty).

const PANEL_SCRIPT := preload("res://scripts/ui/ranking_panel.gd")


func _make_panel() -> PanelContainer:
	var panel: PanelContainer = PANEL_SCRIPT.new()
	add_child_autofree(panel)
	return panel


func test_populate_lists_rows_in_order() -> void:
	var panel := _make_panel()
	panel.populate([
		{"name": "ACE", "score": 2950},
		{"name": "BOB", "score": 100},
	])
	var text: String = panel._list.text
	assert_string_contains(text, "1. ACE  2950")
	assert_string_contains(text, "2. BOB  100")


func test_populate_empty_shows_empty_message() -> void:
	var panel := _make_panel()
	panel.populate([])
	assert_eq(panel._list.text, tr("RANKING_EMPTY"))


func test_highlight_marks_own_entry() -> void:
	var panel := _make_panel()
	panel._highlight_name = "ACE"
	panel._highlight_score = 2950
	panel.populate([
		{"name": "ACE", "score": 2950},
		{"name": "ACE", "score": 50},
	])
	var lines: PackedStringArray = panel._list.text.split("\n")
	assert_string_contains(lines[0], "<")
	assert_false(lines[1].contains("<"), "same name, other score must not highlight")


func test_mode_labels_cover_all_modes() -> void:
	for mode in PANEL_SCRIPT.MODES:
		assert_true(PANEL_SCRIPT.MODE_LABELS.has(mode), "missing label for %s" % mode)
