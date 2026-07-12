extends GutTest
## Tests for homing missile re-acquisition behavior.
## Missile must find a new target when its original target dies,
## and must survive its full LIFETIME even with no enemies present.

const MISSILE_SCENE := preload("res://scenes/bullets/bullet_missile.tscn")


## When the current target is lost (_on_target_lost called), the missile
## must set _target = null so re-acquisition can happen next frame.
func test_on_target_lost_clears_target() -> void:
	var missile := MISSILE_SCENE.instantiate() as Area2D
	add_child_autofree(missile)
	var dummy := Node2D.new()
	dummy.add_to_group("enemies")
	add_child_autofree(dummy)
	missile._target = dummy
	missile._on_target_lost()
	assert_null(missile._target, "_on_target_lost must clear _target to null")


## After target is cleared, one physics frame must cause the missile to
## re-acquire the nearest enemy.
func test_reacquires_target_after_loss() -> void:
	var missile := MISSILE_SCENE.instantiate() as Area2D
	add_child_autofree(missile)
	var target_b := Node2D.new()
	target_b.add_to_group("enemies")
	add_child_autofree(target_b)
	missile._target = null
	missile._lifetime_left = 4.0  # fresh lifetime constant
	missile._physics_process(0.016)
	assert_not_null(missile._target, "missile must re-acquire an available enemy after target loss")


## With no enemies in the scene, missile must survive past TARGET_TIMEOUT (2s).
## Before fix: missile dies at TARGET_TIMEOUT. After fix: lives full LIFETIME.
func test_missile_survives_past_target_timeout_with_no_enemies() -> void:
	var missile := MISSILE_SCENE.instantiate() as Area2D
	add_child_autofree(missile)
	missile._physics_process(2.1)
	assert_true(is_instance_valid(missile), "missile must NOT die at TARGET_TIMEOUT when no enemies present")


## Missile must still expire after its full LIFETIME regardless of targets.
func test_missile_expires_after_full_lifetime() -> void:
	var missile := MISSILE_SCENE.instantiate() as Area2D
	add_child(missile)
	missile._physics_process(4.1)
	await get_tree().process_frame
	assert_false(is_instance_valid(missile), "missile must queue_free after LIFETIME (4s)")
