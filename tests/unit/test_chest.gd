extends GutTest
## Tests for the upgrade chest: random pickup that opens the FULL upgrade
## catalog and applies the chosen upgrade three times.

const CHEST_SCENE := preload("res://scenes/world/chest.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")


func after_each() -> void:
	get_tree().paused = false
	GameManager.current_state = GameManager.State.MENU


## --- Chest node ---

func test_chest_is_a_pickup_not_an_enemy() -> void:
	var chest: Area2D = add_child_autofree(CHEST_SCENE.instantiate())
	await get_tree().process_frame
	assert_eq(chest.collision_layer, 16, "Chest lives on the Pickups layer")
	assert_eq(chest.collision_mask, 1, "Chest only detects the player")
	assert_true(chest.is_in_group("chests"))
	assert_false(chest.is_in_group("enemies"), "Weapons must not target chests")


func test_player_contact_opens_chest() -> void:
	var chest: Area2D = add_child_autofree(CHEST_SCENE.instantiate())
	await get_tree().process_frame
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	add_child_autofree(player)
	watch_signals(EventBus)
	chest._on_body_entered(player)
	assert_signal_emitted(EventBus, "chest_opened")
	assert_true(chest.is_queued_for_deletion(), "Chest must be consumed on open")


## --- Pause + full catalog panel ---

func test_chest_opened_pauses_for_selection() -> void:
	GameManager.current_state = GameManager.State.PLAYING
	EventBus.chest_opened.emit()
	assert_eq(GameManager.current_state, GameManager.State.PAUSED_LEVEL_UP)
	assert_true(get_tree().paused)


func test_chest_shows_full_catalog_with_x3() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	EventBus.chest_opened.emit()
	await get_tree().process_frame
	assert_true(hud.level_up_panel.visible)
	assert_eq(hud.upgrade_buttons.get_child_count(), hud._upgrade_pool.size(),
		"Chest must offer the FULL upgrade catalog")
	assert_eq(hud._pending_multiplier, 3, "Chest upgrades apply x3")


## --- x3 application ---

func test_multiplier_applies_upgrade_three_times() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	var player: CharacterBody2D = add_child_autofree(PLAYER_SCENE.instantiate())
	await get_tree().process_frame
	hud._player = player
	var speed_before: float = player.move_speed
	hud._pending_multiplier = 3
	var upgrade := UpgradeData.new()
	upgrade.display_name = "+Speed"
	upgrade.type = "speed"
	hud._on_upgrade_selected(upgrade)
	assert_eq(player.move_speed, speed_before + 60.0,
		"x3 chest upgrade must apply the effect three times (+20 each)")
	assert_eq(hud._pending_multiplier, 1, "Multiplier must reset after applying")