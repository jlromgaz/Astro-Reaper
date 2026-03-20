extends Node
## Manages game state: menu, playing, paused, game_over.
## Tracks run timer. Coordinates pause on level-up.

enum State { MENU, PLAYING, PAUSED_LEVEL_UP, GAME_OVER }

var current_state: State = State.MENU
var run_time: float = 0.0
var run_level: int = 1


func _ready() -> void:
	DebugLog.log_info("GAME", "GameManager ready")
	EventBus.game_ended.connect(_on_game_ended)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.upgrade_selected.connect(_on_upgrade_selected)


func start_game() -> void:
	current_state = State.PLAYING
	run_time = 0.0
	run_level = 1
	DebugLog.log_info("GAME", "Game started")
	EventBus.game_started.emit()


func end_game(reason: String = "death") -> void:
	current_state = State.GAME_OVER
	DebugLog.log_info("GAME", "Game ended: %s (time: %.1fs)" % [reason, run_time])
	EventBus.game_ended.emit(reason)


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


func _on_game_ended(_reason: String) -> void:
	get_tree().paused = false
