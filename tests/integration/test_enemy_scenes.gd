extends GutTest
## Integration tests: every enemy scene must carry the parametric visual
## and no legacy ColorRect placeholder. Guards the art migration.

const EnemyVisual := preload("res://scripts/enemies/enemy_visual.gd")

## scene path -> [expected shape_type, expected palette color]
var _expected := {
	"res://scenes/enemies/enemy_drone.tscn": [EnemyVisual.ShapeType.CIRCLE, Palette.ENEMY_CHASER],
	"res://scenes/enemies/enemy_kamikaze.tscn": [EnemyVisual.ShapeType.TRIANGLE, Palette.ENEMY_FAST],
	"res://scenes/enemies/enemy_tank.tscn": [EnemyVisual.ShapeType.HEXAGON, Palette.ENEMY_CHASER],
	"res://scenes/enemies/enemy_ranged.tscn": [EnemyVisual.ShapeType.DIAMOND, Palette.ENEMY_RANGED],
	"res://scenes/enemies/enemy_interceptor.tscn": [EnemyVisual.ShapeType.CHEVRON, Palette.ENEMY_FAST],
	"res://scenes/enemies/enemy_boss.tscn": [EnemyVisual.ShapeType.BOSS, Palette.BOSS],
}


func test_all_enemy_scenes_use_enemy_visual() -> void:
	for path in _expected:
		var enemy: Node = add_child_autofree(load(path).instantiate())
		var visual: Node = enemy.get_node_or_null("EnemyVisual")
		assert_not_null(visual, "%s must have an EnemyVisual node" % path)
		if visual:
			assert_eq(visual.shape_type, _expected[path][0], "%s: wrong shape" % path)
			assert_eq(visual.body_color, _expected[path][1], "%s: wrong color" % path)


func test_no_enemy_scene_keeps_colorrect_placeholder() -> void:
	for path in _expected:
		var enemy: Node = add_child_autofree(load(path).instantiate())
		assert_null(enemy.get_node_or_null("Sprite"), "%s must not keep the ColorRect placeholder" % path)


func test_boss_keeps_health_bar() -> void:
	var boss: Node = add_child_autofree(load("res://scenes/enemies/enemy_boss.tscn").instantiate())
	assert_not_null(boss.get_node_or_null("HealthBar"), "Boss HealthBar must survive the art migration")
