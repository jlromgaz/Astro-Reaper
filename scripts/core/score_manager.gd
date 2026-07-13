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
const ARCADE_TIME_POINTS := 25
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
	kills: int, run_level: int, victory: bool, time_to_boss: float, hp_ratio: float,
	difficulty_mult: float = 1.0
) -> int:
	# Level 1 is the starting state, not an achievement — only gained levels score.
	var score: int = int(kills * KILL_POINTS * difficulty_mult) \
		+ maxi(0, run_level - 1) * LEVEL_POINTS
	if victory:
		score += VICTORY_BASE
		score += int(maxf(0.0, PAR_TIME - time_to_boss)) * SPEED_POINTS_PER_SEC
		score += roundi(clampf(hp_ratio, 0.0, 1.0) * HP_BONUS_MAX)
	return score


## Kill-point multiplier for a persisted difficulty string. Mirrors
## GameManager.get_difficulty_mult() so breakdowns of stored records match.
static func difficulty_mult_for(diff_name: String) -> float:
	match diff_name:
		"easy": return 0.75
		"hard": return 1.3
	return 1.0


static func arcade_time_bonus(run_time: float) -> int:
	return int(run_time) * ARCADE_TIME_POINTS


## Splits a run record into labeled components that sum to its score.
static func get_breakdown(result: Dictionary) -> Array:
	var kill_mult := difficulty_mult_for(str(result.get("difficulty", "medium")))
	var lines: Array = [
		{
			"label": "%s x%d" % [TranslationServer.translate("KILLS"), int(result.kills)],
			"points": int(int(result.kills) * KILL_POINTS * kill_mult),
		},
		{
			"label": "%s %d" % [TranslationServer.translate("LEVEL"), int(result.level)],
			"points": maxi(0, int(result.level) - 1) * LEVEL_POINTS,
		},
	]
	if result.victory:
		lines.append({"label": TranslationServer.translate("VICTORY"), "points": VICTORY_BASE})
		lines.append({
			"label": TranslationServer.translate("SPEED"),
			"points": int(maxf(0.0, PAR_TIME - result.time_to_boss)) * SPEED_POINTS_PER_SEC,
		})
		lines.append({
			"label": TranslationServer.translate("HULL"),
			"points": roundi(clampf(result.hp_ratio, 0.0, 1.0) * HP_BONUS_MAX),
		})
	if str(result.get("mode", "")) == "arcade":
		lines.append({
			"label": TranslationServer.translate("SURVIVAL"),
			"points": arcade_time_bonus(result.run_time),
		})
	return lines


func get_high_score() -> int:
	var high: Dictionary = _data.get("high_score", {})
	return int(high.get("score", 0))


## Score the run would earn if it ended right now (death terms only).
func get_live_score() -> int:
	var score := calculate_score(
		_kills, GameManager.run_level, false, _time_to_boss, 0.0,
		GameManager.get_difficulty_mult()
	)
	if GameManager.game_mode == GameManager.GameMode.ARCADE:
		score += arcade_time_bonus(GameManager.run_time)
	return score


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
		_kills, GameManager.run_level, victory, _time_to_boss, hp_ratio,
		GameManager.get_difficulty_mult()
	)
	if GameManager.game_mode == GameManager.GameMode.ARCADE:
		score += arcade_time_bonus(GameManager.run_time)
	last_result = _build_record(score, victory, hp_ratio)
	# run_time == 0 means no real run happened (e.g. bare signal emissions
	# in tests) — show the result but never persist it.
	if GameManager.run_time > 0.0:
		_persist()
	else:
		last_result["is_high_score"] = false
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
		"mode": GameManager.mode_name(),
		"difficulty": GameManager.difficulty_name(),
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
