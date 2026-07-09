extends Node
## ScoreManager — objective run scoring and local high-score persistence.
## EventBus-driven; never touches the player node directly. Records are flat
## primitives so a future web backend ranking can consume them unchanged.

const KILL_POINTS := 100
const LEVEL_POINTS := 50
const VICTORY_BASE := 10000
const PAR_TIME := 240.0
const SPEED_POINTS_PER_SEC := 50
const HP_BONUS_MAX := 2000
const RECENT_CAP := 20
const SCHEMA_VERSION := 1

var save_path: String = "user://scores.json"
var last_result: Dictionary = {}

var _kills: int = 0
var _time_to_boss: float = -1.0
var _hp_ratio: float = 1.0
var _data: Dictionary = {}


func _ready() -> void:
	_data = _load_data()
	EventBus.game_started.connect(_on_game_started)
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.player_hp_changed.connect(_on_player_hp_changed)
	EventBus.boss_defeated.connect(_on_boss_defeated)
	EventBus.game_ended.connect(_on_game_ended)


static func calculate_score(
	kills: int, run_level: int, victory: bool, time_to_boss: float, hp_ratio: float
) -> int:
	var score: int = kills * KILL_POINTS + run_level * LEVEL_POINTS
	if victory:
		score += VICTORY_BASE
		score += int(maxf(0.0, PAR_TIME - time_to_boss)) * SPEED_POINTS_PER_SEC
		score += roundi(clampf(hp_ratio, 0.0, 1.0) * HP_BONUS_MAX)
	return score


func get_high_score() -> int:
	var high: Dictionary = _data.get("high_score", {})
	return int(high.get("score", 0))


func _on_game_started() -> void:
	_kills = 0
	_time_to_boss = -1.0
	_hp_ratio = 1.0
	last_result = {}


func _on_enemy_killed(_enemy: Node2D, _position: Vector2) -> void:
	_kills += 1


func _on_player_hp_changed(current: float, max_hp: float) -> void:
	if max_hp > 0.0:
		_hp_ratio = clampf(current / max_hp, 0.0, 1.0)


func _on_boss_defeated() -> void:
	_time_to_boss = GameManager.run_time


func _on_game_ended(reason: String) -> void:
	var victory: bool = reason == "victory"
	var hp_ratio: float = _hp_ratio if victory else 0.0
	var score: int = calculate_score(
		_kills, GameManager.run_level, victory, _time_to_boss, hp_ratio
	)
	last_result = _build_record(score, victory, hp_ratio)
	_persist()
	DebugLog.log_info("SCORE", "Run scored %d (best: %d)" % [score, get_high_score()])


func _build_record(score: int, victory: bool, hp_ratio: float) -> Dictionary:
	var ship_id: String = ""
	if GameManager.selected_ship:
		ship_id = GameManager.selected_ship.ship_id
	return {
		"score": score,
		"kills": _kills,
		"run_time": GameManager.run_time,
		"time_to_boss": _time_to_boss,
		"hp_ratio": hp_ratio,
		"level": GameManager.run_level,
		"ship_id": ship_id,
		"victory": victory,
		"date": Time.get_datetime_string_from_system(true),
		"app_version": str(ProjectSettings.get_setting("application/config/version", "")),
		"schema_version": SCHEMA_VERSION,
	}


func _persist() -> void:
	var is_high: bool = last_result.score > get_high_score()
	last_result["is_high_score"] = is_high
	if is_high:
		_data["high_score"] = last_result
	var recent: Array = _data.get("recent", [])
	recent.push_front(last_result)
	if recent.size() > RECENT_CAP:
		recent.resize(RECENT_CAP)
	_data["recent"] = recent
	_data["schema_version"] = SCHEMA_VERSION
	_save_data()


func _default_data() -> Dictionary:
	return {"schema_version": SCHEMA_VERSION, "high_score": {}, "recent": []}


func _load_data() -> Dictionary:
	if not FileAccess.file_exists(save_path):
		return _default_data()
	var f := FileAccess.open(save_path, FileAccess.READ)
	if not f:
		DebugLog.log_warn("SCORE", "Could not open %s — using defaults" % save_path)
		return _default_data()
	var json := JSON.new()
	if json.parse(f.get_as_text()) == OK and json.data is Dictionary:
		return json.data
	DebugLog.log_warn("SCORE", "Corrupt score file %s — using defaults" % save_path)
	return _default_data()


func _save_data() -> void:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if not f:
		DebugLog.log_error("SCORE", "Could not write %s" % save_path)
		return
	f.store_string(JSON.stringify(_data))
