extends Node2D
## Beam weapon - aims at nearest enemy, damages all in path.

const PROJECTILE_SCENE := preload("res://scenes/bullets/bullet_laser.tscn")
const DAMAGE := 12.0
const BEAM_HALF_LENGTH := 125.0


func fire(owner_ship: Node2D, damage_mult: float = 1.0) -> void:
	var target: Node2D = _find_nearest_enemy(owner_ship)
	var dir: Vector2 = Vector2.RIGHT
	if target and is_instance_valid(target):
		dir = (target.global_position - owner_ship.global_position).normalized()
	var angle: float = dir.angle()
	var beam: Area2D = PROJECTILE_SCENE.instantiate() as Area2D
	beam.global_position = owner_ship.global_position + dir * BEAM_HALF_LENGTH
	beam.rotation = angle
	owner_ship.get_parent().add_child(beam)
	if beam.has_method("setup"):
		beam.setup(DAMAGE * damage_mult, owner_ship)


func _find_nearest_enemy(owner_ship: Node2D) -> Node2D:
	var enemies: Array = owner_ship.get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist: float = INF
	for node in enemies:
		var body: Node2D = node as Node2D
		if not is_instance_valid(body):
			continue
		var d: float = owner_ship.global_position.distance_squared_to(body.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = body
	return nearest
