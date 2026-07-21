extends GutTest
## Tests for the Leaderboard autoload's HTTPRequest configuration.
##
## Root cause of the "CONNECTION ERROR (200)" ranking bug: the Web export's
## browser transport already transparently decompresses gzip-encoded
## responses before Godot sees the bytes, but Godot's own HTTPRequest tries
## to gunzip them a second time and fails (RESULT_BODY_DECOMPRESS_FAILED)
## once a response is large enough for Firestore to gzip it. Disabling gzip
## acceptance sidesteps the double-decompression on every platform.


func test_leaderboard_requests_disable_gzip() -> void:
	var req := HTTPRequest.new()
	add_child_autofree(req)
	Leaderboard._configure_request(req)
	assert_false(req.accept_gzip,
		"Leaderboard HTTPRequests must disable gzip to avoid Godot's double-decompression bug on Web")
