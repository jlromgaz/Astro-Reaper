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
@onready var play_again_btn: Button = $GameOverPanel/VBox/PlayAgainBtn
@onready var debug_panel: HBoxContainer = $DebugPanel
@onready var share_log_btn: Button = $DebugPanel/ShareLogBtn
@onready var damage_popup: Label = $DamagePopup
@onready var stats_label: Label = $StatsLabel

var _player: Node2D
var _damage_popup_timer: float = 0.0
var _xp_current := 0
var _xp_to_level := 5
var _level := 1
var _extra_time_notified := false
var _chosen_upgrades: Array[String] = []
var _upgrade_pool: Array[UpgradeData] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	level_up_panel.visible = false
	game_over_panel.visible = false
	debug_panel.visible = OS.is_debug_build()
	restart_btn.pressed.connect(_on_restart)
	play_again_btn.pressed.connect(_on_play_again)
	if debug_panel.visible:
		share_log_btn.pressed.connect(_on_share_log)
	EventBus.player_spawned.connect(_on_player_spawned)
	EventBus.player_damaged.connect(_on_player_damaged)
	EventBus.player_died.connect(_on_player_died)
	EventBus.xp_collected.connect(_on_xp_collected)
	EventBus.upgrade_selected.connect(_on_upgrade_selected)
	EventBus.player_hp_changed.connect(_on_hp_changed)
	EventBus.game_ended.connect(_on_game_ended)
	
	_upgrade_pool = _load_upgrade_pool()
	# Fallback if player spawned before HUD was ready
	call_deferred("_find_existing_player")

func _load_upgrade_pool() -> Array[UpgradeData]:
	var pool: Array[UpgradeData] = []
	var dir := DirAccess.open("res://data/upgrades/")
	if not dir:
		DebugLog.log_warn("HUD", "_load_upgrade_pool: data/upgrades/ not found")
		return pool
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if fname.ends_with(".tres"):
			var res := load("res://data/upgrades/" + fname) as UpgradeData
			if res:
				pool.append(res)
			else:
				DebugLog.log_warn("HUD", "Could not load upgrade resource: %s" % fname)
		fname = dir.get_next()
	return pool


func _find_existing_player() -> void:
	var p = get_tree().get_first_node_in_group("player")
	if p and not _player:
		_on_player_spawned(p)


@onready var shield_bar: ProgressBar = $ShieldBar
@onready var weapon_list_label: Label = $WeaponListLabel


func _process(delta: float) -> void:
	if _damage_popup_timer > 0:
		_damage_popup_timer -= delta
		if _damage_popup_timer <= 0:
			damage_popup.visible = false
	
	if GameManager.current_state == GameManager.State.PLAYING:
		_update_timer_display()
		_update_stats()
		_update_shield_bar()
		_update_weapon_list()


func _update_shield_bar() -> void:
	if not _player: return
	if _player.has_shield and _player.shield_hp > 0:
		shield_bar.visible = true
		shield_bar.value = _player.shield_hp
	else:
		shield_bar.visible = false


func _update_weapon_list() -> void:
	if not _player: return
	if not _player.has_method("get_weapons_short_list"):
		return
	weapon_list_label.text = "Weapons: " + _player.get_weapons_short_list()


func _update_timer_display() -> void:
	var total_time: float = GameManager.run_time
	var display_secs: int
	
	if total_time < 120.0:
		# Countdown mode
		display_secs = int(120.0 - total_time)
		timer_label.remove_theme_color_override("font_color")
	else:
		# Extra time mode
		display_secs = int(total_time - 120.0)
		timer_label.add_theme_color_override("font_color", Color.RED)
		if not _extra_time_notified:
			_extra_time_notified = true
			_show_message("FINAL WAVE INCOMING", 2.0)
	
	var mins: int = display_secs / 60
	var secs: int = display_secs % 60
	timer_label.text = "%d:%02d" % [mins, secs]


func _show_message(text: String, duration: float) -> void:
	# Assume we add MessageLabel to hud.tscn
	var msg_label = get_node_or_null("MessageLabel")
	if msg_label:
		msg_label.text = text
		msg_label.visible = true
		await get_tree().create_timer(duration).timeout
		msg_label.visible = false


func _show_damage_popup(amount: int) -> void:
	damage_popup.text = "-%d" % amount
	damage_popup.visible = true
	_damage_popup_timer = 1.2


func _on_player_spawned(player: Node2D) -> void:
	_player = player
	DebugLog.log_info("HUD", "Tracking Player ID: %d" % _player.get_instance_id())
	_update_hp()


func _on_player_damaged(amount: float, _source: Node) -> void:
	_update_hp()
	_show_damage_popup(int(amount))


func _on_player_died() -> void:
	_update_hp()
	_show_game_over()


func _on_hp_changed(current: float, max_v: float) -> void:
	hp_bar.max_value = max_v
	hp_bar.value = current
	hp_label.text = "HP: %d/%d" % [int(current), int(max_v)]


