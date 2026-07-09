extends GutTest
## Tests for the Aura weapon: translucent damage field around the ship.
## Radius scales with weapon level AND the owner's projectile_size_mult.

const WeaponAura := preload("res://scripts/weapons/weapon_aura.gd")


class StubShip:
	extends Node2D
	var weapon_level := 1
	var projectile_size_mult := 1.0

	func get_weapon_level(_type: String) -> int:
		return weapon_level


class StubEnemy:
	extends CharacterBody2D
	var damage_taken := 0.0
	var hits := 0

	func take_damage(amount: float) -> void:
		damage_taken += amount
		hits += 1


var _ship: StubShip
var _aura: Node2D


func before_each() -> void:
	_ship = StubShip.new()
	add_child_autofree(_ship)
	_aura = WeaponAura.new()
	_ship.add_child(_aura)
	await get_tree().process_frame


func _make_enemy(pos: Vector2) -> StubEnemy:
	var enemy := StubEnemy.new()
	enemy.collision_layer = 2  # Enemies layer — matches the aura field mask
	enemy.add_to_group("enemies")
	var shape := CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	enemy.add_child(shape)
	add_child_autofree(enemy)
	enemy.global_position = pos
	return enemy


func test_radius_scales_with_level() -> void:
	_ship.weapon_level = 1
	_aura.fire(_ship)
	var r1: float = _aura.get_radius()
	_ship.weapon_level = 3
	_aura.fire(_ship)
	assert_gt(_aura.get_radius(), r1, "Aura must grow with weapon level")


func test_radius_scales_with_size_mult() -> void:
	_aura.fire(_ship)
	var base: float = _aura.get_radius()
	_ship.projectile_size_mult = 1.5
	_aura.fire(_ship)
	assert_almost_eq(_aura.get_radius(), base * 1.5, 0.5,
		"Size upgrades must also grow the aura")


func test_enemy_inside_takes_tick_damage() -> void:
	_aura.fire(_ship)
	var enemy := _make_enemy(_ship.global_position + Vector2(20, 0))
	await wait_physics_frames(3)
	_aura._tick_timer = 0.0
	_aura._physics_process(0.0)
	assert_gt(enemy.damage_taken, 0.0, "Enemy inside the aura must take tick damage")


func test_enemy_outside_is_untouched() -> void:
	_aura.fire(_ship)
	var enemy := _make_enemy(_ship.global_position + Vector2(500, 0))
	await wait_physics_frames(3)
	_aura._tick_timer = 0.0
	_aura._physics_process(0.0)
	assert_eq(enemy.damage_taken, 0.0, "Enemy outside the aura must be untouched")


func test_damage_is_per_tick_not_per_frame() -> void:
	_aura.fire(_ship)
	var enemy := _make_enemy(_ship.global_position + Vector2(20, 0))
	await wait_physics_frames(3)
	_aura._tick_timer = 0.0
	_aura._physics_process(0.0)
	var hits_after_tick: int = enemy.hits
	_aura._physics_process(0.016)  # tick timer refilled — no damage this frame
	assert_eq(enemy.hits, hits_after_tick, "Damage must only apply when the tick elapses")