extends GutTest
## Tests for the demon-summoned mini-boss: 200 HP chaser that drops a
## burst of XP gems on death without ever ending the game.

const MINIBOSS_SCENE := preload("res://scenes/enemies/enemy_miniboss.tscn")


func after_each() -> void:
	GameManager.current_state = GameManager.State.MENU


func _make_miniboss_in_container() -> Array:
	var container := Node2D.new()
	add_child_autofree(container)
	var miniboss: CharacterBody2D = MINIBOSS_SCENE.instantiate()
	container.add_child(miniboss)
	await get_tree().process_frame
	return [miniboss, container]


## --- Stats & identity ---

func test_miniboss_has_exactly_200_hp() -> void:
	var mb: CharacterBody2D = add_child_autofree(MINIBOSS_SCENE.instantiate())
	await get_tree().process_frame
	assert_eq(mb.HP, 200.0, "Mini-boss HP constant must be exactly 200")
	assert_eq(mb.current_hp, 200.0, "Mini-boss must spawn at full 200 HP")
	assert_eq(mb.max_hp, 200.0, "Mini-boss max HP must be 200")


func test_miniboss_is_enemy_but_not_final_boss() -> void:
	var mb: CharacterBody2D = add_child_autofree(MINIBOSS_SCENE.instantiate())
	await get_tree().process_frame
	assert_true(mb.is_in_group("enemies"), "Weapons must be able to target the mini-boss")
	assert_true(mb.is_in_group("miniboss"))
	assert_false(mb.is_in_group("boss"), "Mini-boss must not count as the final boss")


## --- Health bar ---

func test_miniboss_has_health_bar() -> void:
	var mb: CharacterBody2D = add_child_autofree(MINIBOSS_SCENE.instantiate())
	await get_tree().process_frame
	var bar: Node = mb.get_node_or_null("HealthBar")
	assert_not_null(bar, "Mini-boss must show a HealthBar above the body")
	assert_true(bar is ProgressBar, "HealthBar must be a ProgressBar")
	assert_not_null(mb.get_node_or_null("HealthBar/HPLabel"), "HealthBar must have an HPLabel")


func test_take_damage_lowers_health_bar() -> void:
	var mb: CharacterBody2D = add_child_autofree(MINIBOSS_SCENE.instantiate())
	await get_tree().process_frame
	mb.take_damage(50.0)
	assert_eq(mb.current_hp, 150.0)
	assert_eq(mb.health_bar.value, 150.0, "HealthBar must track current HP")


## --- Death ---

func test_death_spawns_8_xp_gems_in_parent() -> void:
	var parts: Array = await _make_miniboss_in_container()
	var mb: CharacterBody2D = parts[0]
	var container: Node2D = parts[1]
	mb.take_damage(mb.max_hp)
	await get_tree().process_frame
	await get_tree().process_frame
	var gems: int = 0
	for child in container.get_children():
		if child != mb:
			gems += 1
	assert_eq(gems, 8, "Mini-boss death must scatter exactly 8 XP gems")


func test_death_emits_enemy_killed_but_never_boss_defeated() -> void:
	var parts: Array = await _make_miniboss_in_container()
	var mb: CharacterBody2D = parts[0]
	watch_signals(EventBus)
	mb.take_damage(mb.max_hp)
	assert_signal_emitted(EventBus, "enemy_killed")
	assert_signal_not_emitted(EventBus, "boss_defeated",
		"Mini-boss death must NOT end the game")
	assert_true(mb.is_queued_for_deletion())
