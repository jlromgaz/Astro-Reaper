extends Node2D
## Beam weapon - damages all enemies in path.

const PROJECTILE_SCENE := preload("res://scenes/bullets/bullet_laser.tscn")
const BASE_DAMAGE := 25.0
const BEAM_HALF_LENGTH := 125.0


func fire(owner_ship: Node2D, damage_mult: float = 1.0, target: Node2D = null) -> void:
	var dir: Vector2 = Vector2.RIGHT.rotated(owner_ship.rotation)
	
	# Aim at target if provided
	if target and is_instance_valid(target):
		dir = (target.global_position - owner_ship.global_position).normalized()
	
	var angle: float = dir.angle()
	DebugLog.log_info("WEAPON", "Laser fire: dir=%s, angle=%.2f, has_target=%s" % [dir, angle, target != null])
	
	var beam: Area2D = PROJECTILE_SCENE.instantiate() as Area2D
	beam.global_position = owner_ship.global_position + dir * BEAM_HALF_LENGTH
	beam.rotation = angle
	owner_ship.get_parent().add_child(beam)
	if beam.has_method("setup"):
		beam.setup(BASE_DAMAGE * damage_mult, owner_ship)
