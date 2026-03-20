extends Area2D
## Health Pickup - Heals player for 20 HP.

const HEAL_AMOUNT := 20.0
var _player: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if body.has_method("heal"):
			body.heal(HEAL_AMOUNT)
			if has_node("/root/SoundManager"):
				get_node("/root/SoundManager").play_pickup_sound()
		queue_free()
