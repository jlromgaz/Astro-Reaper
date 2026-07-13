extends GutTest
## Tests for the pure Firestore REST codec used by the global leaderboard.


func test_submit_body_shape() -> void:
	var body := LeaderboardCodec.build_submit_body("ACE", 2950, "classic-medium")
	assert_eq(body.fields.name.stringValue, "ACE")
	assert_eq(body.fields.mode.stringValue, "classic-medium")


func test_submit_body_encodes_score_as_string() -> void:
	# Firestore REST requires integerValue to be a JSON string.
	var body := LeaderboardCodec.build_submit_body("ACE", 2950, "arcade-medium")
	assert_eq(body.fields.score.integerValue, "2950")
	assert_true(body.fields.score.integerValue is String)


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
