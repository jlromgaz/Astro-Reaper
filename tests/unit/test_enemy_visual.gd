extends GutTest
## Unit tests for the parametric enemy visual (scripts/enemies/enemy_visual.gd).
## Written BEFORE the implementation (TDD).

const EnemyVisual := preload("res://scripts/enemies/enemy_visual.gd")


func _make_parent_with_visual(shape: int, color_class: int) -> Array:
	var parent := CharacterBody2D.new()
	var visual: Node2D = EnemyVisual.new()
	visual.name = "EnemyVisual"
	visual.shape_type = shape
	visual.color_class = color_class
	parent.add_child(visual)
	add_child_autofree(parent)
	return [parent, visual]


## --- Color resolution from behavior class ---

func test_chaser_class_resolves_to_chaser_color() -> void:
	var pair := _make_parent_with_visual(EnemyVisual.ShapeType.CIRCLE, EnemyVisual.ColorClass.CHASER)
	assert_eq(pair[1].body_color, Palette.ENEMY_CHASER)


func test_fast_class_resolves_to_fast_color() -> void:
	var pair := _make_parent_with_visual(EnemyVisual.ShapeType.TRIANGLE, EnemyVisual.ColorClass.FAST)
	assert_eq(pair[1].body_color, Palette.ENEMY_FAST)


func test_ranged_class_resolves_to_ranged_color() -> void:
	var pair := _make_parent_with_visual(EnemyVisual.ShapeType.DIAMOND, EnemyVisual.ColorClass.RANGED)
	assert_eq(pair[1].body_color, Palette.ENEMY_RANGED)


func test_boss_class_resolves_to_boss_color() -> void:
	var pair := _make_parent_with_visual(EnemyVisual.ShapeType.BOSS, EnemyVisual.ColorClass.BOSS)
	assert_eq(pair[1].body_color, Palette.BOSS)


## --- Hit flash ---

func test_flashes_when_own_parent_is_damaged() -> void:
	var pair := _make_parent_with_visual(EnemyVisual.ShapeType.CIRCLE, EnemyVisual.ColorClass.CHASER)
	assert_eq(pair[1]._flash_timer, 0.0)
	EventBus.enemy_damaged.emit(pair[0], 5.0)
	assert_gt(pair[1]._flash_timer, 0.0, "Visual must flash when its parent takes damage")


func test_does_not_flash_when_other_enemy_is_damaged() -> void:
	var pair_a := _make_parent_with_visual(EnemyVisual.ShapeType.CIRCLE, EnemyVisual.ColorClass.CHASER)
	var pair_b := _make_parent_with_visual(EnemyVisual.ShapeType.CIRCLE, EnemyVisual.ColorClass.CHASER)
	EventBus.enemy_damaged.emit(pair_a[0], 5.0)
	assert_eq(pair_b[1]._flash_timer, 0.0, "Visual must ignore damage to other enemies")


## --- Velocity orientation ---

func test_directional_shape_orients_to_parent_velocity() -> void:
	var pair := _make_parent_with_visual(EnemyVisual.ShapeType.TRIANGLE, EnemyVisual.ColorClass.FAST)
	pair[0].velocity = Vector2(0.0, 100.0)  # Moving down: angle PI/2
	for i in range(180):
		pair[1]._process(1.0 / 60.0)
	assert_almost_eq(pair[1].rotation, PI / 2.0, 0.05, "Directional visual must point along velocity")


func test_non_directional_shape_keeps_rotation() -> void:
	var pair := _make_parent_with_visual(EnemyVisual.ShapeType.CIRCLE, EnemyVisual.ColorClass.CHASER)
	pair[0].velocity = Vector2(0.0, 100.0)
	for i in range(60):
		pair[1]._process(1.0 / 60.0)
	assert_eq(pair[1].rotation, 0.0, "Circle visual must never rotate")
