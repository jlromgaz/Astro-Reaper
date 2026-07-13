extends Control
## Minimap — Shows uncollected drops (XP, health) relative to player.
## Positioned at top-right of HUD. Draws to the control's actual size.

const MAP_RANGE := 500.0  # world units radius shown
const MOBILE_SIZE := 90.0

var _player: Node2D


func _ready() -> void:
	# Mobile keeps the 480x270 design space — the 160px desktop map would eat
	# 60% of the screen height there, so shrink it.
	if DisplayServer.is_touchscreen_available():
		offset_left = offset_right - MOBILE_SIZE
		offset_bottom = offset_top + MOBILE_SIZE
	EventBus.player_spawned.connect(func(p): _player = p)


func _draw() -> void:
	var map_size := minf(size.x, size.y)
	# Background
	draw_rect(Rect2(Vector2.ZERO, Vector2(map_size, map_size)), Color(Palette.BG_NEBULA, 0.7))
	draw_rect(Rect2(Vector2.ZERO, Vector2(map_size, map_size)), Color(Palette.UI_ACCENT, 0.4), false, 1.0)

	if not _player or not is_instance_valid(_player):
		return

	var center := Vector2(map_size / 2.0, map_size / 2.0)
	var scale_factor: float = (map_size / 2.0) / MAP_RANGE
	var player_pos: Vector2 = _player.global_position

	# Draw player dot (bright center)
	draw_circle(center, 2.5, Palette.UI_TEXT)

	# Draw pickups
	var pickups := get_tree().get_nodes_in_group("pickups")
	for pickup in pickups:
		if not is_instance_valid(pickup) or not pickup is Node2D:
			continue
		var offset: Vector2 = (pickup.global_position - player_pos) * scale_factor
		if abs(offset.x) > map_size / 2.0 or abs(offset.y) > map_size / 2.0:
			continue
		var dot_pos: Vector2 = center + offset
		# Color by type
		var dot_color := Palette.XP_GEM
		if pickup.is_in_group("health_pickups"):
			dot_color = Palette.HEALTH
		draw_circle(dot_pos, 2.0, dot_color)

	# Draw comets (yellow)
	var comets := get_tree().get_nodes_in_group("comets")
	for comet in comets:
		if not is_instance_valid(comet) or not comet is Node2D:
			continue
		var offset: Vector2 = (comet.global_position - player_pos) * scale_factor
		if abs(offset.x) > map_size / 2.0 or abs(offset.y) > map_size / 2.0:
			continue
		var dot_pos: Vector2 = center + offset
		draw_circle(dot_pos, 2.5, Palette.COMET)

	# Draw boss (magenta, larger & pulsating)
	var bosses := get_tree().get_nodes_in_group("boss")
	for boss in bosses:
		if not is_instance_valid(boss) or not boss is Node2D:
			continue
		var offset: Vector2 = (boss.global_position - player_pos) * scale_factor
		if abs(offset.x) > map_size / 2.0 or abs(offset.y) > map_size / 2.0:
			# For boss, draw at edge if off-screen
			offset = offset.limit_length(map_size / 2.0 - 2.0)

		var dot_pos: Vector2 = center + offset
		var pulse: float = 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.01)
		draw_circle(dot_pos, 6.0, Color(Palette.BOSS, 0.5 + 0.5 * pulse))
		draw_circle(dot_pos, 2.5, Palette.BOSS)


func _process(_delta: float) -> void:
	queue_redraw()
