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


## --- Performance: BOLT (the most common bullet) has no animation, so it
## must not redraw every single frame — see test_enemy_visual.gd for the
## same optimization on the enemy side (mobile stutter with many on-screen).

func test_bolt_does_not_need_continuous_redraw() -> void:
	var visual := _make_visual(BulletVisual.Style.BOLT)
	assert_false(visual._needs_continuous_redraw(),
		"Bolt is a static shape with no pulse/flicker — no per-frame redraw needed")


func test_beam_needs_continuous_redraw_for_pulse() -> void:
	var visual := _make_visual(BulletVisual.Style.BEAM)
	assert_true(visual._needs_continuous_redraw())


func test_missile_needs_continuous_redraw_for_flame_flicker() -> void:
	var visual := _make_visual(BulletVisual.Style.MISSILE)
	assert_true(visual._needs_continuous_redraw())


func test_orb_needs_continuous_redraw_for_pulse() -> void:
	var visual := _make_visual(BulletVisual.Style.ORB)
	assert_true(visual._needs_continuous_redraw())


func test_mine_needs_continuous_redraw_for_pulse() -> void:
	var visual := _make_visual(BulletVisual.Style.MINE)
	assert_true(visual._needs_continuous_redraw())
