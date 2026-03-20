extends Node2D
## Beam weapon - aims at nearest enemy, damages all in path.

const PROJECTILE_SCENE := preload("res://scenes/bullets/bullet_laser.tscn")
const DAMAGE := 25.0
const BEAM_HALF_LENGTH := 125.0


func fire(owner_ship: Node2D, damage_mult: float = 1.0) -> void:
	var target: Node2D = _find_nearest_enemy(owner_ship)
	var dir: Vector2 = Vector2.RIGHT
	if target and is_instance_valid(target):
		dir = (target.global_position - owner_ship.global_position).normalized()
	
	var angle: float = dir.angle()
	DebugLog.log_info("WEAPON", "Laser fire: dir=%s, angle=%.2f, has_target=%s" % [dir, angle, target != null])
	
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
	var ship_pos: Vector2 = owner_ship.global_position
	
	for node in enemies:
		if not is_instance_valid(node) or not node is Node2D:
			continue
		
		var d: float = ship_pos.distance_squared_to(node.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = node
	
	if not nearest:
		# Fallback: check if we can find any child of the world that's an enemy
		var world = owner_ship.get_parent()
		if world:
			for child in world.get_children():
				if child.is_in_group("enemies") and is_instance_valid(child):
					var d: float = ship_pos.distance_squared_to(child.global_position)
					if d < nearest_dist:
						nearest_dist = d
						nearest = child
	
	if nearest:
		DebugLog.log_info("WEAPON", "Laser: Targeted enemy at %s" % nearest.global_position)
	else:
		DebugLog.log_info("WEAPON", "Laser: No targets found")
		
	return nearest
