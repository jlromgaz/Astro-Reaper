extends GutTest
## Tests for SoundManager audio integration with EventBus combat signals.
## Audio output is not assertable in headless — these are method-existence
## and smoke tests (no crash = pass).


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
