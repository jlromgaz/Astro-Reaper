extends GutTest
## Tests for the anti-missile weapon: it must launch visible counter-missiles
## at incoming enemy projectiles instead of despawning them instantly.
## Written BEFORE implementation (TDD RED).

const WeaponAntiMissile := preload("res://scripts/weapons/weapon_anti_missile.gd")
const CounterMissileScript := preload("res://scripts/bullets/bullet_counter_missile.gd")


class StubShip:
	extends Node2D
	var weapon_level := 1

	func get_weapon_level(_weapon_type: String) -> int:
		return weapon_level


var _arena: Node2D
var _ship: StubShip
var _weapon: Node2D


func before_each() -> void:
	_arena = Node2D.new()
	add_child_autofree(_arena)
	_ship = StubShip.new()
	_arena.add_child(_ship)
	_weapon = autofree(WeaponAntiMissile.new())


func _spawn_projectile(pos: Vector2) -> Area2D:
	var projectile := Area2D.new()
	projectile.add_to_group("enemy_projectiles")
	_arena.add_child(projectile)
	projectile.global_position = pos
	return projectile


func _spawned_missiles() -> Array:
	var missiles := []
	for child in _arena.get_children():
		if child.get_script() == CounterMissileScript:
			missiles.append(child)
	return missiles


func test_fire_spawns_one_missile_per_projectile_with_distinct_targets() -> void:
	_spawn_projectile(Vector2(100, 0))
	_spawn_projectile(Vector2(0, 120))
	_spawn_projectile(Vector2(-80, -60))
	_weapon.fire(_ship)
	var missiles := _spawned_missiles()
	assert_eq(missiles.size(), 3, "fire must spawn one counter-missile per in-range projectile")
	var seen_targets := []
	for missile in missiles:
		assert_not_null(missile._target, "each counter-missile must receive a target")
		assert_false(seen_targets.has(missile._target), "counter-missiles must have pairwise-distinct targets")
		seen_targets.append(missile._target)


func test_fire_does_not_instantly_free_projectiles() -> void:
	var projectile := _spawn_projectile(Vector2(100, 0))
	_weapon.fire(_ship)
	assert_true(is_instance_valid(projectile), "projectile must still exist after fire")
	assert_false(projectile.is_queued_for_deletion(), "REGRESSION: projectiles must be intercepted visibly, not despawned instantly")


func test_fire_with_no_candidates_spawns_nothing() -> void:
	_weapon.fire(_ship)
	assert_eq(_spawned_missiles().size(), 0, "no candidates -> no counter-missiles")


func test_fire_ignores_projectiles_out_of_detection_range() -> void:
	_spawn_projectile(Vector2(500, 0))  # beyond DETECTION_RANGE (300)
	_weapon.fire(_ship)
	assert_eq(_spawned_missiles().size(), 0, "projectiles beyond DETECTION_RANGE must be ignored")


func test_fire_skips_already_claimed_projectiles() -> void:
	var claimed := _spawn_projectile(Vector2(50, 0))
	claimed.set_meta("intercepted", true)
	_spawn_projectile(Vector2(100, 0))
	_weapon.fire(_ship)
	var missiles := _spawned_missiles()
	assert_eq(missiles.size(), 1, "already-claimed projectiles must not receive a second missile")
	if missiles.size() == 1:
		assert_ne(missiles[0]._target, claimed, "the spawned missile must target the unclaimed projectile")


func test_volley_capped_at_five_per_level() -> void:
	for i in range(12):
		_spawn_projectile(Vector2(20 + i * 10, 0))
	_weapon.fire(_ship)  # level 1 -> 5 * 1 = 5
	assert_eq(_spawned_missiles().size(), 5, "level 1 volley must be capped at 5")


func test_volley_capped_at_max_volley() -> void:
	_ship.weapon_level = 2
	for i in range(12):
		_spawn_projectile(Vector2(20 + i * 10, 0))
	_weapon.fire(_ship)  # 5 * 2 = 10, capped at MAX_VOLLEY (8)
	assert_eq(_spawned_missiles().size(), 8, "volley must never exceed MAX_VOLLEY")


func test_volley_limited_by_available_projectiles() -> void:
	_ship.weapon_level = 2
	for i in range(3):
		_spawn_projectile(Vector2(20 + i * 10, 0))
	_weapon.fire(_ship)
	assert_eq(_spawned_missiles().size(), 3, "volley must not exceed the number of candidates")
