extends GutTest
## Player blaster bolts (bullet_blaster.gd) had NO lifetime either — same
## unbounded-accumulation bug as the enemy projectile, just less visible
## since most hit something. A miss must still expire eventually.

const BULLET_SCENE := preload("res://scenes/bullets/bullet_blaster.tscn")


func test_bullet_has_a_finite_lifetime() -> void:
	var bullet := BULLET_SCENE.instantiate() as Area2D
	add_child_autofree(bullet)
	assert_true("LIFETIME" in bullet, "player bullet must declare a LIFETIME")
	assert_gt(bullet.LIFETIME, 0.0)


func test_bullet_survives_before_its_lifetime_expires() -> void:
	var bullet := BULLET_SCENE.instantiate() as Area2D
	add_child_autofree(bullet)
	bullet.setup(10.0, 300.0, null)
	bullet._physics_process(bullet.LIFETIME - 0.5)
	assert_true(is_instance_valid(bullet), "must not expire early")


func test_bullet_expires_after_its_lifetime() -> void:
	var bullet := BULLET_SCENE.instantiate() as Area2D
	add_child(bullet)
	bullet.setup(10.0, 300.0, null)
	bullet._physics_process(bullet.LIFETIME + 0.1)
	await get_tree().process_frame
	assert_false(is_instance_valid(bullet), "a missed player bullet must eventually queue_free itself")
