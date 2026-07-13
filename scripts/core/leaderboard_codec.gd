class_name LeaderboardCodec
extends RefCounted
## Pure helpers for the Firestore REST leaderboard: builds request bodies and
## parses responses. No I/O — fully unit-testable.


static func build_submit_body(player_name: String, score: int, mode: String) -> Dictionary:
	# Firestore REST encodes integers as strings inside integerValue.
	return {
		"fields": {
			"name": {"stringValue": player_name},
			"score": {"integerValue": str(score)},
			"mode": {"stringValue": mode},
		}
	}


static func build_top_query(limit: int, mode: String) -> Dictionary:
	# mode == filter + score DESC order requires the composite index declared
	# in firestore.indexes.json.
	return {
		"structuredQuery": {
			"from": [{"collectionId": "scores"}],
			"where": {
				"fieldFilter": {
					"field": {"fieldPath": "mode"},
					"op": "EQUAL",
					"value": {"stringValue": mode},
				}
			},
			"orderBy": [{"field": {"fieldPath": "score"}, "direction": "DESCENDING"}],
			"limit": limit,
		}
	}


## runQuery returns an array of rows; rows without a "document" key are
## metadata (readTime-only) and must be skipped.
static func parse_top_response(rows: Array) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for row in rows:
		if not (row is Dictionary and row.has("document")):
			continue
		var fields: Dictionary = row["document"].get("fields", {})
		var name_field: Dictionary = fields.get("name", {})
		var score_field: Dictionary = fields.get("score", {})
		out.append({
			"name": str(name_field.get("stringValue", "???")),
			"score": int(str(score_field.get("integerValue", "0"))),
		})
	return out
