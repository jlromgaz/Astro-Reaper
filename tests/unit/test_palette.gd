extends GutTest
## Regression tests for the Palette static class (scripts/core/palette.gd).


func test_core_colors_are_opaque() -> void:
	assert_eq(Palette.PLAYER_CORE.a, 1.0, "Player color must be fully opaque")
	assert_eq(Palette.ENEMY_CHASER.a, 1.0, "Enemy color must be fully opaque")
	assert_eq(Palette.BULLET_ENEMY.a, 1.0, "Enemy bullet color must be fully opaque")


func test_ui_panel_is_translucent() -> void:
	assert_lt(Palette.UI_PANEL.a, 1.0, "UI panel must be translucent")


func test_glow_of_lightens_and_fades() -> void:
	var glow := Palette.glow_of(Palette.PLAYER_CORE, 0.3)
	assert_almost_eq(glow.a, 0.3, 0.001, "Glow alpha must match requested alpha")
	assert_gt(glow.r + glow.g + glow.b, Palette.PLAYER_CORE.r + Palette.PLAYER_CORE.g + Palette.PLAYER_CORE.b,
		"Glow must be lighter than its base color")
