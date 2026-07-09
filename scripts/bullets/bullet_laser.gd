extends Area2D
## Laser beam - damages all enemies overlapping its path in one frame.

var damage: float = 12.0
var _owner_ship: Node2D


var _frames_alive: int = 0

func setup(dmg: float, owner_ship: Node2D) -> void:
	damage = dmg
	_owner_ship = owner_ship


func _physics_process(_delta: float) -> void:
	_frames_alive += 1
	# Wait one frame for physics to detect overlaps
	if _frames_alive >= 2:
		for body in get_overlapping_bodies():
			if body.is_in_group("enemies") and body.has_method("take_damage"):
				body.take_damage(damage)
		# Area2D targets too (comets are areas, not bodies)
		for area in get_overlapping_areas():
			if area.is_in_group("enemies") and area.has_method("take_damage"):
				area.take_damage(damage)
		queue_free()
