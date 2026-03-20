extends Node2D
## AOE Pulse Weapon. Hits all enemies in a radius.

const COOLDOWN := 3.0
const RADIUS := 100.0
const DAMAGE := 60.0

var _timer := 0.0
var _pulse_color := Color(0.4, 0.8, 1.0, 0.4)

func _process(delta: float) -> void:
	if not GameManager.is_playing():
		return
	_timer += delta
	if _timer >= COOLDOWN:
		_timer = 0.0
		_fire()

func _fire() -> void:
	var player = get_parent()
	if not player: return
	
	var enemies = get_tree().get_nodes_in_group("enemies")
	var hit_count := 0
	for e in enemies:
		if not is_instance_valid(e) or e.is_queued_for_deletion():
			continue
		if e.global_position.distance_to(player.global_position) <= RADIUS:
			if e.has_method("take_damage"):
				e.take_damage(DAMAGE)
				hit_count += 1
	
	if hit_count > 0:
		DebugLog.log_info("WEAPON", "Pulse Wave hit %d enemies" % hit_count)
	
	if has_node("/root/SoundManager"):
		get_node("/root/SoundManager").play_pulse_sound()
	
	_show_visuals()


func _show_visuals() -> void:
	# Create a temporary visual effect node
	var effect = Node2D.new()
	effect.name = "PulseEffect"
	effect.global_position = global_position
	get_parent().add_child(effect) # Add to GameWorld
	
	# Add a script to the effect to handle drawing and animation
	effect.set_script(load("res://scripts/effects/pulse_ring.gd"))
	if effect.has_method("setup"):
		effect.setup(RADIUS, _pulse_color)


# Create the pulse_ring.gd script if it doesn't exist (handled by write_to_file next)
