extends CanvasLayer
## Main Menu: two-screen flow. Page 0 selects the ship (up/down + Enter),
## page 1 picks the game mode from a flat list (up/down + Enter, ESC back).

const MODE_OPTIONS := [
	{"label": "CLASSIC — EASY", "mode": GameManager.GameMode.CLASSIC, "difficulty": GameManager.Difficulty.EASY},
	{"label": "CLASSIC — MEDIUM", "mode": GameManager.GameMode.CLASSIC, "difficulty": GameManager.Difficulty.MEDIUM},
	{"label": "CLASSIC — HARD", "mode": GameManager.GameMode.CLASSIC, "difficulty": GameManager.Difficulty.HARD},
	{"label": "ARCADE — ENDLESS", "mode": GameManager.GameMode.ARCADE, "difficulty": GameManager.Difficulty.MEDIUM},
]

@onready var title_label: Label = $VBox/TitleLabel
@onready var best_score_label: Label = $VBox/BestScoreLabel
@onready var lang_row: HBoxContainer = $VBox/LangRow
@onready var mode_list: VBoxContainer = $VBox/ModeList
@onready var mode_hint: Label = $VBox/ModeHint
@onready var subtitle_label: Label = $VBox/SubtitleLabel
@onready var ship_list: VBoxContainer = $VBox/ShipList
@onready var ship_info_panel: PanelContainer = $VBox/ShipInfoPanel
@onready var ship_name_label: Label = $VBox/ShipInfoPanel/InfoVBox/ShipNameLabel
@onready var ship_stats_label: Label = $VBox/ShipInfoPanel/InfoVBox/ShipStatsLabel
@onready var ship_passive_label: Label = $VBox/ShipInfoPanel/InfoVBox/ShipPassiveLabel
@onready var ship_desc_label: Label = $VBox/ShipInfoPanel/InfoVBox/ShipDescLabel
@onready var start_button: Button = $VBox/StartButton

var _ships: Array[ShipResource] = []
var _selected_index: int = 0
var _page: int = 0
var _mode_index: int = 1  # CLASSIC — MEDIUM by default


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_ships()
	_build_ship_buttons()
	_build_mode_buttons()
	start_button.text = "CONTINUE"
	start_button.focus_mode = Control.FOCUS_NONE
	start_button.pressed.connect(func() -> void: _goto_page(1))
	_setup_language_row()
	ship_info_panel.visible = false
	_set_best_score(ScoreManager.get_high_score())
	if _ships.size() > 0:
		_select_ship(0)
	_goto_page(0)


func _goto_page(page: int) -> void:
	_page = page
	var on_ships := page == 0
	ship_list.visible = on_ships
	ship_info_panel.visible = on_ships and _ships.size() > 0
	subtitle_label.visible = on_ships
	start_button.visible = on_ships
	mode_list.visible = not on_ships
	mode_hint.visible = not on_ships
	if not on_ships:
		_select_mode_option(_mode_index)


func _build_mode_buttons() -> void:
	for child in mode_list.get_children():
		child.queue_free()
	for i in range(MODE_OPTIONS.size()):
		var btn := Button.new()
		btn.text = MODE_OPTIONS[i].label
		btn.custom_minimum_size = Vector2(340, 66)
		btn.add_theme_font_size_override("font_size", 21)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_mode_clicked.bind(i))
		mode_list.add_child(btn)


func _on_mode_clicked(index: int) -> void:
	_select_mode_option(index)
	_launch_game()


func _select_mode_option(index: int) -> void:
	_mode_index = index
	for i in range(mode_list.get_child_count()):
		var btn := mode_list.get_child(i) as Button
		if btn:
			btn.add_theme_color_override("font_color", Color.YELLOW if i == index else Color.WHITE)


func _apply_mode_option(index: int) -> void:
	GameManager.game_mode = MODE_OPTIONS[index].mode
	GameManager.difficulty = MODE_OPTIONS[index].difficulty


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
	_set_best_score(ScoreManager.get_high_score())  # refresh composed text


func _highlight_language(code: String) -> void:
	for btn: Button in lang_row.get_children():
		var active: bool = btn.text.to_lower() == code
		btn.add_theme_color_override("font_color", Color.YELLOW if active else Color.WHITE)


func _set_best_score(high: int) -> void:
	best_score_label.visible = high > 0
	best_score_label.text = "%s: %d" % [tr("BEST"), high]


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
		btn.text = _ships[i].ship_name
		btn.custom_minimum_size = Vector2(340, 64)
		btn.add_theme_font_size_override("font_size", 21)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_select_ship.bind(i))
		ship_list.add_child(btn)


func _select_ship(index: int) -> void:
	_selected_index = index
	var ship := _ships[index]
	ship_info_panel.visible = true
	ship_name_label.text = ship.ship_name
	ship_stats_label.text = "HP: %.0f | SPD: %.0f | DMG: x%.1f | FR: x%.1f" % [
		ship.base_hp, ship.base_speed, ship.base_damage_mult, ship.base_fire_rate_mult
	]
	ship_passive_label.text = "%s: %s" % [ship.passive_name, ship.passive_description]
	ship_desc_label.text = ship.description

	# Highlight selected button
	for i in range(ship_list.get_child_count()):
		var btn = ship_list.get_child(i) as Button
		if btn:
			btn.add_theme_color_override("font_color", Color.YELLOW if i == index else Color.WHITE)


func _unhandled_input(event: InputEvent) -> void:
	if _ships.is_empty():
		return
	if _page == 0:
		if event.is_action_pressed("ui_down"):
			_select_ship((_selected_index + 1) % _ships.size())
		elif event.is_action_pressed("ui_up"):
			_select_ship((_selected_index - 1 + _ships.size()) % _ships.size())
		elif event.is_action_pressed("ui_accept"):
			_goto_page(1)
	else:
		if event.is_action_pressed("ui_down"):
			_select_mode_option((_mode_index + 1) % MODE_OPTIONS.size())
		elif event.is_action_pressed("ui_up"):
			_select_mode_option((_mode_index - 1 + MODE_OPTIONS.size()) % MODE_OPTIONS.size())
		elif event.is_action_pressed("ui_cancel"):
			_goto_page(0)
		elif event.is_action_pressed("ui_accept"):
			_launch_game()


func _launch_game() -> void:
	if _ships.is_empty():
		return
	_apply_mode_option(_mode_index)
	var ship := _ships[_selected_index]
	GameManager.select_ship(ship)
	DebugLog.log_info("MENU", "Starting %s (%s) with ship: %s" % [
		GameManager.mode_name(), GameManager.difficulty_name(), ship.ship_name
	])
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
