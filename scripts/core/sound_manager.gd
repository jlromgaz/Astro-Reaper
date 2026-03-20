extends Node
## Simple Sound Manager using AudioStreamGenerator for procedural beeps.

var _shoot_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _gen_stream: AudioStreamGeneratorPlayback
var _music_gen: AudioStreamGeneratorPlayback
var _music_phase := 0.0


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


func _process(_delta: float) -> void:
	_update_music()


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


func _play_beep(freq: float, duration: float) -> void:
	if not _gen_stream: return
	
	var samples = int(44100 * duration)
	var phase = 0.0
	var increment = freq / 44100.0
	
	for i in range(samples):
		var value = sin(phase * TAU)
		_gen_stream.push_frame(Vector2(value, value))
		phase = fmod(phase + increment, 1.0)
