extends Control
## Minimap — Shows uncollected drops (XP, health) relative to player.
## Positioned at top-right of HUD.

const MAP_SIZE := 80.0  # pixels
const MAP_RANGE := 500.0  # world units radius shown

var _player: Node2D


func _ready() -> void:
	custom_minimum_size = Vector2(MAP_SIZE, MAP_SIZE)
	EventBus.player_spawned.connect(func(p): _player = p)


func _draw() -> void:
	# Background
	draw_rect(Rect2(Vector2.ZERO, Vector2(MAP_SIZE, MAP_SIZE)), Color(0.05, 0.05, 0.15, 0.7))
	draw_rect(Rect2(Vector2.ZERO, Vector2(MAP_SIZE, MAP_SIZE)), Color(0.2, 0.5, 0.8, 0.4), false, 1.0)
	
	if not _player or not is_instance_valid(_player):
		return
	
	var center := Vector2(MAP_SIZE / 2.0, MAP_SIZE / 2.0)
	var scale_factor: float = (MAP_SIZE / 2.0) / MAP_RANGE
	var player_pos: Vector2 = _player.global_position
	
	# Draw player dot (white center)
	draw_circle(center, 2.0, Color.WHITE)
	
	# Draw pickups
	var pickups := get_tree().get_nodes_in_group("pickups")
	for pickup in pickups:
		if not is_instance_valid(pickup) or not pickup is Node2D:
			continue
		var offset: Vector2 = (pickup.global_position - player_pos) * scale_factor
		if abs(offset.x) > MAP_SIZE / 2.0 or abs(offset.y) > MAP_SIZE / 2.0:
			continue
		var dot_pos: Vector2 = center + offset
		# Color by type
		var dot_color := Color.GREEN  # XP default
		if pickup.is_in_group("health_pickups"):
			dot_color = Color.RED
		draw_circle(dot_pos, 1.5, dot_color)
	
	# Draw comets (yellow)
	var comets := get_tree().get_nodes_in_group("comets")
	for comet in comets:
		if not is_instance_valid(comet) or not comet is Node2D:
			continue
		var offset: Vector2 = (comet.global_position - player_pos) * scale_factor
		if abs(offset.x) > MAP_SIZE / 2.0 or abs(offset.y) > MAP_SIZE / 2.0:
			continue
		var dot_pos: Vector2 = center + offset
		draw_circle(dot_pos, 2.0, Color.YELLOW)
	
	# Draw boss (magenta, larger)
	var bosses := get_tree().get_nodes_in_group("boss")
	for boss in bosses:
		if not is_instance_valid(boss) or not boss is Node2D:
			continue
		var offset: Vector2 = (boss.global_position - player_pos) * scale_factor
		if abs(offset.x) > MAP_SIZE / 2.0 or abs(offset.y) > MAP_SIZE / 2.0:
			continue
		var dot_pos: Vector2 = center + offset
		draw_circle(dot_pos, 3.0, Color.MAGENTA)


func _process(_delta: float) -> void:
	queue_redraw()
