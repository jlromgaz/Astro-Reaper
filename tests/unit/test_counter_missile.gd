extends GutTest
## Tests for the counter-missile launched by the anti-missile weapon.
## It homes toward an assigned enemy projectile and BOTH explode on contact.
## Written BEFORE implementation (TDD RED).

const COUNTER_MISSILE_SCENE := preload("res://scenes/bullets/bullet_counter_missile.tscn")
const InterceptFlash := preload("res://scripts/fx/intercept_flash.gd")

var _arena: Node2D


func before_each() -> void:
	_arena = Node2D.new()
	add_child_autofree(_arena)


func _make_missile(pos: Vector2 = Vector2.ZERO) -> Area2D:
	var missile: Area2D = COUNTER_MISSILE_SCENE.instantiate() as Area2D
	_arena.add_child(missile)
	missile.global_position = pos
	return missile


func _make_enemy_projectile(pos: Vector2) -> Area2D:
	var projectile := Area2D.new()
	projectile.add_to_group("enemy_projectiles")
	_arena.add_child(projectile)
	projectile.global_position = pos
	return projectile


func test_scene_collision_layers() -> void:
	var missile := _make_missile()
	assert_eq(missile.collision_layer, 4, "counter-missile must live on the PlayerBullets layer (4)")
	assert_eq(missile.collision_mask, 8, "counter-missile must scan the EnemyBullets layer (8)")


func test_setup_assigns_target() -> void:
	var missile := _make_missile()
	var target := _make_enemy_projectile(Vector2(100, 0))
	missile.setup(320.0, target)
	assert_eq(missile._target, target, "setup must assign the pre-selected target")


func test_homing_reduces_distance_to_offaxis_target() -> void:
	var missile := _make_missile(Vector2.ZERO)
	var target := _make_enemy_projectile(Vector2(0, 150))
	missile.setup(320.0, target)  # velocity starts along +X, target is on +Y
	var start_dist := missile.global_position.distance_to(target.global_position)
	for i in range(30):
		missile._physics_process(0.016)
	var end_dist := missile.global_position.distance_to(target.global_position)
	assert_lt(end_dist, start_dist, "homing must curve the missile toward its target")


func test_contact_detonates_both_and_spawns_flash() -> void:
	var missile := _make_missile()
	var target := _make_enemy_projectile(Vector2(40, 0))
	missile.setup(320.0, target)
	var children_before := _arena.get_child_count()
	missile._on_area_entered(target)
	assert_true(missile.is_queued_for_deletion(), "counter-missile must destroy itself on contact")
	assert_true(target.is_queued_for_deletion(), "intercepted projectile must be destroyed on contact")
	assert_eq(_arena.get_child_count(), children_before + 1, "detonation must spawn an intercept flash into the parent")
	var flash: Node = _arena.get_child(children_before)
	assert_eq(flash.get_script(), InterceptFlash, "spawned child must be an intercept flash")


func test_contact_ignores_non_projectile_areas() -> void:
	var missile := _make_missile()
	var bystander := Area2D.new()
	_arena.add_child(bystander)
	missile._on_area_entered(bystander)
	assert_false(missile.is_queued_for_deletion(), "areas outside enemy_projectiles must be ignored")
	assert_false(bystander.is_queued_for_deletion(), "areas outside enemy_projectiles must not be destroyed")


func test_retarget_skips_claimed_projectiles() -> void:
	var missile := _make_missile(Vector2.ZERO)
	var claimed := _make_enemy_projectile(Vector2(20, 0))
	claimed.set_meta("intercepted", true)
	var unclaimed := _make_enemy_projectile(Vector2(80, 0))
	missile._on_target_lost()
	assert_eq(missile._target, unclaimed, "retargeting must skip projectiles already claimed by another missile")
	assert_true(unclaimed.has_meta("intercepted"), "retargeting must claim the newly acquired projectile")


func test_retarget_ignores_projectiles_out_of_range() -> void:
	var missile := _make_missile(Vector2.ZERO)
	var far_away := _make_enemy_projectile(Vector2(400, 0))  # beyond RETARGET_RANGE (250)
	missile._on_target_lost()
	assert_null(missile._target, "retargeting must ignore projectiles beyond RETARGET_RANGE")
	assert_false(far_away.has_meta("intercepted"), "out-of-range projectiles must not be claimed")


func test_no_target_self_destructs_after_grace_time() -> void:
	var missile := _make_missile()
	missile._on_target_lost()  # no projectiles anywhere -> fly straight, then fizzle
	missile._physics_process(0.6)  # > GRACE_TIME (0.5)
	assert_true(missile.is_queued_for_deletion(), "missile must self-destruct after GRACE_TIME with no target")


func test_expires_after_lifetime() -> void:
	var missile := _make_missile()
	var target := _make_enemy_projectile(Vector2(10000, 0))  # keeps grace path out of the picture
	missile.setup(320.0, target)
	missile._physics_process(2.1)  # > LIFETIME (2.0)
	assert_true(missile.is_queued_for_deletion(), "missile must expire after LIFETIME")
