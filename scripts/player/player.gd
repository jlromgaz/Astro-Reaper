extends CharacterBody2D
## Player ship. Movement via virtual joystick, auto-fire.
## Stats are initialized from a ShipResource.
## Weapons track level and projectile count.

var ship_data: ShipResource

var move_speed: float = 120.0
var max_hp: float = 150.0
var current_hp: float = 150.0
var damage_mult: float = 1.0
var fire_rate_mult: float = 1.0
var projectile_size_mult: float = 1.0
var pickup_radius: float = 40.0
var enemies_killed := 0
var _is_dead := false

var _move_input := Vector2.ZERO
## Each entry: { "node": Node2D, "type": String, "level": int, "projectile_count": int }
var _weapon_slots: Array[Dictionary] = []
var _fire_timer: float = 0.0
var _fire_interval: float = 1.2
## Per-source i-frame: blocks the SAME attacker from re-hitting within the
## window, but lets multiple simultaneous attackers each land their hit —
## getting swarmed by 3 enemies must hurt more than being touched by 1.
const INVINCIBILITY_TIME := 0.15
var _source_cooldowns: Dictionary = {}


func _ready() -> void:
	add_to_group("player")
	call_deferred("_emit_spawned")
	EventBus.game_started.connect(_on_game_started)
	EventBus.enemy_killed.connect(func(_e, _p): enemies_killed += 1)


func initialize_ship(data: ShipResource) -> void:
	ship_data = data
	max_hp = data.base_hp
	current_hp = data.base_hp
	move_speed = data.base_speed
	damage_mult = data.base_damage_mult
	fire_rate_mult = data.base_fire_rate_mult
	pickup_radius = data.base_pickup_radius
	# Apply visual color and per-ship silhouette
	var visual = get_node_or_null("ShipVisual")
	if visual and visual.has_method("set_ship_color"):
		visual.set_ship_color(data.color)
	if visual and visual.has_method("set_ship_shape"):
		visual.set_ship_shape(data.ship_id)
	DebugLog.log_info("PLAYER", "Ship initialized: %s (HP:%.0f SPD:%.0f DMG:x%.1f FR:x%.1f)" % [
		data.ship_name, max_hp, move_speed, damage_mult, fire_rate_mult
	])


func _emit_spawned() -> void:
	DebugLog.log_info("PLAYER", "Player spawned (ID: %d)" % get_instance_id())
	# Use starting weapon from ship data, or fallback to blaster
	var weapon_path: String = "res://scripts/weapons/weapon_blaster.gd"
	if ship_data and ship_data.starting_weapon_path != "":
		weapon_path = ship_data.starting_weapon_path
	var script := load(weapon_path) as GDScript
	if not script:
		DebugLog.log_error("PLAYER", "Failed to load weapon script: %s" % weapon_path)
	else:
		add_weapon(script)
	EventBus.player_spawned.emit(self)


func _on_game_started() -> void:
	if ship_data:
		current_hp = ship_data.base_hp
	else:
		current_hp = max_hp
	_source_cooldowns.clear()
	enemies_killed = 0


func _physics_process(delta: float) -> void:
	if not GameManager.is_playing():
		return
	for src in _source_cooldowns.keys():
		if not is_instance_valid(src) or _source_cooldowns[src] <= delta:
			_source_cooldowns.erase(src)
		else:
			_source_cooldowns[src] -= delta
	velocity = _move_input * move_speed
	move_and_slide()
	_auto_aim()
	_try_fire(delta)


func _auto_aim() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: Node2D = null
	var nearest_dist := INF
	for e in enemies:
		if not is_instance_valid(e) or e.is_queued_for_deletion(): continue
		var d = global_position.distance_squared_to(e.global_position)
		if d < nearest_dist:
			nearest_dist = d
			nearest = e
	
	if nearest:
		var target_angle = (nearest.global_position - global_position).angle()
		rotation = lerp_angle(rotation, target_angle, 0.2)


func set_move_input(direction: Vector2) -> void:
	_move_input = direction.limit_length(1.0)


## --- Weapon Management ---

func add_weapon(script: GDScript) -> void:
	var type_name: String = _get_weapon_type(script)
	# If we already have this weapon, level it up instead
	for slot in _weapon_slots:
		if slot.type == type_name:
			level_up_weapon(type_name)
			return
	# New weapon
	var w: Node2D = script.new() as Node2D
	add_child(w)
	var slot := {
		"node": w,
		"type": type_name,
		"level": 1,
		"projectile_count": 1,
	}
	_weapon_slots.append(slot)
	DebugLog.log_info("WEAPON", "Added weapon: %s (Lv.1)" % type_name)


func level_up_weapon(type_name: String) -> void:
	for slot in _weapon_slots:
		if slot.type == type_name:
			slot.level += 1
			slot.projectile_count += 1
			DebugLog.log_info("WEAPON", "Leveled up %s to Lv.%d (%d projectiles)" % [
				type_name, slot.level, slot.projectile_count
			])
			return


func add_projectile_to_all() -> void:
	for slot in _weapon_slots:
		slot.projectile_count += 1
	DebugLog.log_info("WEAPON", "+1 projectile to all weapons")


func _get_weapon_type(script: GDScript) -> String:
	if not script:
		return "unknown"
	return script.resource_path.get_file().replace(".gd", "")


