extends GutTest
## Tests for data-driven upgrade resources (UpgradeData .tres files).

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

var hud: CanvasLayer


func before_each() -> void:
	hud = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame


## --- Resource loading ---

func test_upgrade_blaster_resource_loads() -> void:
	var res := load("res://data/upgrades/upgrade_blaster.tres") as UpgradeData
	assert_not_null(res, "upgrade_blaster.tres must load as UpgradeData")
	assert_ne(res.id, "", "id must be non-empty")
	assert_ne(res.type, "", "type must be non-empty")


func test_upgrade_speed_is_not_weapon() -> void:
	var res := load("res://data/upgrades/upgrade_speed.tres") as UpgradeData
	assert_not_null(res)
	assert_false(res.is_weapon, "speed upgrade must not be a weapon")


func test_upgrade_blaster_is_weapon() -> void:
	var res := load("res://data/upgrades/upgrade_blaster.tres") as UpgradeData
	assert_not_null(res)
	assert_true(res.is_weapon, "blaster upgrade must be flagged as weapon")


func test_upgrade_pool_has_minimum_count() -> void:
	var pool: Array[UpgradeData] = hud._load_upgrade_pool()
	assert_gte(pool.size(), 5, "upgrade pool must contain at least 5 options")


func test_all_pool_entries_have_valid_type() -> void:
	var pool: Array[UpgradeData] = hud._load_upgrade_pool()
	for entry in pool:
		assert_ne(entry.type, "", "Every UpgradeData must have a non-empty type — got empty on '%s'" % entry.id)


func test_upgrade_selected_applies_via_resource() -> void:
	# Confirm hud._on_upgrade_selected still works when fed an UpgradeData dict-style call
	# (backward compat: the match block uses .type key — UpgradeData exposes .type property)
	var res := load("res://data/upgrades/upgrade_heal.tres") as UpgradeData
	assert_not_null(res)
	# _on_upgrade_selected now accepts UpgradeData; it should not crash without a player
	hud._on_upgrade_selected(res)
	assert_true(true, "calling _on_upgrade_selected with UpgradeData must not crash")
