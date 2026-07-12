extends Area2D
## XP magnet — rare drop. Touching it pulls every gem on screen to the player.

const MAX_LIFETIME := 20.0

var _lifetime: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if not GameManager.is_playing():
		return
	_lifetime += delta
	if _lifetime >= MAX_LIFETIME:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	var count := 0
	for gem in get_tree().get_nodes_in_group("xp_pickups"):
		if gem.has_method("attract_to"):
			gem.attract_to(body)
			count += 1
	SoundManager.play_pickup_sound()
	DebugLog.log_info("PICKUP", "Magnet collected — attracting %d gems" % count)
	queue_free()
