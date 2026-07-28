extends Node
## Settings — persists user preferences (language, music, SFX) to user://.
## English is the default; the menu selector calls set_language().

const DEFAULT_LANGUAGE := "en"
const DEFAULT_MUSIC_VOLUME := 100.0
const DEFAULT_SFX_ENABLED := true

var save_path: String = "user://settings.json"

var _language: String = DEFAULT_LANGUAGE
var _music_volume: float = DEFAULT_MUSIC_VOLUME
var _sfx_enabled: bool = DEFAULT_SFX_ENABLED


func _ready() -> void:
	_load()
	TranslationServer.set_locale(_language)
	SoundManager.set_music_volume(_music_volume)
	SoundManager.set_sfx_enabled(_sfx_enabled)
	_adapt_scale()


func _adapt_scale() -> void:
	# On desktop browsers / PC, expand the design space to 1280x720 so UI
	# proportions feel normal. On mobile, keep the 480x270 design (elements
	# appear 2.67x larger thanks to the higher scale factor).
	if not DisplayServer.is_touchscreen_available():
		get_tree().root.content_scale_size = Vector2i(1280, 720)


func get_language() -> String:
	return _language


func set_language(code: String) -> void:
	_language = code
	TranslationServer.set_locale(code)
	_save()
	DebugLog.log_info("SETTINGS", "Language set to %s" % code)


func get_music_volume() -> float:
	return _music_volume


func set_music_volume(percent: float) -> void:
	_music_volume = clampf(percent, 0.0, 100.0)
	SoundManager.set_music_volume(_music_volume)
	_save()
	DebugLog.log_info("SETTINGS", "Music volume set to %.0f%%" % _music_volume)


func get_sfx_enabled() -> bool:
	return _sfx_enabled


func set_sfx_enabled(enabled: bool) -> void:
	_sfx_enabled = enabled
	SoundManager.set_sfx_enabled(enabled)
	_save()
	DebugLog.log_info("SETTINGS", "SFX enabled: %s" % enabled)


func _load() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var f := FileAccess.open(save_path, FileAccess.READ)
	if not f:
		return
	var json := JSON.new()
	if json.parse(f.get_as_text()) == OK and json.data is Dictionary:
		_language = str(json.data.get("language", DEFAULT_LANGUAGE))
		_music_volume = float(json.data.get("music_volume", DEFAULT_MUSIC_VOLUME))
		_sfx_enabled = bool(json.data.get("sfx_enabled", DEFAULT_SFX_ENABLED))


func _save() -> void:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if not f:
		DebugLog.log_error("SETTINGS", "Could not write %s" % save_path)
		return
	f.store_string(JSON.stringify({
		"language": _language,
		"music_volume": _music_volume,
		"sfx_enabled": _sfx_enabled,
	}))
