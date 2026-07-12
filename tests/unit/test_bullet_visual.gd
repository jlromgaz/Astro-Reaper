extends GutTest
## Unit tests for the parametric bullet visual (scripts/bullets/bullet_visual.gd).
## Style rule under test: player projectiles are elongated and cyan-family,
## enemy projectiles are round and hot-colored. Written BEFORE implementation.

const BulletVisual := preload("res://scripts/bullets/bullet_visual.gd")


func _make_visual(style: int) -> Node2D:
	var parent := Area2D.new()
	var visual: Node2D = BulletVisual.new()
	visual.name = "BulletVisual"
	visual.style = style
	parent.add_child(visual)
	add_child_autofree(parent)
	return visual


func test_bolt_uses_player_bullet_color() -> void:
	var visual := _make_visual(BulletVisual.Style.BOLT)
	assert_eq(visual.body_color, Palette.BULLET_PLAYER)


func test_beam_uses_player_bullet_color() -> void:
	var visual := _make_visual(BulletVisual.Style.BEAM)
	assert_eq(visual.body_color, Palette.BULLET_PLAYER)


func test_missile_uses_player_bullet_color() -> void:
	var visual := _make_visual(BulletVisual.Style.MISSILE)
	assert_eq(visual.body_color, Palette.BULLET_PLAYER)


func test_orb_uses_enemy_bullet_color() -> void:
	var visual := _make_visual(BulletVisual.Style.ORB)
	assert_eq(visual.body_color, Palette.BULLET_ENEMY)


func test_default_dimensions_follow_style() -> void:
	var bolt := _make_visual(BulletVisual.Style.BOLT)
	var beam := _make_visual(BulletVisual.Style.BEAM)
	assert_gt(beam.length, bolt.length, "Beam must be longer than bolt by default")
