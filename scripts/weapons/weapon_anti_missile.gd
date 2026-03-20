extends Node2D
## Anti-Missile Weapon - Destroys nearby enemy projectiles.
## Each level increases the number of neutralized targets.

const RANGE := 150.0

func fire(owner_ship: Node2D, _damage_mult: float = 1.0, _target: Node2D = null) -> void:
	# Get weapon level from player
	var level := 1
	if owner_ship.has_method("get_weapon_level"):
		level = owner_ship.get_weapon_level("weapon_anti_missile")
	
	var targets_to_neutralize := 5 * level
	var neutralized_count := 0
	
	# Find enemy projectiles
	var projectiles := owner_ship.get_tree().get_nodes_in_group("enemy_projectiles")
	
	# Sort by distance
	var ship_pos := owner_ship.global_position
	projectiles.sort_custom(func(a, b):
		return ship_pos.distance_squared_to(a.global_position) < ship_pos.distance_squared_to(b.global_position)
	)
	
	for p in projectiles:
		if not is_instance_valid(p):
			continue
		
		var dist := ship_pos.distance_to(p.global_position)
		if dist <= RANGE:
			p.queue_free()
			neutralized_count += 1
			if neutralized_count >= targets_to_neutralize:
				break
	
	if neutralized_count > 0:
		DebugLog.log_info("WEAPON", "Anti-Missile: Neutralized %d projectiles" % neutralized_count)
		# Optional: Spawn a visual effect at owner_ship
		_spawn_visual_fx(owner_ship)

func _spawn_visual_fx(owner_ship: Node2D) -> void:
	# Simple expansion ring effect using a temporary Node2D
	var ring := Node2D.new()
	owner_ship.get_parent().add_child(ring)
	ring.global_position = owner_ship.global_position
	
	var timer := owner_ship.get_tree().create_timer(0.3)
	timer.timeout.connect(ring.queue_free)
	
	# We'd ideally have a sprite or a custom draw here. 
	# For now, just a log is fine, but let's draw a simple circle if possible.
	# Since it's a new node without a script, we can't easily override _draw.
	# We'll skip the ring draw for now to keep it simple and avoid complexity.
