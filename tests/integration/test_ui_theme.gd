extends GutTest
## Integration tests: HUD and main menu must follow the master palette
## (docs/art-style-guide.md). Scene literals must stay in sync with Palette.


func _hud() -> Node:
	return add_child_autofree(load("res://scenes/ui/hud.tscn").instantiate())


func test_hp_bar_fill_uses_palette_hp() -> void:
	var bar: ProgressBar = _hud().get_node("HPBar")
	assert_true(bar.has_theme_stylebox_override("fill"), "HPBar must override its fill style")
	if bar.has_theme_stylebox_override("fill"):
		assert_eq(bar.get_theme_stylebox("fill").bg_color, Palette.UI_HP)


func test_xp_bar_fill_uses_palette_xp() -> void:
	var bar: ProgressBar = _hud().get_node("XPBar")
	assert_true(bar.has_theme_stylebox_override("fill"), "XPBar must override its fill style")
	if bar.has_theme_stylebox_override("fill"):
		assert_eq(bar.get_theme_stylebox("fill").bg_color, Palette.UI_XP)


func test_shield_bar_fill_uses_palette_shield() -> void:
	var bar: ProgressBar = _hud().get_node("ShieldBar")
	assert_true(bar.has_theme_stylebox_override("fill"), "ShieldBar must override its fill style")
	if bar.has_theme_stylebox_override("fill"):
		assert_eq(bar.get_theme_stylebox("fill").bg_color, Palette.SHIELD)


func test_level_up_panel_uses_palette_panel() -> void:
	var panel: PanelContainer = _hud().get_node("LevelUpPanel")
	assert_true(panel.has_theme_stylebox_override("panel"), "LevelUpPanel must override its panel style")
	if panel.has_theme_stylebox_override("panel"):
		var style: StyleBoxFlat = panel.get_theme_stylebox("panel")
		assert_eq(style.bg_color, Palette.UI_PANEL)
		assert_eq(style.border_color, Palette.UI_ACCENT)


func test_menu_background_uses_palette_bg_space() -> void:
	var menu: Node = add_child_autofree(load("res://scenes/ui/main_menu.tscn").instantiate())
	var bg: ColorRect = menu.get_node("Background")
	assert_eq(bg.color, Palette.BG_SPACE)


func test_menu_title_uses_palette_accent() -> void:
	var menu: Node = add_child_autofree(load("res://scenes/ui/main_menu.tscn").instantiate())
	var title: Label = menu.get_node("VBox/TitleLabel")
	assert_not_null(title.label_settings)
	if title.label_settings:
		assert_eq(title.label_settings.font_color, Palette.UI_ACCENT)
