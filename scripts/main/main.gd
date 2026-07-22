extends Node2D
## Main game scene. Wires joystick to player, starts game, spawns enemies.
## Receives selected ship data from GameManager.

@onready var game_world: Node2D = $GameWorld
@onready var player: CharacterBody2D = $GameWorld/Player
@onready var joystick: Control = get_node_or_null("VirtualJoystick")
@onready var spawner: Node2D = $GameWorld/EnemySpawner

var _spawner_script: Node


func _ready() -> void:
	_setup_input_actions()
	
	# Robust Joystick discovery (fallbacks if moved/renamed)
	if not joystick:
		joystick = find_child("VirtualJoystick*", true, false)
	
	if joystick and joystick.has_signal("input_changed"):
		joystick.input_changed.connect(_on_joystick_input)
	
	$GameWorld/Camera2D.make_current()
	$GameWorld/Camera2D.position_smoothing_enabled = true
	_add_spawner_script()
	_spawner_script = spawner.get_node_or_null("SpawnerScript")
	if _spawner_script:
		if _spawner_script.has_method("set_player"):
			_spawner_script.set_player(player)
		if _spawner_script.has_method("set_world"):
			_spawner_script.set_world(game_world)
	
	# Initialize player with selected ship data
	if GameManager.selected_ship and player.has_method("initialize_ship"):
		player.initialize_ship(GameManager.selected_ship)
	
	GameManager.start_game()


func _setup_input_actions() -> void:
	for action in ["move_up", "move_down", "move_left", "move_right"]:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
	var keys: Dictionary = {"move_up": KEY_W, "move_down": KEY_S, "move_left": KEY_A, "move_right": KEY_D}
	for action in keys:
		var ev: InputEventKey = InputEventKey.new()
		ev.keycode = keys[action]
		InputMap.action_add_event(action, ev)
	var arrows: Dictionary = {"move_up": KEY_UP, "move_down": KEY_DOWN, "move_left": KEY_LEFT, "move_right": KEY_RIGHT}
	for action in arrows:
		var ev: InputEventKey = InputEventKey.new()
		ev.keycode = arrows[action]
		InputMap.action_add_event(action, ev)


func _add_spawner_script() -> void:
	var spawner_script: Node = preload("res://scripts/systems/enemy_spawner.gd").new()
	spawner_script.name = "SpawnerScript"
	spawner.add_child(spawner_script)
	_spawner_script = spawner_script
	if _spawner_script.has_method("set_player"):
		_spawner_script.set_player(player)
	if _spawner_script.has_method("set_world"):
		_spawner_script.set_world(game_world)


var _keyboard_was_active := false


func _process(_delta: float) -> void:
	if player:
		$GameWorld/Camera2D.global_position = player.global_position
	# Keyboard writes ONLY while keys are held (plus one zero on release so
	# the ship stops on desktop). An OS.get_name() platform check used to
	# gate this, but a phone browser reports "Web" — the idle keyboard then
	# stomped set_move_input(ZERO) over the joystick every frame, so ships
	# only moved while the finger was actively dragging.
	var key_input: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		key_input.x += 1
	if Input.is_action_pressed("move_left"):
		key_input.x -= 1
	if Input.is_action_pressed("move_down"):
		key_input.y += 1
	if Input.is_action_pressed("move_up"):
		key_input.y -= 1
	if key_input != Vector2.ZERO:
		player.set_move_input(key_input.normalized())
		_keyboard_was_active = true
	elif _keyboard_was_active:
		player.set_move_input(Vector2.ZERO)
		_keyboard_was_active = false


func _on_joystick_input(direction: Vector2) -> void:
	if player and player.has_method("set_move_input"):
		player.set_move_input(direction)
