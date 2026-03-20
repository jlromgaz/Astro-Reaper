extends CanvasLayer
## HUD: HP bar, XP bar, timer, level-up popup, game over.

@onready var hp_bar: ProgressBar = $HPBar
@onready var hp_label: Label = $HPLabel
@onready var xp_bar: ProgressBar = $XPBar
@onready var xp_label: Label = $XPLabel
@onready var timer_label: Label = $TimerLabel
@onready var level_up_panel: PanelContainer = $LevelUpPanel
@onready var upgrade_buttons: HBoxContainer = $LevelUpPanel/VBox/UpgradeButtons
@onready var game_over_panel: PanelContainer = $GameOverPanel
@onready var game_over_title: Label = $GameOverPanel/VBox/Title
@onready var game_over_summary: Label = $GameOverPanel/VBox/Summary
@onready var restart_btn: Button = $GameOverPanel/VBox/RestartBtn
@onready var debug_panel: HBoxContainer = $DebugPanel
@onready var share_log_btn: Button = $DebugPanel/ShareLogBtn
@onready var damage_popup: Label = $DamagePopup

var _player: Node2D
var _damage_popup_timer: float = 0.0
var _xp_current := 0
var _xp_to_level := 5
var _level := 1


func _ready() -> void:
	level_up_panel.visible = false
	game_over_panel.visible = false
	debug_panel.visible = OS.is_debug_build()
	restart_btn.pressed.connect(_on_restart)
	if debug_panel.visible:
		share_log_btn.pressed.connect(_on_share_log)
	EventBus.player_spawned.connect(_on_player_spawned)
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.player_died.connect(_on_player_died)
	EventBus.xp_collected.connect(_on_xp_collected)
	EventBus.player_leveled_up.connect(_on_level_up)
	EventBus.upgrade_selected.connect(_on_upgrade_selected)
	EventBus.game_ended.connect(_on_game_ended)


func _process(delta: float) -> void:
	if _damage_popup_timer > 0:
		_damage_popup_timer -= delta
		if _damage_popup_timer <= 0:
			damage_popup.visible = false
	if GameManager.current_state == GameManager.State.PLAYING:
		var mins: int = int(GameManager.run_time) / 60
		var secs: int = int(GameManager.run_time) % 60
		timer_label.text = "%d:%02d" % [mins, secs]


func _show_damage_popup(amount: int) -> void:
	damage_popup.text = "-%d" % amount
	damage_popup.visible = true
	_damage_popup_timer = 1.2


func _on_player_spawned(player: Node2D) -> void:
	_player = player
	_update_hp()


func _on_player_damaged(amount: float, _source: Node) -> void:
	_update_hp()
	_show_damage_popup(int(amount))


func _on_player_died() -> void:
	_update_hp()
	_show_game_over()


func _update_hp() -> void:
	if not _player:
		return
	if _player.has_method("get_current_hp"):
		var hp: float = _player.current_hp
		var max_hp: float = _player.max_hp
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		hp_label.text = "HP: %d/%d" % [int(hp), int(max_hp)]
	else:
		hp_bar.value = _player.current_hp
		hp_bar.max_value = _player.max_hp
		hp_label.text = "HP: %d/%d" % [int(_player.current_hp), int(_player.max_hp)]


func _on_xp_collected(amount: int) -> void:
	_xp_current += amount
	while _xp_current >= _xp_to_level:
		_xp_current -= _xp_to_level
		_level += 1
		_xp_to_level = int(_xp_to_level * 1.15)
		EventBus.player_leveled_up.emit(_level)
	_update_xp()


func _update_xp() -> void:
	xp_bar.max_value = _xp_to_level
	xp_bar.value = _xp_current
	xp_label.text = "Level %d | XP: %d/%d" % [_level, _xp_current, _xp_to_level]


func _on_level_up(_new_level: int) -> void:
	_show_upgrade_choices()


func _show_upgrade_choices() -> void:
	level_up_panel.visible = true
	for c in upgrade_buttons.get_children():
		c.queue_free()
	var choices: Array = _get_upgrade_choices()
	for i in range(min(3, choices.size())):
		var btn: Button = Button.new()
		btn.text = choices[i]
		btn.pressed.connect(_on_upgrade_btn_pressed.bind(choices[i]))
		upgrade_buttons.add_child(btn)


func _get_upgrade_choices() -> Array[String]:
	var pool: Array = ["+10% Damage", "+10% Fire Rate", "+20 Max HP", "+Laser Weapon", "+Missiles Weapon"]
	pool.shuffle()
	return pool.slice(0, 3)


func _on_upgrade_btn_pressed(choice: String) -> void:
	_apply_upgrade(choice)
	level_up_panel.visible = false
	EventBus.upgrade_selected.emit(null)


func _apply_upgrade(choice: String) -> void:
	if not _player:
		return
	if choice == "+10% Damage":
		_player.damage_mult *= 1.1
	elif choice == "+10% Fire Rate":
		_player.fire_rate_mult *= 1.1
	elif choice == "+20 Max HP":
		_player.max_hp += 20
		_player.current_hp += 20
	elif choice == "+Laser Weapon":
		_player.add_weapon_laser()
	elif choice == "+Missiles Weapon":
		_player.add_weapon_missiles()


func _on_upgrade_selected(_data: Resource) -> void:
	level_up_panel.visible = false


func _on_game_ended(reason: String) -> void:
	_show_game_over(reason)


func _show_game_over(reason: String = "death") -> void:
	game_over_panel.visible = true
	game_over_title.text = "VICTORY" if reason == "victory" else "GAME OVER"
	var mins: int = int(GameManager.run_time) / 60
	var secs: int = int(GameManager.run_time) % 60
	game_over_summary.text = "Time: %d:%02d | Level: %d" % [mins, secs, _level]


func _on_restart() -> void:
	get_tree().reload_current_scene()


func _on_share_log() -> void:
	DebugLog.share_log()
