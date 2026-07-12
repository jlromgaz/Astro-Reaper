extends GutTest
## Tests for the proximity mine: arms after ARM_TIME, explodes when an enemy
## enters, damaging every enemy within AOE_RADIUS, and fizzles at LIFETIME.
## Written BEFORE implementation (TDD RED).

const MINE_SCENE := preload("res://scenes/bullets/bullet_mine.tscn")
const InterceptFlash := preload("res://scripts/fx/intercept_flash.gd")


class StubEnemy:
	extends Node2D
	var damage_taken := 0.0

	func take_damage(amount: float) -> void:
		damage_taken += amount


var _arena: Node2D


func before_each() -> void:
	_arena = Node2D.new()
	add_child_autofree(_arena)


func _make_mine(pos: Vector2 = Vector2.ZERO) -> Area2D:
	var mine: Area2D = MINE_SCENE.instantiate() as Area2D
	_arena.add_child(mine)
	mine.global_position = pos
	mine.setup(20.0)
	return mine


func _make_enemy(pos: Vector2) -> StubEnemy:
	var enemy := StubEnemy.new()
	enemy.add_to_group("enemies")
	_arena.add_child(enemy)
	enemy.global_position = pos
	return enemy


func test_scene_collision_layers() -> void:
	var mine := _make_mine()
	assert_eq(mine.collision_layer, 4, "mine must live on the PlayerBullets layer (4)")
	assert_eq(mine.collision_mask, 2, "mine must scan the Enemies layer (2)")


func test_trigger_ignored_before_arm_time() -> void:
	var mine := _make_mine()
	var enemy := _make_enemy(Vector2(10, 0))
	mine._on_body_entered(enemy)
	assert_false(mine.is_queued_for_deletion(), "mine must not explode before ARM_TIME")
	assert_eq(enemy.damage_taken, 0.0, "an unarmed mine must not deal damage")


func test_explodes_after_armed_damaging_enemies_within_aoe() -> void:
	var mine := _make_mine()
	var near := _make_enemy(Vector2(30, 0))
	var also_near := _make_enemy(Vector2(0, 50))
	var far := _make_enemy(Vector2(200, 0))
	mine._physics_process(0.6)  # > ARM_TIME (0.5)
	mine._on_body_entered(near)
	assert_true(mine.is_queued_for_deletion(), "armed mine must explode on enemy contact")
	assert_eq(near.damage_taken, 20.0, "trigger enemy within AOE_RADIUS must take damage")
	assert_eq(also_near.damage_taken, 20.0, "every enemy within AOE_RADIUS must take damage")
	assert_eq(far.damage_taken, 0.0, "enemies beyond AOE_RADIUS must not take damage")


func test_explosion_spawns_scaled_flash() -> void:
	var mine := _make_mine()
	var enemy := _make_enemy(Vector2(30, 0))
	mine._physics_process(0.6)
	var children_before := _arena.get_child_count()
	mine._on_body_entered(enemy)
	assert_eq(_arena.get_child_count(), children_before + 1, "explosion must spawn a flash into the parent")
	var flash: Node = _arena.get_child(children_before)
	assert_eq(flash.get_script(), InterceptFlash, "spawned child must be an intercept flash")
	assert_eq(flash.scale_mult, 2.0, "mine flash must use scale_mult 2.0")


func test_trigger_ignores_non_enemy_bodies() -> void:
	var mine := _make_mine()
	var bystander := Node2D.new()
	_arena.add_child(bystander)
	mine._physics_process(0.6)
	mine._on_body_entered(bystander)
	assert_false(mine.is_queued_for_deletion(), "bodies outside the enemies group must not trigger the mine")


func test_expires_after_lifetime() -> void:
	var mine := _make_mine()
	mine._physics_process(8.1)  # > LIFETIME (8.0)
	assert_true(mine.is_queued_for_deletion(), "mine must fizzle after LIFETIME")
