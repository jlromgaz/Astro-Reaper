extends Node
## Sound Manager — cached WAV beeps played through one polyphonic stream,
## plus a looping generated music track. Wired to EventBus combat events.
## No per-frame generator pushes: those starve the buffer under load and
## crackle badly in web exports.

const SFX_POLYPHONY := 12
const SFX_RATE := 22050
const MUSIC_DB := -16.0

var _sfx_player: AudioStreamPlayer
var _sfx_playback: AudioStreamPlaybackPolyphonic
var _music_player: AudioStreamPlayer
var _beep_cache: Dictionary = {}
var _hit_cooldown: float = 0.0  # rate-limit enemy_hit to prevent audio stacking
var _audio_unlocked := false  # web browsers block audio until first user gesture


func _ready() -> void:
	_sfx_player = AudioStreamPlayer.new()
	var poly := AudioStreamPolyphonic.new()
	poly.polyphony = SFX_POLYPHONY
	_sfx_player.stream = poly
	add_child(_sfx_player)

	_music_player = AudioStreamPlayer.new()
	var music: AudioStreamWAV = load("res://assets/audio/music_loop.wav")
	if music:
		music.loop_mode = AudioStreamWAV.LOOP_FORWARD
		music.loop_begin = 0
		music.loop_end = music.data.size() / 2  # 16-bit mono: 2 bytes per frame
		_music_player.stream = music
	_music_player.volume_db = MUSIC_DB
	add_child(_music_player)

	EventBus.enemy_damaged.connect(func(_e, _a): play_enemy_hit())
	EventBus.enemy_killed.connect(func(_e, _p): play_enemy_death())
	EventBus.player_damaged.connect(func(_a, _s): play_player_hit())
	EventBus.boss_spawned.connect(func(_b): play_boss_incoming())
	EventBus.boss_defeated.connect(play_victory_fanfare)
	EventBus.xp_collected.connect(func(_a): play_xp_ping())
	EventBus.player_leveled_up.connect(func(_l): play_level_up_sound())


func _input(event: InputEvent) -> void:
	if _audio_unlocked:
		return
	if event is InputEventMouseButton or event is InputEventScreenTouch or event is InputEventKey:
		_unlock_audio()


func _unlock_audio() -> void:
	if _audio_unlocked:
		return
	_audio_unlocked = true
	_sfx_player.play()
	_sfx_playback = _sfx_player.get_stream_playback()
	if _music_player.stream:
		_music_player.play()


func _process(delta: float) -> void:
	if _hit_cooldown > 0.0:
		_hit_cooldown -= delta


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
	if not _audio_unlocked or not _sfx_playback:
		return
	_sfx_playback.play_stream(_get_beep(freq, duration))


func _get_beep(freq: float, duration: float) -> AudioStreamWAV:
	var key := "%d_%d" % [int(freq), int(duration * 1000.0)]
	if not _beep_cache.has(key):
		_beep_cache[key] = _make_beep(freq, duration)
	return _beep_cache[key]


## Sine beep with a short attack/release envelope — hard edges click.
func _make_beep(freq: float, duration: float) -> AudioStreamWAV:
	var frames := int(SFX_RATE * duration)
	var data := PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t := float(i) / SFX_RATE
		var envelope := minf(1.0, t / 0.004) * minf(1.0, (duration - t) / 0.03)
		var value := int(sin(TAU * freq * t) * envelope * 0.35 * 32767.0)
		data.encode_s16(i * 2, value)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = SFX_RATE
	wav.stereo = false
	wav.data = data
	return wav
