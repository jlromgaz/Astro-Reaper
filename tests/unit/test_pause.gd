extends GutTest
## Tests for the pause system: GameManager state toggle and HUD pause panel.

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func after_each() -> void:
	get_tree().paused = false
	GameManager.current_state = GameManager.State.MENU


## --- GameManager.toggle_pause ---

func test_toggle_pause_from_playing_pauses_tree() -> void:
	GameManager.current_state = GameManager.State.PLAYING
	GameManager.toggle_pause()
	assert_eq(GameManager.current_state, GameManager.State.PAUSED)
	assert_true(get_tree().paused, "Tree must pause when entering PAUSED state")


func test_toggle_pause_twice_resumes() -> void:
	GameManager.current_state = GameManager.State.PLAYING
	GameManager.toggle_pause()
	GameManager.toggle_pause()
	assert_eq(GameManager.current_state, GameManager.State.PLAYING)
	assert_false(get_tree().paused, "Tree must resume on second toggle")


func test_toggle_pause_is_noop_outside_gameplay() -> void:
	GameManager.current_state = GameManager.State.MENU
	GameManager.toggle_pause()
	assert_eq(GameManager.current_state, GameManager.State.MENU)
	assert_false(get_tree().paused, "Pause must not trigger from the menu")


## --- HUD wiring ---

func test_hud_pause_panel_hidden_by_default() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	assert_true(hud.pause_panel is PanelContainer)
	assert_false(hud.pause_panel.visible)


func test_hud_pause_buttons_are_wired() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	assert_true(hud.pause_btn.pressed.is_connected(hud._on_pause_toggle))
	assert_true(hud.resume_btn.pressed.is_connected(hud._on_pause_toggle))
	assert_true(hud.pause_quit_btn.pressed.is_connected(hud._on_restart))


func test_pause_toggle_shows_and_hides_panel() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	GameManager.current_state = GameManager.State.PLAYING
	hud._on_pause_toggle()
	assert_true(hud.pause_panel.visible, "Panel must show when pausing")
	hud._on_pause_toggle()
	assert_false(hud.pause_panel.visible, "Panel must hide when resuming")
