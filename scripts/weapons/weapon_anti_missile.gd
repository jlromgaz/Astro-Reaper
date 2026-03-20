extends Node2D
## Anti-Missile Weapon - Destroys nearby enemy projectiles.
## Each level increases the number of neutralized targets.

const RANGE := 150.0
var _pulse_timer := 0.0
const PULSE_DURATION := 0.4

func _process(delta: float) -> void:
	if _pulse_timer > 0:
		_pulse_timer -= delta
		queue_redraw()

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
		_pulse_timer = PULSE_DURATION
		queue_redraw()

func _draw() -> void:
	if _pulse_timer > 0:
		var progress := 1.0 - (_pulse_timer / PULSE_DURATION)
		var radius := progress * RANGE
		var alpha := 1.0 - progress
		draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color(0.4, 0.7, 1.0, alpha), 2.0)
		draw_circle(Vector2.ZERO, radius, Color(0.4, 0.7, 1.0, alpha * 0.2))
