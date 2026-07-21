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


func test_kamikaze_flies_through_the_horde() -> void:
	# mask=2 made kamikazes jam against the crowd near the boss and hover one
	# body-width from the ship without their contact area ever reaching it.
	var kamikaze: CharacterBody2D = autofree(KAMIKAZE_SCENE.instantiate())
	assert_eq(kamikaze.collision_mask, 0,
		"Kamikaze must collide with nothing — contact is handled by its Area2D")


func test_no_lingering_contact_state_that_can_skip_the_explosion() -> void:
	# Prior bug: a dual-purpose "_damage_timer" could leave a kamikaze
	# "stuck" in contact, dealing periodic damage forever without ever
	# exploding — exactly the "pegado, no explota, quita vida" report.
	# Removed entirely: any live contact must explode immediately.
	var kamikaze: CharacterBody2D = autofree(KAMIKAZE_SCENE.instantiate())
	assert_false("_damage_timer" in kamikaze, "no timer-gated contact damage — contact always explodes")
	assert_false("_player_in_contact" in kamikaze, "no lingering contact state — contact always explodes")


func test_contact_deals_explosion_damage_and_self_destructs() -> void:
	var parts: Array = await _make_kamikaze_and_player()
	var kamikaze: CharacterBody2D = parts[0]
	var player: CharacterBody2D = parts[1]
	kamikaze._on_body_entered(player)
	assert_eq(player.damage_taken, kamikaze.EXPLOSION_DAMAGE,
		"Contact must deal the full explosion damage")
	assert_true(kamikaze.is_queued_for_deletion(), "Kamikaze must explode (die) on contact")


func test_is_dying_flag_prevents_double_die() -> void:
	var parts: Array = await _make_kamikaze_and_player()
	var kamikaze: CharacterBody2D = parts[0]
	kamikaze._die()
	assert_true(kamikaze._is_dying, "_is_dying must be true after first _die()")
	# Second call must not crash or re-queue-free
	kamikaze._die()  # should be a no-op
	assert_true(kamikaze.is_queued_for_deletion(), "Kamikaze must be queued for deletion")


func test_contact_while_dying_does_not_re_explode() -> void:
	var parts: Array = await _make_kamikaze_and_player()
	var kamikaze: CharacterBody2D = parts[0]
	var player: CharacterBody2D   = parts[1]
	kamikaze._is_dying = true
	var damage_before: float = player.damage_taken
	kamikaze._on_body_entered(player)
	assert_eq(player.damage_taken, damage_before, "No damage must be dealt when kamikaze is already dying")


func test_contact_freezes_velocity() -> void:
	var parts: Array = await _make_kamikaze_and_player()
	var kamikaze: CharacterBody2D = parts[0]
	var player: CharacterBody2D   = parts[1]
	kamikaze.velocity = Vector2(100, 0)
	kamikaze._on_body_entered(player)
	assert_eq(kamikaze.velocity, Vector2.ZERO, "Velocity must be zero'd on contact so kamikaze stops drilling")


func test_take_damage_ignores_dead_kamikaze() -> void:
	var parts: Array = await _make_kamikaze_and_player()
	var kamikaze: CharacterBody2D = parts[0]
	kamikaze._is_dying = true
	var hp_before: float = kamikaze.current_hp
	kamikaze.take_damage(999.0)
	assert_eq(kamikaze.current_hp, hp_before, "take_damage must be a no-op when _is_dying")


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


## --- Balance: speed must never run away, however high difficulty climbs ---

func test_speed_scale_is_capped_at_high_difficulty() -> void:
	# Reported bug: after 2 wave-boss kills, combined difficulty scale could
	# reach ~9x, tripling kamikaze speed and making them feel "insane".
	var kamikaze: CharacterBody2D = autofree(KAMIKAZE_SCENE.instantiate())
	kamikaze.apply_difficulty_scale(9.0)
	assert_lt(kamikaze.move_speed, kamikaze.SPEED * 2.0,
		"kamikaze speed must stay well short of double base speed even at extreme difficulty")