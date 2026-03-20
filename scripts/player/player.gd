extends CharacterBody2D
## Player ship. Movement via virtual joystick, auto-fire.

const BASE_SPEED := 120.0
const BASE_HP := 150.0

var move_speed: float = BASE_SPEED
var max_hp: float = BASE_HP
var current_hp: float = BASE_HP
var damage_mult: float = 1.0
var fire_rate_mult: float = 1.0
var pickup_radius: float = 40.0
var enemies_killed := 0

var _move_input := Vector2.ZERO
var _weapons: Array[Node2D] = []
var _fire_timer: float = 0.0
var _fire_interval: float = 1.2  # Reduced fire rate (was 0.5)
const INVINCIBILITY_TIME := 0.8  # Seconds immune after taking damage
var _invincibility_timer: float = 0.0


func _ready() -> void:
	add_to_group("player")
	call_deferred("_emit_spawned")
	EventBus.game_started.connect(_on_game_started)
	# Listen for kills to track stats
	EventBus.enemy_killed.connect(func(_e, _p): enemies_killed += 1)


func _emit_spawned() -> void:
	DebugLog.log_info("PLAYER", "Player spawned (ID: %d)" % get_instance_id())
	add_weapon(preload("res://scripts/weapons/weapon_blaster.gd"))
	EventBus.player_spawned.emit(self)


func _on_game_started() -> void:
	current_hp = max_hp
	_invincibility_timer = 0.0
	enemies_killed = 0


func _physics_process(delta: float) -> void:
	if not GameManager.is_playing():
		return
	if _invincibility_timer > 0:
		_invincibility_timer -= delta
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


func add_weapon(script: GDScript) -> void:
	var w: Node2D = script.new() as Node2D
	add_child(w)
	_weapons.append(w)


func add_weapon_laser() -> void:
	if _has_weapon("weapon_laser"):
		return
	add_weapon(preload("res://scripts/weapons/weapon_laser.gd") as GDScript)


func add_weapon_missiles() -> void:
	if _has_weapon("weapon_missiles"):
		return
	add_weapon(preload("res://scripts/weapons/weapon_missiles.gd") as GDScript)


func _has_weapon(name_prefix: String) -> bool:
	for w in _weapons:
		if w.get_script() and name_prefix in w.get_script().resource_path:
			return true
	return false


func _try_fire(delta: float) -> void:
	# Only cycle timer and fire if there are REAL enemies in the scene
	var enemies = get_tree().get_nodes_in_group("enemies").filter(
		func(e): return is_instance_valid(e) and not e.is_queued_for_deletion() and e.is_inside_tree()
	)
	if enemies.is_empty():
		return
		
	_fire_timer += delta
	var interval: float = _fire_interval / fire_rate_mult
	if _fire_timer >= interval:
		_fire_timer = 0.0
		for w in _weapons:
			if w and w.has_method("fire"):
				w.fire(self, damage_mult)


var has_shield := false
var shield_hp := 0.0


func add_shield() -> void:
	has_shield = true
	shield_hp = 20.0
	DebugLog.log_info("PLAYER", "Shield activated (20 HP)")


func get_weapons_short_list() -> String:
	var list = []
	for w in _weapons:
		var name = w.get_script().resource_path.get_file().replace("weapon_", "").replace(".gd", "").capitalize()
		list.append(name)
	if has_shield and shield_hp > 0:
		list.append("Shield")
	return ", ".join(list)


func take_damage(amount: float, _source: Node) -> void:
	if _invincibility_timer > 0:
		return
	
	var remaining_dmg = amount
	if has_shield and shield_hp > 0:
		# Distinguish between contact and projectiles
		if _source is Area2D: # Projectiles
			var absorbed = min(shield_hp, remaining_dmg)
			shield_hp -= absorbed
			remaining_dmg -= absorbed
			DebugLog.log_info("PLAYER", "Shield absorbed %.1f damage. Remaining: %.1f" % [absorbed, shield_hp])
			if shield_hp <= 0:
				DebugLog.log_info("PLAYER", "Shield broken!")
		else: # Contact damage (CharacterBody2D/PhysicsBody2D)
			# Do not use shield for contact damage per user request
			pass
	
	if remaining_dmg <= 0:
		return
		
	current_hp -= remaining_dmg
	_invincibility_timer = INVINCIBILITY_TIME
	DebugLog.log_info("COMBAT", "Player[%d] hit: %.1f. HP: %.1f/%.1f" % [get_instance_id(), remaining_dmg, current_hp, max_hp])
	EventBus.player_hp_changed.emit(current_hp, max_hp)
	EventBus.player_damaged.emit(remaining_dmg, _source)
	
	if current_hp <= 0:
		_die()


func has_weapon(weapon_type: String) -> bool:
	# Convert type from HUD (weapon_blaster) to script name (weapon_blaster.gd)
	var script_name = weapon_type + ".gd"
	for w in _weapons:
		if w.get_script() and script_name in w.get_script().resource_path:
			return true
	if weapon_type == "shield" and has_shield:
		return true
	return false


func heal(amount: float) -> void:
	current_hp = clampf(current_hp + amount, 0, max_hp)
	EventBus.player_hp_changed.emit(current_hp, max_hp)
	DebugLog.log_info("PLAYER", "Healed %.1f HP. Current: %.1f" % [amount, current_hp])


func add_speed(amount: float) -> void:
	move_speed += amount
	DebugLog.log_info("PLAYER", "Speed increased to %.1f" % move_speed)


func _die() -> void:
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
		"weapon_count": _weapons.size(),
		"laser_count": _get_weapon_count("weapon_laser"),
		"missile_count": _get_weapon_count("weapon_missiles"),
		"kills": enemies_killed
	}

func _get_weapon_count(prefix: String) -> int:
	var count = 0
	for w in _weapons:
		if w.get_script() and prefix in w.get_script().resource_path:
			count += 1
	return count
