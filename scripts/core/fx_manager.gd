extends Node
## FX manager (autoload) — spawns death bursts on enemy kills and applies
## subtle camera shake on player damage and boss spawn.
## Rules in docs/art-style-guide.md: no shake on regular kills.

const DeathBurst := preload("res://scripts/fx/death_burst.gd")

var _shake_time := 0.0
var _shake_duration := 0.0
var _shake_strength := 0.0


func _ready() -> void:
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.player_damaged.connect(_on_player_damaged)
	if EventBus.has_signal("boss_spawned"):
		EventBus.boss_spawned.connect(func(_boss = null): shake(3.0, 0.4))


func shake(strength: float, duration: float) -> void:
	_shake_strength = strength
	_shake_duration = duration
	_shake_time = duration


func _process(delta: float) -> void:
	if _shake_time <= 0.0:
		return
	var cam := get_viewport().get_camera_2d()
	if not cam:
		_shake_time = 0.0
		return
	_shake_time -= delta
	if _shake_time <= 0.0:
		cam.offset = Vector2.ZERO
		return
	var t := (_shake_duration - _shake_time) * 60.0
	var falloff := _shake_time / _shake_duration
	cam.offset = Vector2(sin(t * 1.3), cos(t * 1.7)) * _shake_strength * falloff


func _on_enemy_killed(enemy: Node, position: Vector2) -> void:
	var burst: Node2D = DeathBurst.new()
	burst.color = _color_of(enemy)
	add_child(burst)
	burst.global_position = position


func _on_player_damaged(_amount: float, _source: Node) -> void:
	shake(2.5, 0.2)


func _color_of(enemy: Node) -> Color:
	if not is_instance_valid(enemy):
		return Palette.EXPLOSION
	for visual_name in ["EnemyVisual", "CometVisual"]:
		var visual := enemy.get_node_or_null(visual_name)
		if visual and "body_color" in visual:
			return visual.body_color
	return Palette.EXPLOSION
