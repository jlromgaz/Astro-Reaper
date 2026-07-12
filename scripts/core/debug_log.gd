extends Node
## Debug logging service for mobile APK.
## Writes to user://debug_astro.log with timestamps and categories.
## On Android, use share_log() to send logs via share intent.

const LOG_PATH := "user://debug_astro.log"
const MAX_LOG_LINES := 5000

var _log_lines: Array[String] = []


func _ready() -> void:
	if not OS.is_debug_build():
		return
	_log("SYSTEM", "DebugLog initialized")
	_write_to_file("[SESSION START] %s" % Time.get_datetime_string_from_system())


func log_info(category: String, message: String) -> void:
	_log(category, message, "INFO")


func log_warn(category: String, message: String) -> void:
	_log(category, message, "WARN")
	push_warning("[%s] %s" % [category, message])


func log_error(category: String, message: String) -> void:
	_log(category, message, "ERROR")
	push_error("[%s] %s" % [category, message])


func _log(category: String, message: String, level: String = "INFO") -> void:
	var timestamp: String = Time.get_time_string_from_system()
	var line: String = "[%s][%s][%s] %s" % [timestamp, level, category, message]
	_log_lines.append(line)
	if _log_lines.size() > MAX_LOG_LINES:
		_log_lines.remove_at(0)
	print(line)
	_write_to_file(line)


func _write_to_file(line: String) -> void:
	var f: FileAccess = FileAccess.open(LOG_PATH, FileAccess.READ_WRITE)
	if not f:
		f = FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if not f:
		print("[DebugLog] Cannot write to log (error %d): %s" % [FileAccess.get_open_error(), line])
		return
	f.seek_end()
	f.store_line(line)
	f.close()


func get_log_path() -> String:
	return ProjectSettings.globalize_path(LOG_PATH)


func get_log_content() -> String:
	return "\n".join(_log_lines)


func share_log() -> void:
	## On Android, opens share intent with log content.
	var content: String = get_log_content()
	if content.is_empty():
		content = "(no log entries)"
	if OS.get_name() == "Android":
		var f: FileAccess = FileAccess.open(LOG_PATH, FileAccess.WRITE)
		if f:
			f.store_string(content)
			f.close()
		_android_share_file(LOG_PATH)
	else:
		DisplayServer.clipboard_set(content)
		log_info("DEBUG", "Log copied to clipboard (%d chars)" % content.length())


func _android_share_file(path: String) -> void:
	## Uses Godot's DisplayServer for Android share.
	## Requires Android plugin or Engine singleton - simplified for MVP.
	var abspath: String = ProjectSettings.globalize_path(path)
	OS.shell_open("file://" + abspath)
