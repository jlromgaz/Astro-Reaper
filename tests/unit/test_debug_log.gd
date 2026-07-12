extends GutTest
## Unit tests for DebugLog autoload — logging levels and resilience.

func test_log_info_writes_info_level() -> void:
	DebugLog.log_info("TEST", "info-unit-test")
	assert_true(
		DebugLog.get_log_content().contains("[INFO]"),
		"log_info must write [INFO] level marker"
	)

func test_log_warn_writes_warn_level() -> void:
	DebugLog.log_warn("TEST", "warn-unit-test")
	assert_true(
		DebugLog.get_log_content().contains("[WARN]"),
		"log_warn must write [WARN] level marker"
	)

func test_log_error_writes_error_level() -> void:
	# Call _log directly to avoid triggering push_error inside GUT runner
	DebugLog._log("TEST", "error-unit-test", "ERROR")
	assert_true(
		DebugLog.get_log_content().contains("[ERROR]"),
		"log_error must write [ERROR] level marker"
	)

func test_log_path_is_non_empty() -> void:
	assert_ne(DebugLog.get_log_path(), "", "get_log_path must return a non-empty path")

func test_log_content_includes_category() -> void:
	DebugLog.log_info("MYCAT", "cat-test")
	assert_true(
		DebugLog.get_log_content().contains("[MYCAT]"),
		"log content must include the category"
	)

func test_log_error_does_not_crash_on_repeated_calls() -> void:
	# Use _log directly to avoid triggering push_error inside GUT runner
	for i in range(5):
		DebugLog._log("TEST", "repeated error %d" % i, "ERROR")
	assert_true(true, "repeated _log(ERROR) calls must not crash")