func has_weapon(weapon_type: String) -> bool:
	for slot in _weapon_slots:
		if slot.type == weapon_type:
			return true
	if weapon_type == "shield" and has_shield:
		return true
	return false


func get_weapon_level(weapon_type: String) -> int:
	for slot in _weapon_slots:
		if slot.type == weapon_type:
			return slot.level
	return 0


func get_weapon_slots() -> Array[Dictionary]:
	return _weapon_slots


func get_total_projectile_count() -> int:
	var total := 0
	for slot in _weapon_slots:
		total += slot.projectile_count
	return total


## --- Multi-target firing ---

func _try_fire(delta: float) -> void:
	var enemies = get_tree().get_nodes_in_group("enemies").filter(
		func(e): return is_instance_valid(e) and not e.is_queued_for_deletion() and e.is_inside_tree()
	)
	if enemies.is_empty():
		return
		
	_fire_timer += delta
	var interval: float = _fire_interval / fire_rate_mult
	if _fire_timer >= interval:
		_fire_timer = 0.0
		_fire_all_weapons(enemies)


func _fire_all_weapons(enemies: Array) -> void:
	# Count total projectiles across all weapons
	var total_projectiles := get_total_projectile_count()
	
	# Sort enemies by distance
	var ship_pos := global_position
	enemies.sort_custom(func(a, b):
		return ship_pos.distance_squared_to(a.global_position) < ship_pos.distance_squared_to(b.global_position)
	)
	
	# Build target list: distribute projectiles across closest enemies
	var targets: Array[Node2D] = []
	if enemies.size() >= total_projectiles:
		for i in range(total_projectiles):
			targets.append(enemies[i])
	else:
		# Fewer enemies than projectiles: round-robin distribute
		for i in range(total_projectiles):
			targets.append(enemies[i % enemies.size()])
	
	# Assign targets to each weapon slot's projectiles
	var target_idx := 0
	for slot in _weapon_slots:
		var weapon: Node2D = slot.node
		if not weapon or not weapon.has_method("fire"):
			continue
		var level_damage_bonus: float = 1.0 + (slot.level - 1) * 0.15
		for _p in range(slot.projectile_count):
			if target_idx < targets.size():
				weapon.fire(self, damage_mult * level_damage_bonus, targets[target_idx])
				target_idx += 1


## --- Legacy compatibility ---

func add_weapon_laser() -> void:
	add_weapon(preload("res://scripts/weapons/weapon_laser.gd") as GDScript)


func add_weapon_missiles() -> void:
	add_weapon(preload("res://scripts/weapons/weapon_missiles.gd") as GDScript)


## --- Shield ---

var has_shield := false
var shield_hp := 0.0


func add_shield() -> void:
	has_shield = true
	shield_hp = 20.0
	DebugLog.log_info("PLAYER", "Shield activated (20 HP)")


func get_weapons_short_list() -> String:
	var list = []
	for slot in _weapon_slots:
		var wname = slot.type.replace("weapon_", "").capitalize()
		list.append("%s Lv.%d" % [wname, slot.level])
	if has_shield and shield_hp > 0:
		list.append("Shield")
	return ", ".join(list)


func take_damage(amount: float, _source: Node) -> void:
	if _is_dead:
		return
	if _source and _source_cooldowns.has(_source):
		return

	var remaining_dmg = amount
	if has_shield and shield_hp > 0:
		var absorbed = min(shield_hp, remaining_dmg)
		shield_hp -= absorbed
		remaining_dmg -= absorbed
		DebugLog.log_info("PLAYER", "Shield absorbed %.1f damage. Remaining: %.1f" % [absorbed, shield_hp])
		if shield_hp <= 0:
			DebugLog.log_info("PLAYER", "Shield broken!")

	if remaining_dmg <= 0:
		return

	current_hp -= remaining_dmg
	if _source:
		_source_cooldowns[_source] = INVINCIBILITY_TIME
	DebugLog.log_info("COMBAT", "Player[%d] hit: %.1f. HP: %.1f/%.1f" % [get_instance_id(), remaining_dmg, current_hp, max_hp])
	EventBus.player_hp_changed.emit(current_hp, max_hp)
	EventBus.player_damaged.emit(remaining_dmg, _source)
	
	if current_hp <= 0:
		_die()


func heal(amount: float) -> void:
	current_hp = clampf(current_hp + amount, 0, max_hp)
	EventBus.player_hp_changed.emit(current_hp, max_hp)
	DebugLog.log_info("PLAYER", "Healed %.1f HP. Current: %.1f" % [amount, current_hp])


func add_speed(amount: float) -> void:
	move_speed += amount
	DebugLog.log_info("PLAYER", "Speed increased to %.1f" % move_speed)


func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	DebugLog.log_info("COMBAT", "Player died")
	EventBus.player_died.emit()
	GameManager.end_game("death")


func get_current_hp() -> float:
	return current_hp


func get_max_hp() -> float:
	return max_hp


func get_pickup_radius() -> float:
	return pickup_radius


func get_stats() -> Dictionary:
	return {
		"damage": damage_mult,
		"fire_rate": fire_rate_mult,
		"weapon_count": _weapon_slots.size(),
		"total_projectiles": get_total_projectile_count(),
		"kills": enemies_killed
	}
