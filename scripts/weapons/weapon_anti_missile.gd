extends Node2D
## Anti-Missile Weapon - Launches visible counter-missiles that home toward
## incoming enemy projectiles. Each level increases the volley size.

const COUNTER_MISSILE_SCENE := preload("res://scenes/bullets/bullet_counter_missile.tscn")
const DETECTION_RANGE := 300.0
const MAX_VOLLEY := 8


func fire(owner_ship: Node2D, _damage_mult: float = 1.0, _target: Node2D = null) -> void:
	# Get weapon level from player
	var level := 1
	if owner_ship.has_method("get_weapon_level"):
		level = owner_ship.get_weapon_level("weapon_anti_missile")

	# Find unclaimed enemy projectiles within detection range
	var ship_pos := owner_ship.global_position
	var candidates := []
	for p in owner_ship.get_tree().get_nodes_in_group("enemy_projectiles"):
		if not is_instance_valid(p) or p.is_queued_for_deletion():
			continue
		if p.has_meta("intercepted"):
			continue
		if ship_pos.distance_to(p.global_position) > DETECTION_RANGE:
			continue
		candidates.append(p)

	if candidates.is_empty():
		return

	# Sort by distance
	candidates.sort_custom(func(a, b):
		return ship_pos.distance_squared_to(a.global_position) < ship_pos.distance_squared_to(b.global_position)
	)

	var count := mini(mini(5 * level, MAX_VOLLEY), candidates.size())
	for i in range(count):
		var target: Node2D = candidates[i]
		var missile: Area2D = COUNTER_MISSILE_SCENE.instantiate() as Area2D
		missile.global_position = ship_pos
		missile.rotation = (target.global_position - ship_pos).angle()
		owner_ship.get_parent().add_child(missile)
		missile.setup(missile.SPEED, target)
		target.set_meta("intercepted", true)

	DebugLog.log_info("WEAPON", "Anti-Missile: Launched %d counter-missiles" % count)
