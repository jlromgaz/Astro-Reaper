extends Control
## Static ship silhouette preview for the ship selection panel.
## Call set_ship(ship_id) to update. Scales the same body points
## from player_ship_visual.gd to fit the control size.

const SCALE := 3.5

var _ship_id: String = "stellar"
var _color: Color = Palette.PLAYER_CORE


func set_ship(ship_id: String, color: Color = Palette.PLAYER_CORE) -> void:
	_ship_id = ship_id
	_color = color
	queue_redraw()


func _draw() -> void:
	var pts := _body_points()
	if pts.is_empty():
		return
	var center := size / 2.0
	var scaled := PackedVector2Array()
	for p in pts:
		scaled.append(center + p * SCALE)
	draw_colored_polygon(scaled, _color)
	draw_polyline(scaled + PackedVector2Array([scaled[0]]), Color(Palette.UI_ACCENT, 0.9), 1.5)


func _body_points() -> PackedVector2Array:
	match _ship_id:
		"vanguard":
			return PackedVector2Array([
				Vector2(12, 0), Vector2(3, 10), Vector2(-10, 7),
				Vector2(-10, -7), Vector2(3, -10),
			])
		"interceptor":
			return PackedVector2Array([
				Vector2(17, 0), Vector2(-9, 5), Vector2(-5, 0), Vector2(-9, -5),
			])
		"phantom":
			return PackedVector2Array([
				Vector2(13, 0), Vector2(-3, 4), Vector2(-11, 10),
				Vector2(-6, 0), Vector2(-11, -10), Vector2(-3, -4),
			])
		_:  # stellar
			return PackedVector2Array([
				Vector2(14, 0), Vector2(-10, 9), Vector2(-6, 0), Vector2(-10, -9),
			])
