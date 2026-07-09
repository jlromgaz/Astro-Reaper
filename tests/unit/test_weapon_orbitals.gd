extends GutTest
## Tests for the orbital blades weapon: persistent blades orbit the owner
## ship and damage enemies on contact with a per-blade hit cooldown.
## Written BEFORE implementation (TDD RED).

const WeaponOrbitals := preload("res://scripts/weapons/weapon_orbitals.gd")


class StubShip:
	extends Node2D
	var weapon_level := 1

	func get_weapon_level(_weapon_type: String) -> int:
		return weapon_level


class StubEnemy:
	extends Node2D
	var damage_taken := 0.0
	var hits := 0

	func take_damage(amount: float) -> void:
		damage_taken += amount
		hits += 1


var _arena: Node2D
var _ship: StubShip
var _weapon: Node2D


func before_each() -> void:
	_arena = Node2D.new()
	add_child_autofree(_arena)
	_ship = StubShip.new()
	_arena.add_child(_ship)
	_weapon = WeaponOrbitals.new()
	_ship.add_child(_weapon)


func _blades() -> Array:
	var blades := []
	for child in _weapon.get_children():
		if child is Area2D:
			blades.append(child)
	return blades


func _make_enemy() -> StubEnemy:
	var enemy := StubEnemy.new()
	enemy.add_to_group("enemies")
	_arena.add_child(enemy)
	return enemy


func test_fire_maintains_level_plus_one_blades() -> void:
	_ship.weapon_level = 1
	_weapon.fire(_ship)
	assert_eq(_blades().size(), 2, "level 1 must maintain 2 blades")


func test_blade_count_syncs_when_level_rises() -> void:
	_weapon.fire(_ship)
	_ship.weapon_level = 3
	_weapon.fire(_ship)
	assert_eq(_blades().size(), 4, "level 3 must maintain 4 blades")


func test_blade_count_capped_at_six() -> void:
	_ship.weapon_level = 10
	_weapon.fire(_ship)
	assert_eq(_blades().size(), 6, "blade count must never exceed the cap (6)")


func test_repeat_fire_does_not_stack_blades() -> void:
	_weapon.fire(_ship)
	_weapon.fire(_ship)
	_weapon.fire(_ship)
	assert_eq(_blades().size(), 2, "repeat fire at the same level must not add blades")


func test_blades_stay_at_orbit_radius_from_owner() -> void:
	_weapon.fire(_ship)
	for i in range(10):
		_weapon._physics_process(0.016)
	for blade in _blades():
		var dist: float = blade.global_position.distance_to(_ship.global_position)
		assert_almost_eq(dist, _weapon.ORBIT_RADIUS, 1.0, "blades must stay at ORBIT_RADIUS from the owner")


func test_blades_move_across_physics_steps() -> void:
	_weapon.fire(_ship)
	_weapon._physics_process(0.016)
	var before: Vector2 = _blades()[0].position
	for i in range(10):
		_weapon._physics_process(0.016)
	var after: Vector2 = _blades()[0].position
	assert_ne(before, after, "blades must orbit (position changes across steps)")


func test_contact_damages_enemy() -> void:
	_weapon.fire(_ship)
	var enemy := _make_enemy()
	var blade: Area2D = _blades()[0]
	_weapon._on_blade_body_entered(enemy, blade)
	assert_eq(enemy.damage_taken, 8.0, "contact must deal BASE_DAMAGE * damage_mult")


func test_damage_scales_with_damage_mult() -> void:
	_weapon.fire(_ship, 2.0)
	var enemy := _make_enemy()
	_weapon._on_blade_body_entered(enemy, _blades()[0])
	assert_eq(enemy.damage_taken, 16.0, "damage_mult must scale blade damage")


func test_contact_damages_once_per_cooldown_window() -> void:
	_weapon.fire(_ship)
	var enemy := _make_enemy()
	var blade: Area2D = _blades()[0]
	_weapon._on_blade_body_entered(enemy, blade)
	_weapon._on_blade_body_entered(enemy, blade)
	assert_eq(enemy.hits, 1, "second contact within the cooldown window must be ignored")
	for i in range(30):
		_weapon._physics_process(0.016)  # 0.48s > HIT_COOLDOWN (0.4)
	_weapon._on_blade_body_entered(enemy, blade)
	assert_eq(enemy.hits, 2, "contact after the cooldown window must damage again")


func test_contact_ignores_non_enemies() -> void:
	_weapon.fire(_ship)
	var bystander := StubEnemy.new()  # has take_damage but is NOT in "enemies"
	_arena.add_child(bystander)
	_weapon._on_blade_body_entered(bystander, _blades()[0])
	assert_eq(bystander.hits, 0, "bodies outside the enemies group must be ignored")
