extends Node2D
## Homing missiles - seek nearest enemy.

const PROJECTILE_SCENE := preload("res://scenes/bullets/bullet_missile.tscn")
const BASE_DAMAGE := 10.0
const SPEED := 180.0


func fire(owner_ship: Node2D, damage_mult: float = 1.0, target: Node2D = null) -> void:
	var missile: Area2D = PROJECTILE_SCENE.instantiate() as Area2D
	missile.global_position = owner_ship.global_position
	
	# Aim at target if provided, else use ship rotation
	var aim_angle: float = owner_ship.rotation
	if target and is_instance_valid(target):
		aim_angle = (target.global_position - owner_ship.global_position).angle()
	
	missile.rotation = aim_angle
	owner_ship.get_parent().add_child(missile)
	if missile.has_method("setup"):
		missile.setup(BASE_DAMAGE * damage_mult, SPEED, owner_ship)
	var dir = Vector2.RIGHT.rotated(aim_angle)
	DebugLog.log_info("WEAPON", "Missile fire | dir: %.2f,%.2f | angle: %.2f" % [dir.x, dir.y, aim_angle])
