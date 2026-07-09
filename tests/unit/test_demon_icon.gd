extends GutTest
## Tests for the demon summon icon: a menacing pickup that summons an
## XP-rich mini-boss when the player touches it.

const ICON_SCENE := preload("res://scenes/world/demon_icon.tscn")


func after_each() -> void:
	GameManager.current_state = GameManager.State.MENU


func _make_icon_in_container() -> Array:
	var container := Node2D.new()
	add_child_autofree(container)
	var icon: Area2D = ICON_SCENE.instantiate()
	container.add_child(icon)
	await get_tree().process_frame
	return [icon, container]


func _count_minibosses(container: Node2D) -> int:
	var count: int = 0
	for child in container.get_children():
		if child.is_in_group("miniboss"):
			count += 1
	return count


## --- Icon node ---

func test_icon_is_a_pickup_not_an_enemy() -> void:
	var icon: Area2D = add_child_autofree(ICON_SCENE.instantiate())
	await get_tree().process_frame
	assert_eq(icon.collision_layer, 16, "Demon icon lives on the Pickups layer")
	assert_eq(icon.collision_mask, 1, "Demon icon only detects the player")
	assert_true(icon.is_in_group("demon_icons"))
	assert_false(icon.is_in_group("enemies"), "Weapons must not target the demon icon")


## --- Summoning ---

func test_player_touch_summons_one_miniboss_and_consumes_icon() -> void:
	var parts: Array = await _make_icon_in_container()
	var icon: Area2D = parts[0]
	var container: Node2D = parts[1]
	var player := Node2D.new()
	player.add_to_group("player")
	container.add_child(player)
	watch_signals(EventBus)
	icon._on_body_entered(player)
	await get_tree().process_frame
	assert_eq(_count_minibosses(container), 1,
		"Touching the icon must summon exactly one mini-boss in the icon's parent")
	assert_true(not is_instance_valid(icon) or icon.is_queued_for_deletion(),
		"Icon must be consumed on touch")
	assert_signal_emitted(EventBus, "enemy_spawned")


func test_summoned_miniboss_keeps_fixed_200_hp() -> void:
	var parts: Array = await _make_icon_in_container()
	var icon: Area2D = parts[0]
	var container: Node2D = parts[1]
	var player := Node2D.new()
	player.add_to_group("player")
	container.add_child(player)
	icon._on_body_entered(player)
	await get_tree().process_frame
	for child in container.get_children():
		if child.is_in_group("miniboss"):
			assert_eq(child.current_hp, 200.0,
				"Summoned mini-boss must keep its fixed 200 HP (no difficulty scaling)")


func test_non_player_body_is_ignored() -> void:
	var parts: Array = await _make_icon_in_container()
	var icon: Area2D = parts[0]
	var container: Node2D = parts[1]
	var rock := Node2D.new()
	container.add_child(rock)
	icon._on_body_entered(rock)
	await get_tree().process_frame
	assert_eq(_count_minibosses(container), 0, "Non-player bodies must not trigger the summon")
	assert_false(icon.is_queued_for_deletion(), "Icon must survive non-player contact")
