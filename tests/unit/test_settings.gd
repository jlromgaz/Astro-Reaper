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
	SoundManager._music_volume = 100.0  # restore defaults for other tests
	SoundManager._sfx_enabled = true


func test_music_volume_defaults_to_100() -> void:
	var s := _make_settings()
	assert_eq(s.get_music_volume(), 100.0)


func test_set_music_volume_persists_across_reload() -> void:
	var s := _make_settings()
	s.set_music_volume(35.0)
	assert_eq(s.get_music_volume(), 35.0)

	var reloaded: Node = SETTINGS_SCRIPT.new()
	reloaded.save_path = TEST_PATH
	add_child_autofree(reloaded)
	assert_eq(reloaded.get_music_volume(), 35.0, "music volume must persist across reloads")


func test_set_music_volume_applies_to_sound_manager() -> void:
	var s := _make_settings()
	s.set_music_volume(20.0)
	assert_eq(SoundManager._music_volume, 20.0, "setting volume in Settings must apply to SoundManager immediately")


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


func test_music_volume_and_sfx_toggle_independently() -> void:
	var s := _make_settings()
	s.set_music_volume(0.0)
	assert_true(s.get_sfx_enabled(), "disabling music must not affect SFX")
	s.set_sfx_enabled(false)
	assert_eq(s.get_music_volume(), 0.0)
	assert_false(s.get_sfx_enabled())
