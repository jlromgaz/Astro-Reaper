extends Node
## Manages game state: menu, playing, paused, game_over, victory.
## Tracks run timer. Coordinates pause on level-up.
## Holds selected ship data for the current run.

enum State { MENU, PLAYING, PAUSED_LEVEL_UP, GAME_OVER, VICTORY, PAUSED }
enum GameMode { CLASSIC, ARCADE }
enum Difficulty { EASY, MEDIUM, HARD }

var current_state: State = State.MENU
var run_time: float = 0.0
var run_level: int = 1
var selected_ship: ShipResource = null
var game_mode: GameMode = GameMode.CLASSIC
var difficulty: Difficulty = Difficulty.MEDIUM


func get_difficulty_mult() -> float:
	match difficulty:
		Difficulty.EASY: return 0.75
		Difficulty.HARD: return 1.3
	return 1.0


func mode_name() -> String:
	return "arcade" if game_mode == GameMode.ARCADE else "classic"


func difficulty_name() -> String:
	match difficulty:
		Difficulty.EASY: return "easy"
		Difficulty.HARD: return "hard"
	return "medium"


func _ready() -> void:
	DebugLog.log_info("GAME", "GameManager ready")
	EventBus.game_ended.connect(_on_game_ended)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.upgrade_selected.connect(_on_upgrade_selected)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.comet_bonus.connect(_on_bonus_pause)
	EventBus.chest_opened.connect(_on_bonus_pause)


func select_ship(ship: ShipResource) -> void:
	selected_ship = ship
	DebugLog.log_info("GAME", "Ship selected: %s" % ship.ship_name)


func start_game() -> void:
	current_state = State.PLAYING
	run_time = 0.0
	run_level = 1
	DebugLog.log_info("GAME", "Game started")
	EventBus.game_started.emit()


func end_game(reason: String = "death") -> void:
	if reason == "victory":
		current_state = State.VICTORY
	else:
		current_state = State.GAME_OVER
	DebugLog.log_info("GAME", "Game ended: %s (time: %.1fs)" % [reason, run_time])
	EventBus.game_ended.emit(reason)


func win_game() -> void:
	end_game("victory")
	EventBus.victory.emit()


func toggle_pause() -> void:
	if current_state == State.PLAYING:
		current_state = State.PAUSED
		get_tree().paused = true
		EventBus.game_paused.emit()
		DebugLog.log_info("GAME", "Paused by player")
	elif current_state == State.PAUSED:
		current_state = State.PLAYING
		get_tree().paused = false
		EventBus.game_resumed.emit()
		DebugLog.log_info("GAME", "Resumed by player")


func go_to_menu() -> void:
	current_state = State.MENU
	selected_ship = null
	get_tree().paused = false


func _process(delta: float) -> void:
	if current_state == State.PLAYING:
		run_time += delta


func is_playing() -> bool:
	return current_state == State.PLAYING


func is_paused() -> bool:
	return current_state == State.PAUSED_LEVEL_UP


func _on_player_leveled_up(new_level: int) -> void:
	run_level = new_level
	current_state = State.PAUSED_LEVEL_UP
	get_tree().paused = true
	EventBus.game_paused.emit()
	DebugLog.log_info("UPGRADE", "Level up to %d, paused for upgrade choice" % new_level)


func _on_upgrade_selected(_upgrade_data: Resource) -> void:
	current_state = State.PLAYING
	get_tree().paused = false
	EventBus.game_resumed.emit()
	DebugLog.log_info("UPGRADE", "Upgrade selected, resuming")


func _on_bonus_pause() -> void:
	# Same pause as a level-up, but run_level is untouched (bonus, not a level).
	current_state = State.PAUSED_LEVEL_UP
	get_tree().paused = true
	EventBus.game_paused.emit()
	DebugLog.log_info("UPGRADE", "Bonus pickup — paused for upgrade choice")


func _on_game_ended(_reason: String) -> void:
	get_tree().paused = false


func _on_boss_defeated() -> void:
	DebugLog.log_info("GAME", "Final boss defeated! Victory!")
	win_game()
