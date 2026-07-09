extends Area2D
## Upgrade chest — rare pickup. Touching it opens the FULL upgrade catalog
## and the chosen upgrade is applied three times (see hud.gd).

const MAX_LIFETIME := 25.0

var _lifetime: float = 0.0


func _ready() -> void:
	add_to_group("chests")
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
	DebugLog.log_info("CHEST", "Chest opened at %s" % global_position)
	EventBus.chest_opened.emit()
	queue_free()
