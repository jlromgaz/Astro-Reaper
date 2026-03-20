extends Area2D
class_name HitboxComponent

@export var damage: float = 10.0

func _init() -> void:
	# Default to Layer 4 (EnemyBullets) or 3 (PlayerBullets) depending on use
	# For now, we'll set it in the editor
	pass
