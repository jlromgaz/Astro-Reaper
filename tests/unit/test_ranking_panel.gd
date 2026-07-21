extends GutTest
## Tests for the per-mode ranking panel rendering (populate/error/empty).

const PANEL_SCRIPT := preload("res://scripts/ui/ranking_panel.gd")


func _make_panel() -> PanelContainer:
	var panel: PanelContainer = PANEL_SCRIPT.new()
	add_child_autofree(panel)
	return panel


## Grid layout: 1 header row (COLUMN_HEADERS.size() cells) + 1 row per entry.
func _row_texts(panel: PanelContainer, row_index: int) -> Array[String]:
	var cols: int = panel.COLUMN_HEADERS.size()
	var start: int = cols + row_index * cols
	var out: Array[String] = []
	for i in range(cols):
		out.append(panel._grid.get_child(start + i).text)
	return out


func test_populate_lists_rows_in_order() -> void:
	var panel := _make_panel()
	panel.populate([
		{"name": "ACE", "score": 2950},
		{"name": "BOB", "score": 100},
	])
	assert_true(panel._grid.visible)
	assert_false(panel._list.visible)
	assert_eq(_row_texts(panel, 0).slice(0, 3), ["1", "ACE", "2950"])
	assert_eq(_row_texts(panel, 1).slice(0, 3), ["2", "BOB", "100"])


func test_populate_shows_run_stat_columns() -> void:
	var panel := _make_panel()
	panel.populate([
		{"name": "ACE", "score": 2950, "ship": "stellar", "run_time": 187.0, "kills": 42, "level": 9},
	])
	assert_eq(_row_texts(panel, 0), ["1", "ACE", "2950", "STE", "3:07", "42", "9"])


func test_populate_shows_placeholder_for_missing_run_stats() -> void:
	# Historical entries recorded before this feature carry none of these
	# fields — must show a clear placeholder, not a misleading zero.
	var panel := _make_panel()
	panel.populate([{"name": "OLD", "score": 100}])
	var cells: Array[String] = _row_texts(panel, 0)
	assert_eq(cells[3], panel.NO_DATA)
	assert_eq(cells[4], panel.NO_DATA)
	assert_eq(cells[5], panel.NO_DATA)
	assert_eq(cells[6], panel.NO_DATA)


func test_populate_empty_shows_empty_message() -> void:
	var panel := _make_panel()
	panel.populate([])
	assert_eq(panel._list.text, tr("RANKING_EMPTY"))
	assert_true(panel._list.visible)
	assert_false(panel._grid.visible)


func test_highlight_marks_own_entry() -> void:
	var panel := _make_panel()
	panel._highlight_name = "ACE"
	panel._highlight_score = 2950
	panel.populate([
		{"name": "ACE", "score": 2950},
		{"name": "ACE", "score": 50},
	])
	var cols: int = panel.COLUMN_HEADERS.size()
	var first_cell: Label = panel._grid.get_child(cols)
	var second_row_cell: Label = panel._grid.get_child(cols * 2)
	assert_eq(first_cell.get_theme_color("font_color"), Palette.UI_ACCENT)
	assert_eq(second_row_cell.get_theme_color("font_color"), Palette.UI_TEXT,
		"same name, other score must not highlight")


func test_fetch_failure_retries_once_then_shows_code() -> void:
	var panel := _make_panel()
	panel.show()
	Leaderboard.last_http_code = 400
	panel._on_top_fetched(false, [])
	assert_eq(panel._list.text, tr("LOADING"), "first failure must retry silently")
	panel._on_top_fetched(false, [])
	assert_string_contains(panel._list.text, "(400)",
		"the HTTP code must be visible so reports are diagnosable")


func test_mode_labels_cover_all_modes() -> void:
	for mode in PANEL_SCRIPT.MODES:
		assert_true(PANEL_SCRIPT.MODE_LABELS.has(mode), "missing label for %s" % mode)
