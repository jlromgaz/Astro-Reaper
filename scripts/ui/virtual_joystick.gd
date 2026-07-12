extends Control
## Virtual joystick for mobile/web touch input.
## Fixed position at bottom-center; hidden on non-touchscreen platforms.

signal input_changed(direction: Vector2)

const DEADZONE := 0.15
const KNOB_RANGE := 70.0

@onready var _base: Control = $Base
@onready var _knob: Control = $Knob

var _base_center := Vector2.ZERO
var _dragging := false
var _touch_index := -1


func _ready() -> void:
	if not DisplayServer.is_touchscreen_available():
		visible = false
		return
	await get_tree().process_frame
	_base_center = size / 2
	_reset_knob()


func _input(event: InputEvent) -> void:
	if not visible:
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
		if _base.get_global_rect().has_point(_to_canvas(event.position)):
			_touch_index = event.index
			_dragging = true
			_update_knob(_to_local(event.position))
	elif event.index == _touch_index:
		_touch_index = -1
		_dragging = false
		_reset_knob()


func _on_mouse_button(event: InputEventMouseButton) -> void:
	if event.pressed:
		if _dragging:
			return
		if _base.get_global_rect().has_point(_to_canvas(event.position)):
			_dragging = true
			_update_knob(_to_local(event.position))
	else:
		_dragging = false
		_reset_knob()


func _to_local(screen_pos: Vector2) -> Vector2:
	return get_global_transform_with_canvas().affine_inverse() * screen_pos


func _to_canvas(screen_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_pos


func _update_knob(local_pos: Vector2) -> void:
	var delta: Vector2 = local_pos - _base_center
	var dist: float = delta.length()
	var dir: Vector2 = delta.normalized() if dist > 0.0 else Vector2.ZERO
	if dist > KNOB_RANGE:
		delta = dir * KNOB_RANGE
	_knob.position = _base_center + delta - _knob.size / 2
	var out: Vector2 = dir * (minf(dist, KNOB_RANGE) / KNOB_RANGE)
	if out.length() < DEADZONE:
		out = Vector2.ZERO
	input_changed.emit(out)


func _reset_knob() -> void:
	_knob.position = _base_center - _knob.size / 2
	input_changed.emit(Vector2.ZERO)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_base_center = size / 2
		_reset_knob()
