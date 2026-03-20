extends Node2D
## Frontal blaster - straight projectile, medium fire rate.

const PROJECTILE_SCENE := preload("res://scenes/bullets/bullet_blaster.tscn")
const BASE_DAMAGE := 18.0
const SPEED := 300.0


func fire(owner_ship: Node2D, damage_mult: float = 1.0, target: Node2D = null) -> void:
	var bullet: Area2D = PROJECTILE_SCENE.instantiate() as Area2D
	bullet.global_position = owner_ship.global_position
	
	# Aim at target if provided, else use ship rotation
	var aim_angle: float = owner_ship.rotation
	if target and is_instance_valid(target):
		aim_angle = (target.global_position - owner_ship.global_position).angle()
	
	bullet.rotation = aim_angle
	owner_ship.get_parent().add_child(bullet)
	if has_node("/root/SoundManager"):
		get_node("/root/SoundManager").play_shoot_sound()
	if bullet.has_method("setup"):
		bullet.setup(BASE_DAMAGE * damage_mult, SPEED, owner_ship)
	var dir = Vector2.RIGHT.rotated(aim_angle)
	DebugLog.log_info("WEAPON", "Blaster fire | dir: %.2f,%.2f | angle: %.2f" % [dir.x, dir.y, aim_angle])
