extends GutTest
## Enemy projectiles (bullet_enemy.gd) had NO lifetime at all — a missed
## shot flew forever, accumulating without bound over a long run (reported:
## screen "full of enemy missiles" plus a real perf hit, since ORB-style
## bullets redraw every frame). Must expire like bullet_missile.gd already does.

const BULLET_SCENE := preload("res://scenes/bullets/bullet_enemy.tscn")


func test_bullet_has_a_finite_lifetime() -> void:
	var bullet := BULLET_SCENE.instantiate() as Area2D
	add_child_autofree(bullet)
	assert_true("LIFETIME" in bullet, "enemy bullet must declare a LIFETIME like the missile does")
	assert_gt(bullet.LIFETIME, 0.0)


func test_bullet_survives_before_its_lifetime_expires() -> void:
	var bullet := BULLET_SCENE.instantiate() as Area2D
	add_child_autofree(bullet)
	bullet.setup(4.0, 180.0, Vector2.RIGHT)
	bullet._physics_process(bullet.LIFETIME - 0.5)
	assert_true(is_instance_valid(bullet), "must not expire early")


func test_bullet_expires_after_its_lifetime() -> void:
	var bullet := BULLET_SCENE.instantiate() as Area2D
	add_child(bullet)
	bullet.setup(4.0, 180.0, Vector2.RIGHT)
	bullet._physics_process(bullet.LIFETIME + 0.1)
	await get_tree().process_frame
	assert_false(is_instance_valid(bullet), "a missed enemy bullet must eventually queue_free itself")
