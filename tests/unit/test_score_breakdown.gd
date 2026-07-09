extends GutTest
## Tests for the animated score breakdown on the end-game panel.

const ScoreManagerScript := preload("res://scripts/core/score_manager.gd")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func after_each() -> void:
	get_tree().paused = false
	GameManager.current_state = GameManager.State.MENU
	GameManager.run_time = 0.0


func _victory_result() -> Dictionary:
	return {
		"score": ScoreManagerScript.calculate_score(100, 8, true, 180.0, 0.5),
		"kills": 100, "level": 8, "victory": true,
		"time_to_boss": 180.0, "hp_ratio": 0.5,
		"mode": "classic", "run_time": 180.0,
	}


func test_breakdown_components_sum_to_score() -> void:
	var result := _victory_result()
	var lines: Array = ScoreManagerScript.get_breakdown(result)
	var total := 0
	for line in lines:
		total += line.points
	assert_eq(total, result.score, "Breakdown components must sum to the final score")


func test_victory_breakdown_has_all_bonus_lines() -> void:
	var lines: Array = ScoreManagerScript.get_breakdown(_victory_result())
	assert_eq(lines.size(), 5, "kills + level + victory + speed + hp")


func test_death_breakdown_has_no_victory_lines() -> void:
	var result := {
		"score": ScoreManagerScript.calculate_score(50, 5, false, -1.0, 0.0),
		"kills": 50, "level": 5, "victory": false,
		"time_to_boss": -1.0, "hp_ratio": 0.0,
		"mode": "classic", "run_time": 90.0,
	}
	var lines: Array = ScoreManagerScript.get_breakdown(result)
	assert_eq(lines.size(), 2, "Death shows only kills + level lines")


func test_arcade_breakdown_includes_time_bonus() -> void:
	var result := {
		"score": 50 + 1500, "kills": 0, "level": 1, "victory": false,
		"time_to_boss": -1.0, "hp_ratio": 0.0,
		"mode": "arcade", "run_time": 60.0,
	}
	var lines: Array = ScoreManagerScript.get_breakdown(result)
	var has_time := false
	for line in lines:
		if line.points == 1500:
			has_time = true
	assert_true(has_time, "Arcade breakdown must include the survival time bonus")


func test_hud_displays_counting_score() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	hud._summary_base = "KILLS: 10"
	hud._set_displayed_score(1234, 5000)
	assert_true(hud.game_over_summary.text.contains("1234"),
		"The animated total must render into the summary")