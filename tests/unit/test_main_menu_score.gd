extends GutTest
## Tests for the high-score display in the main menu.
##
## BEST must reflect the actual GLOBAL leaderboard top entry (with the
## initials of whoever set it), not the local per-device high score —
## a local score that was never submitted/saved must never be shown as
## "BEST", since that's exactly what confused a player comparing it to
## the ranking table.

const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")

var menu: CanvasLayer


func before_each() -> void:
	menu = add_child_autofree(MENU_SCENE.instantiate())
	await get_tree().process_frame


func test_best_score_label_shows_value_and_initials() -> void:
	menu._set_best_score(12450, "ACE")
	assert_true(menu.best_score_label.visible, "Label must be visible with a positive score")
	assert_true(menu.best_score_label.text.contains("12450"), "Label must display the high score value")
	assert_true(menu.best_score_label.text.contains("ACE"), "Label must display who set it")


func test_best_score_label_hidden_when_no_score() -> void:
	menu._set_best_score(0, "")
	assert_false(menu.best_score_label.visible, "Label must hide when there is no high score yet")


func test_best_score_reflects_global_leaderboard_fetch() -> void:
	menu._on_global_best_fetched(true, [{"name": "JLR", "score": 5000}, {"name": "AAV", "score": 100}])
	assert_true(menu.best_score_label.visible)
	assert_true(menu.best_score_label.text.contains("5000"), "Must show the TOP entry's score")
	assert_true(menu.best_score_label.text.contains("JLR"), "Must show the TOP entry's initials")


func test_best_score_hidden_when_fetch_fails() -> void:
	menu._on_global_best_fetched(false, [])
	assert_false(menu.best_score_label.visible,
		"A failed fetch must not show a stale/local score in BEST's place")


func test_best_score_hidden_when_leaderboard_is_empty() -> void:
	menu._on_global_best_fetched(true, [])
	assert_false(menu.best_score_label.visible)
