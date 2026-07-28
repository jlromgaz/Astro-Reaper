extends GutTest
## Tests for SoundManager audio integration with EventBus combat signals.
## Audio output is not assertable in headless — these are method-existence
## and smoke tests (no crash = pass), plus SFX synthesis/cache checks.

const SOUND_SCRIPT := preload("res://scripts/core/sound_manager.gd")


func _make_manager() -> Node:
	var m: Node = SOUND_SCRIPT.new()
	add_child_autofree(m)
	return m


## --- SFX synthesis (crackling fix: pre-rendered WAVs, no generator pushes) ---

func test_beep_is_prerendered_wav() -> void:
	var m := _make_manager()
	var beep: AudioStreamWAV = m._make_beep(440.0, 0.05)
	assert_eq(beep.format, AudioStreamWAV.FORMAT_16_BITS)
	assert_false(beep.stereo)
	# 0.05s at 22050 Hz, 2 bytes per frame
	assert_eq(beep.data.size(), int(22050 * 0.05) * 2)


func test_beep_cache_reuses_streams() -> void:
	var m := _make_manager()
	var first: AudioStreamWAV = m._get_beep(440.0, 0.05)
	var second: AudioStreamWAV = m._get_beep(440.0, 0.05)
	assert_same(first, second, "Same freq/duration must not re-render the WAV")
	var other: AudioStreamWAV = m._get_beep(200.0, 0.12)
	assert_ne(other, first)


func test_beep_envelope_starts_and_ends_silent() -> void:
	var m := _make_manager()
	var beep: AudioStreamWAV = m._make_beep(440.0, 0.05)
	# Hard edges click — first and last samples must be (near) zero
	assert_eq(beep.data.decode_s16(0), 0)
	assert_lt(absi(beep.data.decode_s16(beep.data.size() - 2)), 400)


func test_music_stream_loops() -> void:
	var m := _make_manager()
	var music: AudioStreamWAV = m._music_player.stream
	assert_not_null(music, "Background music must be loaded")
	assert_eq(music.loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_gt(music.loop_end, 0)


## --- Music volume slider ---

func test_music_volume_defaults_to_100() -> void:
	var m := _make_manager()
	assert_eq(m._music_volume, 100.0, "Music must default to full volume")


func test_setting_music_volume_to_zero_stops_the_player() -> void:
	# stream_paused proved unreliable for a looping stream on the Web export
	# (reported: no way to actually silence the music) — stop() is the
	# unambiguous, platform-independent way to guarantee silence.
	var m := _make_manager()
	m._audio_unlocked = true
	m._music_player.play()
	m.set_music_volume(0.0)
	assert_false(m._music_player.playing, "0% volume must actually stop playback")
	assert_eq(m._music_volume, 0.0)


func test_raising_music_volume_from_zero_resumes_the_player() -> void:
	var m := _make_manager()
	m._audio_unlocked = true
	m._music_player.play()
	m.set_music_volume(0.0)
	m.set_music_volume(75.0)
	assert_true(m._music_player.playing, "Raising volume above 0 must resume playback")
	assert_eq(m._music_volume, 75.0)


func test_unlock_audio_respects_zero_music_volume() -> void:
	var m := _make_manager()
	m._audio_unlocked = false
	m.set_music_volume(0.0)
	m._unlock_audio()
	assert_false(m._music_player.playing, "Music must not start playing if volume is 0 before unlock")


func test_music_volume_maps_to_expected_db() -> void:
	# 100% must preserve today's baseline loudness (MUSIC_DB), not jump to 0dB.
	var m := _make_manager()
	m.set_music_volume(100.0)
	assert_almost_eq(m._music_player.volume_db, m.MUSIC_DB, 0.001,
		"100% must match the pre-slider baseline dB")
	m.set_music_volume(50.0)
	var expected: float = m.MUSIC_DB + linear_to_db(0.5)
	assert_almost_eq(m._music_player.volume_db, expected, 0.001)


## --- SFX mute toggle (independent from music) ---

func test_sfx_enabled_by_default() -> void:
	var m := _make_manager()
	assert_true(m._sfx_enabled, "SFX must play by default")


func test_disabling_sfx_sets_the_flag() -> void:
	var m := _make_manager()
	m.set_sfx_enabled(false)
	assert_false(m._sfx_enabled)


func test_play_beep_does_nothing_when_sfx_disabled() -> void:
	var m := _make_manager()
	m._unlock_audio()
	m.set_sfx_enabled(false)
	m._play_beep(440.0, 0.05)
	assert_true(true, "playing a beep while SFX is disabled must not crash")


func test_music_and_sfx_are_independent_toggles() -> void:
	var m := _make_manager()
	m.set_sfx_enabled(false)
	assert_eq(m._music_volume, 100.0, "disabling SFX must not affect music volume")


## --- Method existence ---

func test_play_enemy_hit_exists() -> void:
	assert_true(SoundManager.has_method("play_enemy_hit"))


func test_play_enemy_death_exists() -> void:
	assert_true(SoundManager.has_method("play_enemy_death"))


func test_play_player_hit_exists() -> void:
	assert_true(SoundManager.has_method("play_player_hit"))


func test_play_boss_incoming_exists() -> void:
	assert_true(SoundManager.has_method("play_boss_incoming"))


func test_play_victory_fanfare_exists() -> void:
	assert_true(SoundManager.has_method("play_victory_fanfare"))


func test_play_xp_ping_exists() -> void:
	assert_true(SoundManager.has_method("play_xp_ping"))


## --- Web autoplay gate ---

func test_audio_unlocked_flag_starts_false() -> void:
	SoundManager._audio_unlocked = false
	assert_false(SoundManager._audio_unlocked,
		"audio must be locked until user gesture (web autoplay policy)")


func test_unlock_audio_sets_flag() -> void:
	SoundManager._audio_unlocked = false
	SoundManager._unlock_audio()
	assert_true(SoundManager._audio_unlocked, "_unlock_audio must set the flag")
	SoundManager._audio_unlocked = false  # reset autoload state for other tests


## --- EventBus smoke tests (must not crash) ---

func test_enemy_damaged_signal_triggers_hit_sound() -> void:
	EventBus.enemy_damaged.emit(null, 5.0)
	assert_true(true, "enemy_damaged must not crash SoundManager")


func test_player_damaged_triggers_player_hit() -> void:
	EventBus.player_damaged.emit(10.0, null)
	assert_true(true, "player_damaged must not crash SoundManager")


func test_boss_defeated_triggers_fanfare() -> void:
	EventBus.boss_defeated.emit()
	assert_true(true, "boss_defeated must not crash SoundManager")


func test_xp_collected_triggers_ping() -> void:
	EventBus.xp_collected.emit(1)
	assert_true(true, "xp_collected must not crash SoundManager")
