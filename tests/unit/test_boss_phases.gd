extends GutTest
## Tests for boss spray and pulse attack phases.

const BOSS_SCENE := preload("res://scenes/enemies/enemy_boss.tscn")


func _make_boss_with_player() -> Array:
	var container := Node2D.new()
	add_child_autofree(container)
	var boss: CharacterBody2D = BOSS_SCENE.instantiate()
	container.add_child(boss)
	var fake_player := Node2D.new()
	fake_player.add_to_group("player")  # so boss._find_player() (deferred) finds it
	container.add_child(fake_player)
	await get_tree().process_frame  # deferred _find_player() runs here
	return [boss, fake_player, container]


## --- Timer initialization ---

func test_spray_timer_initialized_positive() -> void:
	var boss: CharacterBody2D = add_child_autofree(BOSS_SCENE.instantiate())
	await get_tree().process_frame
	assert_gt(boss._spray_timer, 0.0, "spray timer must start positive")


func test_pulse_timer_initialized_positive() -> void:
	var boss: CharacterBody2D = add_child_autofree(BOSS_SCENE.instantiate())
	await get_tree().process_frame
	assert_gt(boss._pulse_timer, 0.0, "pulse timer must start positive")


func test_pulse_timer_offset_from_spray() -> void:
	var boss: CharacterBody2D = add_child_autofree(BOSS_SCENE.instantiate())
	await get_tree().process_frame
	assert_ne(boss._spray_timer, boss._pulse_timer, "timers must start offset so attacks don't overlap")


## --- Spray attack ---

func test_spray_does_nothing_without_player() -> void:
	var boss: CharacterBody2D = add_child_autofree(BOSS_SCENE.instantiate())
	await get_tree().process_frame
	boss._player = null
	boss._do_spray()
	assert_true(true, "_do_spray with no player must not crash")


func test_do_spray_spawns_6_bullets() -> void:
	var parts: Array = await _make_boss_with_player()
	var boss: CharacterBody2D = parts[0]
	var container: Node2D = parts[2]
	var children_before: int = container.get_child_count()
	boss._do_spray()
	await get_tree().process_frame
	var added: int = container.get_child_count() - children_before
	assert_eq(added, 6, "_do_spray must spawn exactly 6 bullets")


## --- Pulse attack ---

func test_do_pulse_spawns_8_bullets() -> void:
	var parts: Array = await _make_boss_with_player()
	var boss: CharacterBody2D = parts[0]
	var container: Node2D = parts[2]
	var children_before: int = container.get_child_count()
	boss._do_pulse()
	await get_tree().process_frame
	var added: int = container.get_child_count() - children_before
	assert_eq(added, 8, "_do_pulse must spawn exactly 8 bullets")


func test_pulse_works_without_player() -> void:
	var boss: CharacterBody2D = add_child_autofree(BOSS_SCENE.instantiate())
	await get_tree().process_frame
	boss._player = null
	boss._do_pulse()
	assert_true(true, "_do_pulse must not require a player")


## --- Visual telegraph ---

func test_enemy_visual_has_start_telegraph_method() -> void:
	var vis: Node = load("res://scripts/enemies/enemy_visual.gd").new()
	add_child_autofree(vis)
	await get_tree().process_frame
	assert_true(vis.has_method("start_telegraph"), "enemy_visual must expose start_telegraph(duration)")


func test_start_telegraph_sets_timer() -> void:
	var vis: Node = load("res://scripts/enemies/enemy_visual.gd").new()
	add_child_autofree(vis)
	await get_tree().process_frame
	vis.start_telegraph(0.5)
	assert_gt(vis._telegraph_timer, 0.0, "start_telegraph must set _telegraph_timer > 0")
