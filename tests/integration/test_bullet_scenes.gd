extends GutTest
## Integration tests: every bullet scene must carry the parametric visual.
## Round silhouette is reserved for enemy projectiles (readability rule).

const BulletVisual := preload("res://scripts/bullets/bullet_visual.gd")

## scene path -> expected style
var _expected := {
	"res://scenes/bullets/bullet_blaster.tscn": BulletVisual.Style.BOLT,
	"res://scenes/bullets/bullet_laser.tscn": BulletVisual.Style.BEAM,
	"res://scenes/bullets/bullet_missile.tscn": BulletVisual.Style.MISSILE,
	"res://scenes/bullets/bullet_enemy.tscn": BulletVisual.Style.ORB,
}


func test_all_bullet_scenes_use_bullet_visual() -> void:
	for path in _expected:
		var bullet: Node = add_child_autofree(load(path).instantiate())
		var visual: Node = bullet.get_node_or_null("BulletVisual")
		assert_not_null(visual, "%s must have a BulletVisual node" % path)
		if visual:
			assert_eq(visual.style, _expected[path], "%s: wrong style" % path)


func test_no_bullet_scene_keeps_colorrect_placeholder() -> void:
	for path in _expected:
		var bullet: Node = add_child_autofree(load(path).instantiate())
		assert_null(bullet.get_node_or_null("Sprite"), "%s must not keep the ColorRect placeholder" % path)


func test_only_enemy_bullet_is_round() -> void:
	for path in _expected:
		var bullet: Node = add_child_autofree(load(path).instantiate())
		var visual: Node = bullet.get_node_or_null("BulletVisual")
		if visual == null:
			continue
		if path.contains("enemy"):
			assert_eq(visual.style, BulletVisual.Style.ORB, "Enemy bullet must be round")
		else:
			assert_ne(visual.style, BulletVisual.Style.ORB, "Player bullets must not be round")
