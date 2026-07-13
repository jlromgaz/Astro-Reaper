extends Control
## Dynamic floating joystick: invisible at rest, appears at the touch point.
## Each new press repositions the joystick; releasing hides it again.

signal input_changed(direction: Vector2)

const DEADZONE    := 0.06   # near-instant direction response
const KNOB_RANGE  := 30.0   # 30 px travel = full speed (was 70)
const BASE_RADIUS := 50.0   # visual ring radius
const KNOB_RADIUS := 18.0   # knob radius

@onready var _base: Control = $Base
@onready var _knob: Control = $Knob

var _base_center  := Vector2.ZERO
var _dragging     := false
var _touch_index  := -1


func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		visible = false
		return
	_base.visible = false
	_knob.visible = false


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if get_viewport().is_input_handled():
		return
	if event is InputEventScreenTouch:
		_on_screen_touch(event)
	elif event is InputEventScreenDrag:
		if event.index == _touch_index and _dragging:
			_update_knob(_to_local(event.position))
	elif event is InputEventMouseButton:
		_on_mouse_button(event)
	elif event is InputEventMouseMotion and _dragging:
		_update_knob(_to_local(event.position))


func _on_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		if _touch_index >= 0:
			return
		_touch_index = event.index
		_dragging = true
		_show_at(_to_local(event.position))
	elif event.index == _touch_index:
		_touch_index = -1
		_dragging = false
		_hide()


func _on_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed:
		if _dragging:
			return
		_dragging = true
		_show_at(_to_local(event.position))
	else:
		_dragging = false
		_hide()


func _show_at(local_pos: Vector2) -> void:
	_base_center = local_pos
	_base.set_size(Vector2(BASE_RADIUS * 2.0, BASE_RADIUS * 2.0))
	_base.position = local_pos - Vector2(BASE_RADIUS, BASE_RADIUS)
	_base.visible = true
	_knob.set_size(Vector2(KNOB_RADIUS * 2.0, KNOB_RADIUS * 2.0))
	_knob.position = local_pos - Vector2(KNOB_RADIUS, KNOB_RADIUS)
	_knob.visible = true
	input_changed.emit(Vector2.ZERO)


func _to_local(screen_pos: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * screen_pos


func _update_knob(local_pos: Vector2) -> void:
	var delta: Vector2 = local_pos - _base_center
	var dist: float    = delta.length()
	var dir: Vector2   = delta.normalized() if dist > 0.0 else Vector2.ZERO
	if dist > KNOB_RANGE:
		delta = dir * KNOB_RANGE
	_knob.position = _base_center + delta - Vector2(KNOB_RADIUS, KNOB_RADIUS)
	var out: Vector2 = dir * (minf(dist, KNOB_RANGE) / KNOB_RANGE)
	if out.length() < DEADZONE:
		out = Vector2.ZERO
	input_changed.emit(out)


func _hide() -> void:
	_base.visible = false
	_knob.visible = false
	input_changed.emit(Vector2.ZERO)
