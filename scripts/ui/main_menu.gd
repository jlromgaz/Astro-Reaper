extends CanvasLayer
## Main Menu: single ship-select page (up/down + Enter). Only Arcade —
## Endless is offered; selecting a ship launches straight into it.

@onready var title_label: Label = $VBox/TitleLabel
@onready var best_score_label: Label = $VBox/BestScoreLabel
@onready var lang_row: HBoxContainer = $VBox/LangRow
@onready var mode_list: VBoxContainer = $VBox/ModeList
@onready var mode_hint: Label = $VBox/ModeHint
@onready var subtitle_label: Label = $VBox/SubtitleLabel
@onready var ship_list: VBoxContainer = $VBox/ShipList
@onready var ship_info_panel: PanelContainer = $VBox/ShipInfoPanel
@onready var ship_name_label: Label = $VBox/ShipInfoPanel/InfoHBox/InfoVBox/ShipNameLabel
@onready var ship_stats_label: Label = $VBox/ShipInfoPanel/InfoHBox/InfoVBox/ShipStatsLabel
@onready var ship_passive_label: Label = $VBox/ShipInfoPanel/InfoHBox/InfoVBox/ShipPassiveLabel
@onready var ship_desc_label: Label = $VBox/ShipInfoPanel/InfoHBox/InfoVBox/ShipDescLabel
@onready var ship_preview: Control = $VBox/ShipInfoPanel/InfoHBox/ShipPreview
@onready var start_button: Button = $VBox/StartButton
@onready var ranking_button: Button = $VBox/RankingBtn
@onready var ranking_panel: PanelContainer = $RankingPanel

var _ships: Array[ShipResource] = []
var _selected_index: int = 0
var _global_best_score: int = -1
var _global_best_name: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_ships()
	_build_ship_buttons()
	start_button.text = "CONTINUE"
	start_button.focus_mode = Control.FOCUS_NONE
	start_button.pressed.connect(_launch_game)
	ranking_button.focus_mode = Control.FOCUS_NONE
	ranking_button.pressed.connect(_open_ranking)
	ranking_panel.closed.connect(func() -> void: ranking_panel.hide())
	_setup_language_row()
	mode_list.visible = false
	mode_hint.visible = false
	ship_info_panel.visible = false
	# BEST must reflect the actual global leaderboard, not the local
	# per-device high score — a run that was never saved must never show
	# up here, since that's exactly what it wouldn't show in the ranking.
	best_score_label.visible = false
	Leaderboard.top_fetched.connect(_on_global_best_fetched)
	Leaderboard.fetch_top("arcade")
	if _ships.size() > 0:
		_select_ship(0)


func _setup_language_row() -> void:
	# Mouse/touch only — deliberately outside the keyboard flow.
	var codes := {"EnBtn": "en", "EsBtn": "es"}
	for btn: Button in lang_row.get_children():
		btn.focus_mode = Control.FOCUS_NONE
		var code: String = codes.get(btn.name, "en")
		btn.pressed.connect(_on_language_selected.bind(code))
	_highlight_language(Settings.get_language())


func _on_language_selected(code: String) -> void:
	Settings.set_language(code)
	_highlight_language(code)
	if _global_best_score > 0:
		_set_best_score(_global_best_score, _global_best_name)  # refresh composed text


func _highlight_language(code: String) -> void:
	for btn: Button in lang_row.get_children():
		var active: bool = btn.text.to_lower() == code
		btn.add_theme_color_override("font_color", Color.YELLOW if active else Color.WHITE)


func _on_global_best_fetched(ok: bool, rows: Array) -> void:
	if not ok or rows.is_empty():
		return
	_global_best_score = int(rows[0].get("score", 0))
	_global_best_name = str(rows[0].get("name", "???"))
	_set_best_score(_global_best_score, _global_best_name)


func _set_best_score(score: int, entry_name: String) -> void:
	best_score_label.visible = score > 0
	best_score_label.text = "%s: %d (%s)" % [tr("BEST"), score, entry_name]


func _load_ships() -> void:
	var ship_paths := [
		"res://data/ships/ship_stellar.tres",
		"res://data/ships/ship_vanguard.tres",
		"res://data/ships/ship_interceptor.tres",
		"res://data/ships/ship_phantom.tres",
	]
	for path in ship_paths:
		var res = load(path)
		if res is ShipResource:
			_ships.append(res)
	DebugLog.log_info("MENU", "Loaded %d ships" % _ships.size())


func _build_ship_buttons() -> void:
	for child in ship_list.get_children():
		child.queue_free()

	for i in range(_ships.size()):
		var btn := Button.new()
		btn.text = tr("SHIP_%s_NAME" % _ships[i].ship_id.to_upper())
		btn.custom_minimum_size = Vector2(300, 26)
		btn.add_theme_font_size_override("font_size", 11)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_select_ship.bind(i))
		ship_list.add_child(btn)


func _select_ship(index: int) -> void:
	_selected_index = index
	var ship := _ships[index]
	var key := "SHIP_%s" % ship.ship_id.to_upper()
	ship_info_panel.visible = true
	ship_name_label.text = tr("%s_NAME" % key)
	ship_stats_label.text = "HP: %.0f | SPD: %.0f | DMG: x%.1f | FR: x%.1f" % [
		ship.base_hp, ship.base_speed, ship.base_damage_mult, ship.base_fire_rate_mult
	]
	ship_passive_label.text = "%s: %s" % [tr("%s_PASSIVE_NAME" % key), tr("%s_PASSIVE_DESC" % key)]
	ship_desc_label.text = tr("%s_DESC" % key)
	ship_preview.set_ship(ship.ship_id)

	# Highlight selected button
	for i in range(ship_list.get_child_count()):
		var btn = ship_list.get_child(i) as Button
		if btn:
			btn.add_theme_color_override("font_color", Color.YELLOW if i == index else Color.WHITE)


func _open_ranking() -> void:
	ranking_panel.open("arcade")


func _unhandled_input(event: InputEvent) -> void:
	if ranking_panel.visible:
		if event.is_action_pressed("ui_cancel"):
			ranking_panel.hide()
		return
	if _ships.is_empty():
		return
	if event.is_action_pressed("ui_down"):
		_select_ship((_selected_index + 1) % _ships.size())
	elif event.is_action_pressed("ui_up"):
		_select_ship((_selected_index - 1 + _ships.size()) % _ships.size())
	elif event.is_action_pressed("ui_accept"):
		_launch_game()


## Pure state setup, kept separate from _launch_game() so tests can verify
## it without triggering the actual scene change.
func _prepare_arcade_launch() -> void:
	GameManager.game_mode = GameManager.GameMode.ARCADE
	GameManager.difficulty = GameManager.Difficulty.MEDIUM


func _launch_game() -> void:
	if _ships.is_empty():
		return
	_prepare_arcade_launch()
	var ship := _ships[_selected_index]
	GameManager.select_ship(ship)
	DebugLog.log_info("MENU", "Starting %s with ship: %s" % [GameManager.mode_name(), ship.ship_name])
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
