extends GutTest
## Tests for Settings persistence: the music and SFX on/off preferences.

const SETTINGS_SCRIPT := preload("res://scripts/core/settings.gd")
const TEST_PATH := "user://test_settings_music.json"


func _make_settings() -> Node:
	var s: Node = SETTINGS_SCRIPT.new()
	s.save_path = TEST_PATH
	add_child_autofree(s)
	return s


func after_each() -> void:
	if FileAccess.file_exists(TEST_PATH):
		DirAccess.remove_absolute(TEST_PATH)
	SoundManager._music_enabled = true  # restore defaults for other tests
	SoundManager._sfx_enabled = true


func test_music_enabled_by_default() -> void:
	var s := _make_settings()
	assert_true(s.get_music_enabled())


func test_set_music_enabled_persists_across_reload() -> void:
	var s := _make_settings()
	s.set_music_enabled(false)
	assert_false(s.get_music_enabled())

	var reloaded: Node = SETTINGS_SCRIPT.new()
	reloaded.save_path = TEST_PATH
	add_child_autofree(reloaded)
	assert_false(reloaded.get_music_enabled(), "music preference must persist across reloads")


func test_set_music_enabled_applies_to_sound_manager() -> void:
	var s := _make_settings()
	s.set_music_enabled(false)
	assert_false(SoundManager._music_enabled, "toggling in Settings must apply to SoundManager immediately")


func test_sfx_enabled_by_default() -> void:
	var s := _make_settings()
	assert_true(s.get_sfx_enabled())


func test_set_sfx_enabled_persists_across_reload() -> void:
	var s := _make_settings()
	s.set_sfx_enabled(false)
	assert_false(s.get_sfx_enabled())

	var reloaded: Node = SETTINGS_SCRIPT.new()
	reloaded.save_path = TEST_PATH
	add_child_autofree(reloaded)
	assert_false(reloaded.get_sfx_enabled(), "SFX preference must persist across reloads")


func test_set_sfx_enabled_applies_to_sound_manager() -> void:
	var s := _make_settings()
	s.set_sfx_enabled(false)
	assert_false(SoundManager._sfx_enabled, "toggling in Settings must apply to SoundManager immediately")


func test_music_and_sfx_toggle_independently() -> void:
	var s := _make_settings()
	s.set_music_enabled(false)
	assert_true(s.get_sfx_enabled(), "disabling music must not affect SFX")
	s.set_sfx_enabled(false)
	assert_false(s.get_music_enabled())
	assert_false(s.get_sfx_enabled())