func _update_hp() -> void:
	if not _player:
		return
	
	var hp: float = 0.0
	var max_hp: float = 100.0
	
	if _player.has_method("get_current_hp"):
		hp = _player.get_current_hp()
	else:
		hp = _player.current_hp
		
	if _player.has_method("get_max_hp"):
		max_hp = _player.get_max_hp()
	else:
		max_hp = _player.max_hp
		
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_label.text = "HP: %d/%d" % [int(hp), int(max_hp)]
	DebugLog.log_info("HUD", "UpdateHP: %.0f/%.0f (PlayerID: %d)" % [hp, max_hp, _player.get_instance_id() if _player else 0])


func _on_xp_collected(amount: int) -> void:
	_xp_current += amount
	_update_xp_bar()
	if _xp_current >= _xp_to_level:
		_on_level_up(_level + 1)


func _update_xp_bar() -> void:
	xp_bar.max_value = _xp_to_level
	xp_bar.value = _xp_current
	xp_label.text = "Level %d | XP: %d/%d" % [_level, _xp_current, _xp_to_level]


func _on_level_up(new_level: int) -> void:
	_xp_current -= _xp_to_level
	_level = new_level
	_xp_to_level = 5 + (_level * 3) # Scaling XP curve
	_update_xp_bar()
	EventBus.player_leveled_up.emit(_level)
	_show_upgrade_selection()


func _show_upgrade_selection() -> void:
	for child in upgrade_buttons.get_children():
		child.queue_free()

	level_up_panel.show()

	var pool := _upgrade_pool.duplicate()
	pool.shuffle()
	var selected: Array = pool.slice(0, 3)

	for opt: UpgradeData in selected:
		var btn := Button.new()
		var label: String = opt.display_name
		if opt.is_weapon and opt.type != "shield" and _player and _player.has_weapon(opt.type):
			var current_level: int = _player.get_weapon_level(opt.type)
			var short_name: String = opt.type.replace("weapon_", "").capitalize()
			label = "%s → Lv.%d" % [short_name, current_level + 1]
		btn.text = label
		btn.pressed.connect(_on_upgrade_selected.bind(opt))
		upgrade_buttons.add_child(btn)

func _on_upgrade_selected(upgrade) -> void:
	if not upgrade or (upgrade is Dictionary and upgrade.is_empty()):
		return

	var disp_name: String
	var upg_type: String
	if upgrade is UpgradeData:
		disp_name = upgrade.display_name
		upg_type = upgrade.type
	else:
		disp_name = upgrade.get("name", "")
		upg_type = upgrade.get("type", "")

	DebugLog.log_info("UPGRADE", "Selected: %s" % disp_name)
	_chosen_upgrades.append(disp_name)
	EventBus.difficulty_bump.emit()
	get_tree().paused = false

	if _player:
		match upg_type:
			"weapon_blaster":
				_player.add_weapon(load("res://scripts/weapons/weapon_blaster.gd"))
			"weapon_laser":
				_player.add_weapon(load("res://scripts/weapons/weapon_laser.gd"))
			"weapon_missiles":
				_player.add_weapon(load("res://scripts/weapons/weapon_missiles.gd"))
			"weapon_anti_missile":
				_player.add_weapon(load("res://scripts/weapons/weapon_anti_missile.gd"))
			"shield":
				_player.add_shield()
			"projectile":
				_player.add_projectile_to_all()
			"stat_damage":
				_player.damage_mult *= 1.1
			"stat_fire_rate":
				_player.fire_rate_mult *= 1.1
			"stat_max_hp":
				_player.max_hp += 20
				_player.current_hp += 20
				_update_hp()
			"heal":
				_player.heal(20)
			"speed":
				_player.add_speed(20)

	level_up_panel.hide()
	EventBus.upgrade_selected.emit(null)


func _on_game_ended(reason: String) -> void:
	game_over_panel.show()
	game_over_title.text = "VICTORY!" if reason == "victory" else "GAME OVER"
	var mins: int = int(GameManager.run_time) / 60
	var secs: int = int(GameManager.run_time) % 60
	var kills := 0
	if _player and _player.has_method("get_stats") and _player.get_stats().has("kills"):
		kills = _player.get_stats().kills

	var summary := "KILLS: %d | TIME: %d:%02d" % [kills, mins, secs]
	if not ScoreManager.last_result.is_empty():
		summary += "\nSCORE: %d | BEST: %d" % [
			ScoreManager.last_result.score, ScoreManager.get_high_score()
		]
		if ScoreManager.last_result.get("is_high_score", false):
			summary += "\nNEW HIGH SCORE!"
	if _chosen_upgrades.size() > 0:
		summary += "\nUpgrades: " + ", ".join(_chosen_upgrades)
	game_over_summary.text = summary
	DebugLog.log_info("GAME", "Game ended. Total kills: %d" % kills)


func _show_game_over(reason: String = "death") -> void:
	_on_game_ended(reason)


func _on_restart() -> void:
	GameManager.go_to_menu()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _on_play_again() -> void:
	# Keeps GameManager.selected_ship; main.tscn's ready calls start_game()
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _update_stats() -> void:
	if not _player or not _player.has_method("get_stats"):
		return
	var stats = _player.get_stats()
	stats_label.text = "DMG: x%.1f | FR: x%.1f | Proj: %d | Kills: %d" % [
		stats.damage, stats.fire_rate, stats.total_projectiles, stats.get("kills", 0)
	]


func _on_share_log() -> void:
	DebugLog.share_log()
