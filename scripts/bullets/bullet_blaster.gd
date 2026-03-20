extends Area2D
## Player blaster projectile.

var damage: float = 10.0
var speed: float = 300.0
var _direction := Vector2.RIGHT
var _owner_ship: Node2D

func setup(dmg: float, spd: float, owner_ship: Node2D) -> void:
	damage = dmg
	speed = spd
	_owner_ship = owner_ship
	_direction = Vector2.RIGHT.rotated(rotation)
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position += _direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
