extends Node
## Settings — persists user preferences (language for now) to user://.
## English is the default; the menu selector calls set_language().

const DEFAULT_LANGUAGE := "en"

var save_path: String = "user://settings.json"

var _language: String = DEFAULT_LANGUAGE


func _ready() -> void:
	_load()
	TranslationServer.set_locale(_language)


func get_language() -> String:
	return _language


func set_language(code: String) -> void:
	_language = code
	TranslationServer.set_locale(code)
	_save()
	DebugLog.log_info("SETTINGS", "Language set to %s" % code)


func _load() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var f := FileAccess.open(save_path, FileAccess.READ)
	if not f:
		return
	var json := JSON.new()
	if json.parse(f.get_as_text()) == OK and json.data is Dictionary:
		_language = str(json.data.get("language", DEFAULT_LANGUAGE))


func _save() -> void:
	var f := FileAccess.open(save_path, FileAccess.WRITE)
	if not f:
		DebugLog.log_error("SETTINGS", "Could not write %s" % save_path)
		return
	f.store_string(JSON.stringify({"language": _language}))
