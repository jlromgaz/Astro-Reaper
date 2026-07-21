extends GutTest
## Tests for the pure Firestore REST codec used by the global leaderboard.


func test_submit_body_shape() -> void:
	var body := LeaderboardCodec.build_submit_body("ACE", 2950, "classic-medium", "stellar", 125.0, 30, 5)
	assert_eq(body.fields.name.stringValue, "ACE")
	assert_eq(body.fields.mode.stringValue, "classic-medium")


func test_submit_body_encodes_score_as_string() -> void:
	# Firestore REST requires integerValue to be a JSON string.
	var body := LeaderboardCodec.build_submit_body("ACE", 2950, "arcade-medium", "stellar", 125.0, 30, 5)
	assert_eq(body.fields.score.integerValue, "2950")
	assert_true(body.fields.score.integerValue is String)


func test_submit_body_includes_run_stats() -> void:
	var body := LeaderboardCodec.build_submit_body("ACE", 2950, "arcade", "vanguard", 187.5, 42, 9)
	assert_eq(body.fields.ship.stringValue, "vanguard")
	assert_eq(body.fields.run_time.doubleValue, 187.5)
	assert_eq(body.fields.kills.integerValue, "42")
	assert_true(body.fields.kills.integerValue is String)
	assert_eq(body.fields.level.integerValue, "9")
	assert_true(body.fields.level.integerValue is String)


func test_top_query_orders_by_score_descending() -> void:
	var query := LeaderboardCodec.build_top_query(10, "classic-medium")
	var sq: Dictionary = query.structuredQuery
	assert_eq(sq.from[0].collectionId, "scores")
	assert_eq(sq.orderBy[0].field.fieldPath, "score")
	assert_eq(sq.orderBy[0].direction, "DESCENDING")
	assert_eq(sq.limit, 10)


func test_top_query_filters_by_mode() -> void:
	var query := LeaderboardCodec.build_top_query(10, "arcade")
	var filter: Dictionary = query.structuredQuery.where.fieldFilter
	assert_eq(filter.field.fieldPath, "mode")
	assert_eq(filter.op, "EQUAL")
	assert_eq(filter.value.stringValue, "arcade")


func test_parse_extracts_name_and_score() -> void:
	var rows := [
		{"document": {"fields": {
			"name": {"stringValue": "ACE"},
			"score": {"integerValue": "2950"},
		}}},
		{"document": {"fields": {
			"name": {"stringValue": "BOB"},
			"score": {"integerValue": "100"},
		}}},
	]
	var parsed := LeaderboardCodec.parse_top_response(rows)
	assert_eq(parsed.size(), 2)
	assert_eq(parsed[0], {"name": "ACE", "score": 2950})
	assert_eq(parsed[1], {"name": "BOB", "score": 100})


func test_parse_extracts_run_stats_when_present() -> void:
	var rows := [{"document": {"fields": {
		"name": {"stringValue": "ACE"},
		"score": {"integerValue": "2950"},
		"ship": {"stringValue": "phantom"},
		"run_time": {"doubleValue": 212.5},
		"kills": {"integerValue": "37"},
		"level": {"integerValue": "8"},
	}}}]
	var parsed := LeaderboardCodec.parse_top_response(rows)
	assert_eq(parsed[0].ship, "phantom")
	assert_eq(parsed[0].run_time, 212.5)
	assert_eq(parsed[0].kills, 37)
	assert_eq(parsed[0].level, 8)


func test_parse_omits_run_stats_when_absent() -> void:
	# Historical entries recorded before this feature have none of these
	# fields — the UI must be able to tell "absent" from "zero".
	var rows := [{"document": {"fields": {
		"name": {"stringValue": "OLD"},
		"score": {"integerValue": "100"},
	}}}]
	var parsed := LeaderboardCodec.parse_top_response(rows)
	assert_false(parsed[0].has("ship"))
	assert_false(parsed[0].has("run_time"))
	assert_false(parsed[0].has("kills"))
	assert_false(parsed[0].has("level"))


func test_parse_skips_metadata_rows() -> void:
	# runQuery may return readTime-only rows with no document.
	var rows := [
		{"readTime": "2026-07-13T00:00:00Z"},
		{"document": {"fields": {
			"name": {"stringValue": "ACE"},
			"score": {"integerValue": "1"},
		}}},
	]
	var parsed := LeaderboardCodec.parse_top_response(rows)
	assert_eq(parsed.size(), 1)
	assert_eq(parsed[0].name, "ACE")


func test_parse_handles_empty_and_malformed() -> void:
	assert_eq(LeaderboardCodec.parse_top_response([]).size(), 0)
	var parsed := LeaderboardCodec.parse_top_response([{"document": {}}])
	assert_eq(parsed.size(), 1)
	assert_eq(parsed[0], {"name": "???", "score": 0})
