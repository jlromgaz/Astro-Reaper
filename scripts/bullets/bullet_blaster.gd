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
	if _owner_ship and "projectile_size_mult" in _owner_ship:
		scale *= _owner_ship.projectile_size_mult
	_direction = Vector2.RIGHT.rotated(rotation)
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)


func _physics_process(delta: float) -> void:
	position += _direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		_damage_entity(body)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		_damage_entity(area)


func _damage_entity(entity: Node) -> void:
	if entity.has_method("take_damage"):
		entity.take_damage(damage)
	queue_free()
