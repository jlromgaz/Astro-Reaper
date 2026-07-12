extends GutTest
## Tests for the language system: Settings autoload, EN default, ES
## translations, persistence, and the mouse-only menu selector.

const MENU_SCENE := preload("res://scenes/ui/main_menu.tscn")
const SettingsScript := preload("res://scripts/core/settings.gd")
const TEST_SETTINGS_PATH := "user://test_settings.json"


func after_each() -> void:
	Settings.set_language("en")
	if FileAccess.file_exists(TEST_SETTINGS_PATH):
		DirAccess.remove_absolute(TEST_SETTINGS_PATH)


func test_default_locale_is_english() -> void:
	assert_true(TranslationServer.get_locale().begins_with("en"),
		"English must be the default language")


func test_set_language_switches_locale_and_translates() -> void:
	Settings.set_language("es")
	assert_true(TranslationServer.get_locale().begins_with("es"))
	assert_eq(TranslationServer.translate("GAME OVER"), "FIN DE LA PARTIDA",
		"Spanish translation must be active")


func test_language_persists_across_instances() -> void:
	var s1: Node = SettingsScript.new()
	s1.save_path = TEST_SETTINGS_PATH
	add_child_autofree(s1)
	s1.set_language("es")
	var s2: Node = SettingsScript.new()
	s2.save_path = TEST_SETTINGS_PATH
	add_child_autofree(s2)
	await get_tree().process_frame
	assert_eq(s2.get_language(), "es", "Saved language must be restored on load")


func test_menu_language_buttons_are_mouse_only() -> void:
	var menu: CanvasLayer = add_child_autofree(MENU_SCENE.instantiate())
	await get_tree().process_frame
	assert_gt(menu.lang_row.get_child_count(), 1, "Menu must offer language buttons")
	for btn in menu.lang_row.get_children():
		assert_eq(btn.focus_mode, Control.FOCUS_NONE,
			"Language buttons must not enter the keyboard flow")