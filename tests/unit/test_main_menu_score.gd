extends GutTest
## Tests for the high-score display in the main menu.

const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")

var menu: CanvasLayer


func before_each() -> void:
	menu = add_child_autofree(MENU_SCENE.instantiate())
	await get_tree().process_frame


func test_best_score_label_shows_value() -> void:
	menu._set_best_score(12450)
	assert_true(menu.best_score_label.visible, "Label must be visible with a positive score")
	assert_true(
		menu.best_score_label.text.contains("12450"),
		"Label must display the high score value"
	)


func test_best_score_label_hidden_when_no_score() -> void:
	menu._set_best_score(0)
	assert_false(menu.best_score_label.visible, "Label must hide when there is no high score yet")
