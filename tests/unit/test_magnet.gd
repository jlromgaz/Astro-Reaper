extends GutTest
## Tests for the XP magnet: rare drop that pulls every gem to the player.

const MAGNET_SCENE := preload("res://scenes/pickups/pickup_magnet.tscn")
const XP_SCENE := preload("res://scenes/pickups/xp_pickup.tscn")


class FakePlayer:
	extends CharacterBody2D

	func get_pickup_radius() -> float:
		return 10.0


func _make_player(pos: Vector2) -> FakePlayer:
	var player := FakePlayer.new()
	player.add_to_group("player")
	add_child_autofree(player)
	player.global_position = pos
	return player


func test_gems_join_the_xp_group() -> void:
	var gem: Area2D = add_child_autofree(XP_SCENE.instantiate())
	await get_tree().process_frame
	assert_true(gem.is_in_group("xp_pickups"), "Gems must be findable by the magnet")


func test_attracted_gem_flies_toward_player() -> void:
	var player := _make_player(Vector2(400, 0))
	var gem: Area2D = add_child_autofree(XP_SCENE.instantiate())
	gem.global_position = Vector2.ZERO
	gem.attract_to(player)
	var dist_before: float = gem.global_position.distance_to(player.global_position)
	gem._process(0.05)
	assert_lt(gem.global_position.distance_to(player.global_position), dist_before,
		"An attracted gem must fly toward the player")


func test_magnet_pickup_attracts_all_gems() -> void:
	var player := _make_player(Vector2(500, 0))
	var gems: Array = []
	for i in range(3):
		var gem: Area2D = add_child_autofree(XP_SCENE.instantiate())
		gem.global_position = Vector2(i * 50, 200)
		gems.append(gem)
	var magnet: Area2D = add_child_autofree(MAGNET_SCENE.instantiate())
	await get_tree().process_frame
	magnet._on_body_entered(player)
	for gem in gems:
		assert_true(gem._magnet_target == player,
			"Magnet must attract every gem on screen")
	assert_true(magnet.is_queued_for_deletion(), "Magnet is consumed on pickup")


func test_magnet_is_a_pickup_layer_node() -> void:
	var magnet: Area2D = add_child_autofree(MAGNET_SCENE.instantiate())
	await get_tree().process_frame
	assert_eq(magnet.collision_layer, 16)
	assert_eq(magnet.collision_mask, 1)
	assert_false(magnet.is_in_group("enemies"))


func test_magnet_drop_chance_reduced_for_rarity() -> void:
	const SPAWNER_SCRIPT := preload("res://scripts/systems/enemy_spawner.gd")
	assert_lt(SPAWNER_SCRIPT.MAGNET_DROP_CHANCE, 0.015, "magnets must be rarer than before")