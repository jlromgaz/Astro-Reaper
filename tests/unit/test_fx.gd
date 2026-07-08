extends GutTest
## Unit tests for death burst FX and camera shake (FXManager autoload).
## Written BEFORE implementation.

const DeathBurst := preload("res://scripts/fx/death_burst.gd")


func test_fx_manager_autoload_exists() -> void:
	assert_not_null(get_node_or_null("/root/FXManager"), "FXManager must be registered as autoload")


func test_death_burst_frees_itself_after_lifetime() -> void:
	var burst: Node2D = DeathBurst.new()
	add_child(burst)
	assert_true(is_instance_valid(burst))
	await get_tree().create_timer(DeathBurst.LIFETIME + 0.2).timeout
	assert_false(is_instance_valid(burst), "Death burst must free itself after its lifetime")


func test_enemy_killed_spawns_death_burst() -> void:
	var fx: Node = get_node("/root/FXManager")
	var enemy := CharacterBody2D.new()
	add_child_autofree(enemy)
	var before: int = fx.get_child_count()
	EventBus.enemy_killed.emit(enemy, Vector2(100, 50))
	assert_eq(fx.get_child_count(), before + 1, "enemy_killed must spawn one burst under FXManager")
	# Cleanup: remove spawned bursts so they don't leak between tests
	for child in fx.get_children():
		child.free()


func test_shake_offsets_current_camera_and_recovers() -> void:
	var fx: Node = get_node("/root/FXManager")
	var cam := Camera2D.new()
	add_child_autofree(cam)
	cam.make_current()
	fx.shake(3.0, 0.2)
	fx._process(1.0 / 60.0)
	assert_ne(cam.offset, Vector2.ZERO, "Shake must offset the camera")
	# Exhaust the shake
	for i in range(30):
		fx._process(1.0 / 60.0)
	assert_eq(cam.offset, Vector2.ZERO, "Camera must recover to zero offset after shake ends")
