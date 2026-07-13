extends Node
## Global leaderboard over the Firestore REST API (no SDK required).
## Fire-and-listen: call submit_score() / fetch_top(), connect to the signals.

signal submit_finished(ok: bool)
signal top_fetched(ok: bool, rows: Array)

const PROJECT_ID := "astro-reaper-e71f6"
# Public web API key — identifies the project, not a secret. Access control
# lives in firestore.rules.
const API_KEY := "AIzaSyDBhzO4OjTyQxq3SN8E4xnrXloB7991ROI"
const TOP_LIMIT := 10
const REQUEST_TIMEOUT := 10.0

var last_http_code: int = 0  # last fetch response code, for diagnosable errors

var _base_url := "https://firestore.googleapis.com/v1/projects/%s/databases/(default)/documents" % PROJECT_ID


func _ready() -> void:
	# Requests must complete while the tree is paused (game over screen).
	process_mode = Node.PROCESS_MODE_ALWAYS


func submit_score(player_name: String, score: int, mode: String) -> void:
	var body := JSON.stringify(LeaderboardCodec.build_submit_body(player_name, score, mode))
	_request("%s/scores?key=%s" % [_base_url, API_KEY], body, _on_submit_done)


func fetch_top(mode: String) -> void:
	var body := JSON.stringify(LeaderboardCodec.build_top_query(TOP_LIMIT, mode))
	_request("%s:runQuery?key=%s" % [_base_url, API_KEY], body, _on_fetch_done)


func _request(url: String, body: String, callback: Callable) -> void:
	var req := HTTPRequest.new()
	req.timeout = REQUEST_TIMEOUT
	add_child(req)
	req.request_completed.connect(
		func(result: int, code: int, _headers: PackedStringArray, resp: PackedByteArray) -> void:
			callback.call(result, code, resp)
			req.queue_free()
	)
	var err := req.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, body)
	if err != OK:
		callback.call(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedByteArray())
		req.queue_free()


func _on_submit_done(result: int, code: int, _body: PackedByteArray) -> void:
	var ok := result == HTTPRequest.RESULT_SUCCESS and code >= 200 and code < 300
	if not ok:
		DebugLog.log_error("LEADERBOARD", "Submit failed (result=%d, http=%d)" % [result, code])
	submit_finished.emit(ok)


func _on_fetch_done(result: int, code: int, body: PackedByteArray) -> void:
	var ok := result == HTTPRequest.RESULT_SUCCESS and code >= 200 and code < 300
	last_http_code = code
	var rows: Array[Dictionary] = []
	if ok:
		var json = JSON.parse_string(body.get_string_from_utf8())
		if json is Array:
			rows = LeaderboardCodec.parse_top_response(json)
		else:
			ok = false
	if not ok:
		DebugLog.log_error("LEADERBOARD", "Fetch failed (result=%d, http=%d)" % [result, code])
	top_fetched.emit(ok, rows)
