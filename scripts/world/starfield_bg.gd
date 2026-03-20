extends Node2D
## Infinite scrolling starfield background.
## Stars are repositioned relative to the camera to create illusion of infinite space.

const STAR_COUNT := 80
const FIELD_SIZE := 600.0  # Half-size of the star area around camera
const PARALLAX_FACTOR := 0.3  # Stars move slower than camera = depth illusion

var _stars: Array[Dictionary] = []
var _camera: Camera2D


func _ready() -> void:
	z_index = -10
	# Generate random stars
	for i in range(STAR_COUNT):
		var star := {
			"offset": Vector2(randf_range(-FIELD_SIZE, FIELD_SIZE), randf_range(-FIELD_SIZE, FIELD_SIZE)),
			"size": randf_range(0.5, 2.0),
			"brightness": randf_range(0.3, 1.0),
			"parallax": randf_range(0.1, PARALLAX_FACTOR),
		}
		_stars.append(star)


func _process(_delta: float) -> void:
	if not _camera:
		_camera = get_viewport().get_camera_2d()
		if not _camera:
			return
	queue_redraw()


func _draw() -> void:
	if not _camera:
		return
	var cam_pos: Vector2 = _camera.global_position
	
	# Draw background fill based on Stitch 'surface' color
	draw_rect(Rect2(cam_pos - Vector2(FIELD_SIZE, FIELD_SIZE), Vector2(FIELD_SIZE * 2, FIELD_SIZE * 2)), Color("#17111b"))
	
	for star in _stars:
		# Apply parallax: stars closer to camera (lower parallax) move less
		var world_pos: Vector2 = star.offset + cam_pos * (1.0 - star.parallax)
		# Wrap stars to stay within view range
		var rel := world_pos - cam_pos
		rel.x = fmod(rel.x + FIELD_SIZE, FIELD_SIZE * 2.0) - FIELD_SIZE
		rel.y = fmod(rel.y + FIELD_SIZE, FIELD_SIZE * 2.0) - FIELD_SIZE
		var draw_pos: Vector2 = rel + cam_pos - global_position
		
		# Primarily Cyan stars (#00dddd) with rare Pink (#ffabf3)
		var base_color := Color("#00dddd") if randf() > 0.1 else Color("#ffabf3")
		var alpha: float = star.brightness
		var color := Color(base_color.r, base_color.g, base_color.b, alpha)
		draw_circle(draw_pos, star.size, color)
