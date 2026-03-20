extends Node2D
## Homing missiles - seek nearest enemy.

const PROJECTILE_SCENE := preload("res://scenes/bullets/bullet_missile.tscn")
const DAMAGE := 10.0
const SPEED := 180.0


func fire(owner_ship: Node2D, damage_mult: float = 1.0) -> void:
	var missile: Area2D = PROJECTILE_SCENE.instantiate() as Area2D
	missile.global_position = owner_ship.global_position
	missile.rotation = owner_ship.rotation
	owner_ship.get_parent().add_child(missile)
	if missile.has_method("setup"):
		missile.setup(DAMAGE * damage_mult, SPEED, owner_ship)
	var dir = Vector2.RIGHT.rotated(owner_ship.rotation)
	DebugLog.log_info("WEAPON", "Missile fire | dir: %.2f,%.2f | angle: %.2f" % [dir.x, dir.y, owner_ship.rotation])
