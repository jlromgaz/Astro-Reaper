extends CanvasLayer
## Main Menu: Entry point. Ship selection and game start.

@onready var title_label: Label = $VBox/TitleLabel
@onready var best_score_label: Label = $VBox/BestScoreLabel
@onready var mode_row: HBoxContainer = $VBox/ModeRow
@onready var classic_btn: Button = $VBox/ModeRow/ClassicBtn
@onready var arcade_btn: Button = $VBox/ModeRow/ArcadeBtn
@onready var diff_row: HBoxContainer = $VBox/DiffRow
@onready var easy_btn: Button = $VBox/DiffRow/EasyBtn
@onready var medium_btn: Button = $VBox/DiffRow/MediumBtn
@onready var hard_btn: Button = $VBox/DiffRow/HardBtn
@onready var ship_list: VBoxContainer = $VBox/ShipList
@onready var ship_info_panel: PanelContainer = $VBox/ShipInfoPanel
@onready var ship_name_label: Label = $VBox/ShipInfoPanel/InfoVBox/ShipNameLabel
@onready var ship_stats_label: Label = $VBox/ShipInfoPanel/InfoVBox/ShipStatsLabel
@onready var ship_passive_label: Label = $VBox/ShipInfoPanel/InfoVBox/ShipPassiveLabel
@onready var ship_desc_label: Label = $VBox/ShipInfoPanel/InfoVBox/ShipDescLabel
@onready var start_button: Button = $VBox/StartButton

var _ships: Array[ShipResource] = []
var _selected_index: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_ships()
	_build_ship_buttons()
	start_button.pressed.connect(_on_start_pressed)
	ship_info_panel.visible = false
	_set_best_score(ScoreManager.get_high_score())
	for btn: Button in [classic_btn, arcade_btn, easy_btn, medium_btn, hard_btn, start_button]:
		btn.focus_mode = Control.FOCUS_NONE
	classic_btn.pressed.connect(_select_mode.bind(GameManager.GameMode.CLASSIC))
	arcade_btn.pressed.connect(_select_mode.bind(GameManager.GameMode.ARCADE))
	easy_btn.pressed.connect(_select_difficulty.bind(GameManager.Difficulty.EASY))
	medium_btn.pressed.connect(_select_difficulty.bind(GameManager.Difficulty.MEDIUM))
	hard_btn.pressed.connect(_select_difficulty.bind(GameManager.Difficulty.HARD))
	_select_mode(GameManager.game_mode)
	_select_difficulty(GameManager.difficulty)
	if _ships.size() > 0:
		_select_ship(0)


func _select_mode(mode: GameManager.GameMode) -> void:
	GameManager.game_mode = mode
	diff_row.visible = mode == GameManager.GameMode.CLASSIC
	_highlight(classic_btn, mode == GameManager.GameMode.CLASSIC)
	_highlight(arcade_btn, mode == GameManager.GameMode.ARCADE)


func _select_difficulty(diff: GameManager.Difficulty) -> void:
	GameManager.difficulty = diff
	_highlight(easy_btn, diff == GameManager.Difficulty.EASY)
	_highlight(medium_btn, diff == GameManager.Difficulty.MEDIUM)
	_highlight(hard_btn, diff == GameManager.Difficulty.HARD)


func _highlight(btn: Button, active: bool) -> void:
	btn.add_theme_color_override("font_color", Color.YELLOW if active else Color.WHITE)


func _set_best_score(high: int) -> void:
	best_score_label.visible = high > 0
	best_score_label.text = "BEST: %d" % high


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
		btn.custom_minimum_size = Vector2(200, 40)
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
	if event.is_action_pressed("ui_down"):
		_select_ship((_selected_index + 1) % _ships.size())
	elif event.is_action_pressed("ui_up"):
		_select_ship((_selected_index - 1 + _ships.size()) % _ships.size())
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_right"):
		var other := GameManager.GameMode.ARCADE \
			if GameManager.game_mode == GameManager.GameMode.CLASSIC \
			else GameManager.GameMode.CLASSIC
		_select_mode(other)
	elif event.is_action_pressed("ui_accept"):
		_on_start_pressed()
	elif event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1: _select_difficulty(GameManager.Difficulty.EASY)
			KEY_2: _select_difficulty(GameManager.Difficulty.MEDIUM)
			KEY_3: _select_difficulty(GameManager.Difficulty.HARD)


func _on_start_pressed() -> void:
	if _ships.is_empty():
		return
	var ship := _ships[_selected_index]
	GameManager.select_ship(ship)
	DebugLog.log_info("MENU", "Starting game with ship: %s" % ship.ship_name)
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")
