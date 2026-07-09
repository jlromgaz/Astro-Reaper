extends GutTest
## Tests for the proximity mine weapon: each fire drops min(level, 3) mines
## at the owner ship's position. Written BEFORE implementation (TDD RED).

const WeaponMines := preload("res://scripts/weapons/weapon_mines.gd")
const MineScript := preload("res://scripts/bullets/bullet_mine.gd")


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
	_weapon = autofree(WeaponMines.new())


func _spawned_mines() -> Array:
	var mines := []
	for child in _arena.get_children():
		if child.get_script() == MineScript:
			mines.append(child)
	return mines


func test_fire_drops_one_mine_at_level_one() -> void:
	_weapon.fire(_ship)
	assert_eq(_spawned_mines().size(), 1, "level 1 must drop exactly one mine")


func test_fire_drops_one_mine_per_level() -> void:
	_ship.weapon_level = 2
	_weapon.fire(_ship)
	assert_eq(_spawned_mines().size(), 2, "level 2 must drop two mines")


func test_drop_count_capped_at_three() -> void:
	_ship.weapon_level = 5
	_weapon.fire(_ship)
	assert_eq(_spawned_mines().size(), 3, "drop count must be capped at 3")


func test_mines_dropped_at_owner_position() -> void:
	_ship.global_position = Vector2(120, -40)
	_weapon.fire(_ship)
	for mine in _spawned_mines():
		assert_eq(mine.global_position, Vector2(120, -40), "mines must be dropped at the owner ship's position")


func test_mine_damage_scales_with_damage_mult() -> void:
	_weapon.fire(_ship, 2.0)
	assert_eq(_spawned_mines()[0].damage, 40.0, "mine damage must be BASE_DAMAGE * damage_mult")
