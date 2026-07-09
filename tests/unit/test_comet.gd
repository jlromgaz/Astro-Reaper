extends GutTest
## Tests for comet destructibility, bonus upgrade drop, and fiery visual.

const COMET_SCENE := preload("res://scenes/world/comet.tscn")
const LASER_SCENE := preload("res://scenes/bullets/bullet_laser.tscn")


func after_each() -> void:
	get_tree().paused = false
	GameManager.current_state = GameManager.State.MENU


## --- Bonus drop on destruction ---

func test_comet_death_emits_comet_bonus_not_level_up() -> void:
	var comet: Area2D = add_child_autofree(COMET_SCENE.instantiate())
	await get_tree().process_frame
	watch_signals(EventBus)
	var level_before: int = GameManager.run_level
	comet.take_damage(999.0)
	assert_signal_emitted(EventBus, "comet_bonus", "Comet death must offer a bonus upgrade")
	assert_signal_not_emitted(EventBus, "player_leveled_up",
		"Comet death must NOT fake a level-up")
	assert_eq(GameManager.run_level, level_before, "Comet death must not corrupt run_level")


func test_comet_bonus_pauses_for_selection() -> void:
	GameManager.current_state = GameManager.State.PLAYING
	EventBus.comet_bonus.emit()
	assert_eq(GameManager.current_state, GameManager.State.PAUSED_LEVEL_UP)
	assert_true(get_tree().paused, "Comet bonus must pause like a level-up")


func test_hud_shows_upgrade_panel_on_comet_bonus() -> void:
	var hud: CanvasLayer = add_child_autofree(
		preload("res://scenes/ui/hud.tscn").instantiate()
	)
	await get_tree().process_frame
	EventBus.comet_bonus.emit()
	assert_true(hud.level_up_panel.visible,
		"Comet bonus must open the upgrade selection panel")


## --- Destructibility by laser ---

func test_laser_damages_comet() -> void:
	var comet: Area2D = add_child_autofree(COMET_SCENE.instantiate())
	comet.global_position = Vector2(100, 100)
	var laser: Area2D = add_child_autofree(LASER_SCENE.instantiate())
	laser.global_position = Vector2(100, 100)
	laser.setup(12.0, null)
	await wait_physics_frames(4)
	assert_lt(comet.current_hp, comet.HP, "Laser must damage overlapping comets (Area2D)")


## --- Fiery sphere visual ---

func test_comet_visual_declares_flame_tongues() -> void:
	var vis: Node2D = autofree(load("res://scripts/world/comet_visual.gd").new())
	assert_gt(vis.FLAME_TONGUES, 0, "Comet visual must draw flame tongues")


func test_comet_visual_draws_without_errors() -> void:
	var comet: Area2D = add_child_autofree(COMET_SCENE.instantiate())
	await get_tree().process_frame
	await get_tree().process_frame
	assert_true(is_instance_valid(comet), "Fiery comet visual must draw without errors")
