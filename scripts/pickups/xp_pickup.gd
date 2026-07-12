extends Area2D
## XP gem. Collected when player is within pickup radius. A magnet pickup
## can force-attract it from anywhere via attract_to().

const MAGNET_SPEED := 550.0
const COLLECT_DISTANCE := 15.0

var xp_value: int = 1
var _magnet_target: Node2D = null


func _ready() -> void:
	add_to_group("xp_pickups")


func set_value(v: int) -> void:
	xp_value = v


func attract_to(player: Node2D) -> void:
	_magnet_target = player


func _process(delta: float) -> void:
	if _magnet_target and is_instance_valid(_magnet_target):
		var to_player: Vector2 = _magnet_target.global_position - global_position
		if to_player.length() <= COLLECT_DISTANCE:
			_collect(_magnet_target)
			return
		global_position += to_player.normalized() * MAGNET_SPEED * delta
		return
	var player: Node2D = get_tree().get_first_node_in_group("player") as Node2D
	if not player:
		return
	var dist: float = global_position.distance_to(player.global_position)
	if player.has_method("get_pickup_radius"):
		var radius: float = player.get_pickup_radius()
		if dist <= radius:
			_collect(player)


func _collect(_player: Node2D) -> void:
	EventBus.xp_collected.emit(xp_value)
	DebugLog.log_info("XP", "Collected %d XP" % xp_value)
	queue_free()
