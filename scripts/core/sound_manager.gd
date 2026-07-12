extends Node
## Sound Manager — procedural sine-wave beeps wired to EventBus combat events.

var _shoot_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _gen_stream: AudioStreamGeneratorPlayback
var _music_gen: AudioStreamGeneratorPlayback
var _music_phase := 0.0
var _hit_cooldown: float = 0.0  # rate-limit enemy_hit to prevent audio stacking


func _ready() -> void:
	_shoot_player = AudioStreamPlayer.new()
	var s_gen = AudioStreamGenerator.new()
	s_gen.mix_rate = 44100
	_shoot_player.stream = s_gen
	add_child(_shoot_player)
	_shoot_player.play()
	_gen_stream = _shoot_player.get_stream_playback()
	
	_music_player = AudioStreamPlayer.new()
	var m_gen = AudioStreamGenerator.new()
	m_gen.mix_rate = 44100
	_music_player.stream = m_gen
	_music_player.volume_db = -20.0 # Very soft
	add_child(_music_player)
	_music_player.play()
	_music_gen = _music_player.get_stream_playback()

	EventBus.enemy_damaged.connect(func(_e, _a): play_enemy_hit())
	EventBus.enemy_killed.connect(func(_e, _p): play_enemy_death())
	EventBus.player_damaged.connect(func(_a, _s): play_player_hit())
	EventBus.boss_spawned.connect(func(_b): play_boss_incoming())
	EventBus.boss_defeated.connect(play_victory_fanfare)
	EventBus.xp_collected.connect(func(_a): play_xp_ping())
	EventBus.player_leveled_up.connect(func(_l): play_level_up_sound())


func _process(delta: float) -> void:
	_update_music()
	if _hit_cooldown > 0.0:
		_hit_cooldown -= delta


func _update_music() -> void:
	if not _music_gen: return
	var to_fill = _music_gen.get_frames_available()
	while to_fill > 0:
		var val = sin(_music_phase * TAU) * 0.05 # Very soft
		_music_gen.push_frame(Vector2(val, val))
		_music_phase = fmod(_music_phase + 110.0 / 44100.0, 1.0) # Very low base note
		to_fill -= 1


func play_shoot_sound() -> void:
	_play_beep(440.0, 0.05)


func play_pulse_sound() -> void:
	_play_beep(220.0, 0.15)


func play_pickup_sound() -> void:
	_play_beep(880.0, 0.1)


func play_level_up_sound() -> void:
	_play_beep(660.0, 0.2)


func play_enemy_hit() -> void:
	if _hit_cooldown > 0.0:
		return
	_hit_cooldown = 0.08
	_play_beep(350.0, 0.05)


func play_enemy_death() -> void:
	_play_beep(200.0, 0.12)


func play_player_hit() -> void:
	_play_beep(120.0, 0.2)


func play_boss_incoming() -> void:
	_play_beep(80.0, 0.6)


func play_victory_fanfare() -> void:
	_play_beep(440.0, 0.2)
	await get_tree().create_timer(0.22).timeout
	_play_beep(550.0, 0.2)
	await get_tree().create_timer(0.22).timeout
	_play_beep(660.0, 0.3)


func play_xp_ping() -> void:
	_play_beep(780.0, 0.04)


func _play_beep(freq: float, duration: float) -> void:
	if not _gen_stream: return
	
	var samples = int(44100 * duration)
	var phase = 0.0
	var increment = freq / 44100.0
	
	for i in range(samples):
		var value = sin(phase * TAU)
		_gen_stream.push_frame(Vector2(value, value))
		phase = fmod(phase + increment, 1.0)
