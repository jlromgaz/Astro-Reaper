extends Node2D
## Frontal blaster - straight projectile, medium fire rate.

const PROJECTILE_SCENE := preload("res://scenes/bullets/bullet_blaster.tscn")
const DAMAGE := 18.0
const SPEED := 300.0


func fire(owner_ship: Node2D, damage_mult: float = 1.0) -> void:
	var bullet: Area2D = PROJECTILE_SCENE.instantiate() as Area2D
	bullet.global_position = owner_ship.global_position
	bullet.rotation = owner_ship.rotation
	owner_ship.get_parent().add_child(bullet)
	if has_node("/root/SoundManager"):
		get_node("/root/SoundManager").play_shoot_sound()
	if bullet.has_method("setup"):
		bullet.setup(DAMAGE * damage_mult, SPEED, owner_ship)
	var dir = Vector2.RIGHT.rotated(owner_ship.rotation)
	DebugLog.log_info("WEAPON", "Blaster fire | dir: %.2f,%.2f | angle: %.2f" % [dir.x, dir.y, owner_ship.rotation])
