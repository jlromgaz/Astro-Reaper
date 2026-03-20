extends Area2D
## Homing missile - seeks nearest enemy and damages on hit.

var damage: float = 15.0
var speed: float = 180.0
var _owner_ship: Node2D
var _velocity := Vector2.ZERO
const HOMING_STRENGTH := 4.0
const LIFETIME := 4.0
var _lifetime_left: float = LIFETIME


func setup(dmg: float, spd: float, owner_ship: Node2D) -> void:
	damage = dmg
	speed = spd
	_owner_ship = owner_ship
	_velocity = Vector2.RIGHT.rotated(rotation) * speed
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_lifetime_left -= delta
	if _lifetime_left <= 0:
		queue_free()
		return

	var target := _find_nearest_enemy()
	if target:
		var to_target := (target.global_position - global_position).normalized()
		_velocity = _velocity.lerp(to_target * speed, HOMING_STRENGTH * delta).limit_length(speed)

	position += _velocity * delta
	rotation = _velocity.angle()


func _find_nearest_enemy() -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist := INF
	for node in enemies:
		var body := node as Node2D
		if not is_instance_valid(body):
			continue
		var d := global_position.distance_squared_to(body.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = body
	return nearest


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
