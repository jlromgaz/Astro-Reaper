extends Area2D
## XP gem. Collected when player is within pickup radius.

var xp_value: int = 1


func set_value(v: int) -> void:
	xp_value = v


func _process(_delta: float) -> void:
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
