extends PanelContainer
## Global top-10 ranking for Arcade — Endless, the game's only mode.
## Builds its UI in code so unit tests can drive populate()/show_error().

signal closed

const MODES: Array[String] = ["arcade"]
const MODE_LABELS := {
	"arcade": "ARCADE — ENDLESS",
}
const COLUMN_HEADERS := ["#", "NAME", "SCORE", "SHIP", "TIME", "KILLS", "LVL"]
const NO_DATA := "—"

var _mode_index := 0
var _highlight_name := ""
var _highlight_score := -1
var _retry_left := 1
var _mode_label: Label
var _list: Label
var _grid: GridContainer


func _ready() -> void:
	Leaderboard.top_fetched.connect(_on_top_fetched)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	add_child(vbox)

	var title := Label.new()
	title.text = tr("RANKING")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Palette.UI_ACCENT)
	title.add_theme_font_size_override("font_size", 12)
	vbox.add_child(title)

	var mode_row := HBoxContainer.new()
	mode_row.alignment = BoxContainer.ALIGNMENT_CENTER
	mode_row.add_theme_constant_override("separation", 8)
	vbox.add_child(mode_row)

	var prev_btn := Button.new()
	prev_btn.text = "<"
	prev_btn.custom_minimum_size = Vector2(30, 24)
	prev_btn.focus_mode = Control.FOCUS_NONE
	prev_btn.visible = MODES.size() > 1
	prev_btn.pressed.connect(_on_cycle.bind(-1))
	mode_row.add_child(prev_btn)

	_mode_label = Label.new()
	_mode_label.custom_minimum_size = Vector2(150, 0)
	_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mode_label.add_theme_color_override("font_color", Palette.UPGRADE_STAT)
	_mode_label.add_theme_font_size_override("font_size", 11)
	mode_row.add_child(_mode_label)

	var next_btn := Button.new()
	next_btn.text = ">"
	next_btn.custom_minimum_size = Vector2(30, 24)
	next_btn.focus_mode = Control.FOCUS_NONE
	next_btn.visible = MODES.size() > 1
	next_btn.pressed.connect(_on_cycle.bind(1))
	mode_row.add_child(next_btn)

	_list = Label.new()
	_list.text = tr("LOADING")
	_list.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_list.add_theme_color_override("font_color", Palette.UI_TEXT)
	_list.add_theme_font_size_override("font_size", 11)
	_list.custom_minimum_size = Vector2(320, 110)
	vbox.add_child(_list)

	_grid = GridContainer.new()
	_grid.columns = COLUMN_HEADERS.size()
	_grid.add_theme_constant_override("h_separation", 10)
	_grid.add_theme_constant_override("v_separation", 3)
	_grid.visible = false
	vbox.add_child(_grid)
	for header in COLUMN_HEADERS:
		var h := Label.new()
		h.text = header
		h.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		h.add_theme_color_override("font_color", Palette.UPGRADE_STAT)
		h.add_theme_font_size_override("font_size", 9)
		_grid.add_child(h)

	var close_btn := Button.new()
	close_btn.text = tr("CONTINUE")
	close_btn.custom_minimum_size = Vector2(120, 26)
	close_btn.add_theme_font_size_override("font_size", 12)
	close_btn.pressed.connect(func() -> void: closed.emit())
	vbox.add_child(close_btn)


## Opens the panel on a mode bucket. fetch=false leaves it in the loading
## state so the host can trigger refresh() later (e.g. after a submit).
func open(mode: String, hl_name: String = "", hl_score: int = -1, fetch: bool = true) -> void:
	_mode_index = maxi(0, MODES.find(mode))
	_highlight_name = hl_name
	_highlight_score = hl_score
	_retry_left = 1
	show()
	_update_mode_label()
	show_loading()
	if fetch:
		refresh()


func refresh() -> void:
	show_loading()
	Leaderboard.fetch_top(MODES[_mode_index])


func _on_cycle(delta: int) -> void:
	_mode_index = posmod(_mode_index + delta, MODES.size())
	_retry_left = 1
	_update_mode_label()
	refresh()


func _update_mode_label() -> void:
	_mode_label.text = tr(MODE_LABELS[MODES[_mode_index]])


func _on_top_fetched(ok: bool, rows: Array) -> void:
	if not visible:
		return
	if ok:
		populate(rows)
		return
	# One silent retry covers transient blips (e.g. an index warming up)
	if _retry_left > 0:
		_retry_left -= 1
		get_tree().create_timer(1.5).timeout.connect(refresh)
		return
	show_error()


func show_loading() -> void:
	_grid.visible = false
	_list.visible = true
	_list.text = tr("LOADING")


func show_error() -> void:
	# The HTTP code turns a vague failure into a diagnosable report
	_grid.visible = false
	_list.visible = true
	_list.text = "%s (%d)" % [tr("RANKING_ERROR"), Leaderboard.last_http_code]


func populate(rows: Array) -> void:
	if rows.is_empty():
		_grid.visible = false
		_list.visible = true
		_list.text = tr("RANKING_EMPTY")
		return
	_list.visible = false
	_grid.visible = true
	_clear_data_rows()
	for i in range(rows.size()):
		var row: Dictionary = rows[i]
		var is_hl: bool = row.get("name", "") == _highlight_name and row.get("score", -2) == _highlight_score
		_add_row(i + 1, row, is_hl)


func _clear_data_rows() -> void:
	while _grid.get_child_count() > COLUMN_HEADERS.size():
		var child: Node = _grid.get_child(_grid.get_child_count() - 1)
		_grid.remove_child(child)
		child.queue_free()


func _add_row(rank: int, row: Dictionary, is_highlight: bool) -> void:
	var ship_id: String = str(row.get("ship", ""))
	var ship_code: String = ship_id.substr(0, 3).to_upper() if row.has("ship") and ship_id != "" else NO_DATA
	var values: Array[String] = [
		str(rank),
		str(row.get("name", "???")),
		str(row.get("score", 0)),
		ship_code,
		_format_time(row.run_time) if row.has("run_time") else NO_DATA,
		str(row.kills) if row.has("kills") else NO_DATA,
		str(row.level) if row.has("level") else NO_DATA,
	]
	for value in values:
		var cell := Label.new()
		cell.text = value
		cell.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell.add_theme_font_size_override("font_size", 10)
		cell.add_theme_color_override(
			"font_color", Palette.UI_ACCENT if is_highlight else Palette.UI_TEXT
		)
		_grid.add_child(cell)


func _format_time(seconds: float) -> String:
	var total: int = int(seconds)
	return "%d:%02d" % [total / 60, total % 60]
