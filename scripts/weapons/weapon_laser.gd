extends Node2D
## Beam weapon - instant-hit line that damages all enemies in path.

const PROJECTILE_SCENE := preload("res://scenes/bullets/bullet_laser.tscn")
const DAMAGE := 12.0


const BEAM_HALF_LENGTH := 125.0


func fire(owner_ship: Node2D, damage_mult: float = 1.0) -> void:
	var beam := PROJECTILE_SCENE.instantiate() as Area2D
	var forward := Vector2.RIGHT.rotated(owner_ship.rotation)
	beam.global_position = owner_ship.global_position + forward * BEAM_HALF_LENGTH
	beam.rotation = owner_ship.rotation
	owner_ship.get_parent().add_child(beam)
	if beam.has_method("setup"):
		beam.setup(DAMAGE * damage_mult, owner_ship)
