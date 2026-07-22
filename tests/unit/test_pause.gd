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
	assert_true(hud.pause_quit_btn.pressed.is_connected(hud._on_pause_quit))


## --- Voluntary end-run (was a silent abandon-without-saving quit) ---

func test_pause_quit_ends_the_run_instead_of_silently_abandoning() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	GameManager.current_state = GameManager.State.PAUSED
	watch_signals(EventBus)
	hud._on_pause_quit()
	assert_signal_emitted_with_parameters(EventBus, "game_ended", ["quit"])
	assert_false(hud.pause_panel.visible, "Pause panel must close when ending the run")


func test_pause_toggle_shows_and_hides_panel() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	GameManager.current_state = GameManager.State.PLAYING
	hud._on_pause_toggle()
	assert_true(hud.pause_panel.visible, "Panel must show when pausing")
	hud._on_pause_toggle()
	assert_false(hud.pause_panel.visible, "Panel must hide when resuming")


## --- Music/SFX mute toggles (inside the pause panel) ---

func after_each_audio() -> void:
	Settings.set_music_enabled(true)
	Settings.set_sfx_enabled(true)


func test_music_and_sfx_toggle_buttons_are_wired() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	assert_true(hud.music_toggle_btn.pressed.is_connected(hud._on_music_toggle))
	assert_true(hud.sfx_toggle_btn.pressed.is_connected(hud._on_sfx_toggle))
	after_each_audio()


func test_music_toggle_button_flips_settings_and_sound_manager() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	Settings.set_music_enabled(true)
	hud._on_music_toggle()
	assert_false(Settings.get_music_enabled(), "First press must disable music")
	assert_false(SoundManager._music_enabled)
	hud._on_music_toggle()
	assert_true(Settings.get_music_enabled(), "Second press must re-enable music")
	after_each_audio()


func test_sfx_toggle_button_flips_settings_and_sound_manager() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	Settings.set_sfx_enabled(true)
	hud._on_sfx_toggle()
	assert_false(Settings.get_sfx_enabled(), "First press must disable SFX")
	assert_false(SoundManager._sfx_enabled)
	hud._on_sfx_toggle()
	assert_true(Settings.get_sfx_enabled(), "Second press must re-enable SFX")
	after_each_audio()


func test_music_and_sfx_toggles_are_independent() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	hud._on_music_toggle()
	assert_false(Settings.get_music_enabled())
	assert_true(Settings.get_sfx_enabled(), "Toggling music must not affect SFX")
	after_each_audio()


func test_audio_toggle_button_labels_reflect_state() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	Settings.set_music_enabled(true)
	Settings.set_sfx_enabled(false)
	hud._update_audio_toggle_buttons()
	assert_string_contains(hud.music_toggle_btn.text, "ON")
	assert_string_contains(hud.sfx_toggle_btn.text, "OFF")
	after_each_audio()
