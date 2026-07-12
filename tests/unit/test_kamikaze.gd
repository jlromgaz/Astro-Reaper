extends GutTest
## Tests for kamikaze contact explosion: extra damage, self-destruction, FX.

const KAMIKAZE_SCENE := preload("res://scenes/enemies/enemy_kamikaze.tscn")


class FakePlayer:
	extends CharacterBody2D
	var damage_taken: float = 0.0

	func take_damage(amount: float, _source: Node) -> void:
		damage_taken += amount


func _make_kamikaze_and_player() -> Array:
	var arena := Node2D.new()
	add_child_autofree(arena)
	var kamikaze: CharacterBody2D = KAMIKAZE_SCENE.instantiate()
	arena.add_child(kamikaze)
	var player := FakePlayer.new()
	player.add_to_group("player")
	arena.add_child(player)
	await get_tree().process_frame
	return [kamikaze, player, arena]


func test_explosion_damage_exceeds_contact_damage() -> void:
	var kamikaze: CharacterBody2D = autofree(KAMIKAZE_SCENE.instantiate())
	assert_gt(kamikaze.EXPLOSION_DAMAGE, kamikaze.DAMAGE,
		"Kamikaze explosion must hurt more than a regular contact tick")


func test_contact_deals_explosion_damage_and_self_destructs() -> void:
	var parts: Array = await _make_kamikaze_and_player()
	var kamikaze: CharacterBody2D = parts[0]
	var player: CharacterBody2D = parts[1]
	kamikaze._on_body_entered(player)
	assert_eq(player.damage_taken, kamikaze.EXPLOSION_DAMAGE,
		"Contact must deal the full explosion damage")
	assert_true(kamikaze.is_queued_for_deletion(), "Kamikaze must explode (die) on contact")


func test_contact_explosion_spawns_flash() -> void:
	var parts: Array = await _make_kamikaze_and_player()
	var kamikaze: CharacterBody2D = parts[0]
	var player: CharacterBody2D = parts[1]
	var arena: Node2D = parts[2]
	var children_before: int = arena.get_child_count()
	kamikaze._on_body_entered(player)
	await get_tree().process_frame
	assert_gt(arena.get_child_count(), children_before - 1,
		"Explosion must leave a visible flash node behind")
	var found_flash := false
	for child in arena.get_children():
		if child is Node2D and child.has_method("_draw") and "scale_mult" in child:
			found_flash = true
	assert_true(found_flash, "Explosion flash (intercept_flash-style) must be spawned")