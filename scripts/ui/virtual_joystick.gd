extends Control
## Virtual joystick for mobile. Emits input direction.

signal input_changed(direction: Vector2)

const DEADZONE := 0.2
const KNOB_RANGE := 40.0

@onready var _base: Control = $Base
@onready var _knob: Control = $Knob

var _base_center := Vector2.ZERO
var _dragging := false


func _ready() -> void:
	_base_center = size / 2
	if not DisplayServer.is_touchscreen_available():
		visible = false


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var e: InputEventScreenTouch = event as InputEventScreenTouch
		var canvas_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * e.position
		var local: Vector2 = get_global_transform_with_canvas().affine_inverse() * canvas_pos
		if e.pressed:
			if _base.get_global_rect().has_point(canvas_pos):
				_dragging = true
				_update_knob(local)
		else:
			_dragging = false
			_reset_knob()
	elif event is InputEventScreenDrag and _dragging:
		var e: InputEventScreenDrag = event as InputEventScreenDrag
		var canvas_pos: Vector2 = get_viewport().get_canvas_transform().affine_inverse() * e.position
		var local: Vector2 = get_global_transform_with_canvas().affine_inverse() * canvas_pos
		_update_knob(local)
	elif event is InputEventMouseButton:
		var e: InputEventMouseButton = event as InputEventMouseButton
		var local: Vector2 = get_local_mouse_position()
		if e.pressed:
			if _base.get_global_rect().has_point(get_global_mouse_position()):
				_dragging = true
				_update_knob(local)
		else:
			_dragging = false
			_reset_knob()
	elif event is InputEventMouseMotion and _dragging:
		_update_knob(get_local_mouse_position())


func _update_knob(local_pos: Vector2) -> void:
	var delta: Vector2 = local_pos - _base_center
	var dist: float = delta.length()
	var dir: Vector2 = delta.normalized() if dist > 0 else Vector2.ZERO
	if dist > KNOB_RANGE:
		delta = dir * KNOB_RANGE
	_knob.position = _base_center + delta - _knob.size / 2
	var out: Vector2 = dir * (min(dist, KNOB_RANGE) / KNOB_RANGE)
	if out.length() < DEADZONE:
		out = Vector2.ZERO
	input_changed.emit(out)


func _reset_knob() -> void:
	_knob.position = _base_center - _knob.size / 2
	input_changed.emit(Vector2.ZERO)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_base_center = size / 2
