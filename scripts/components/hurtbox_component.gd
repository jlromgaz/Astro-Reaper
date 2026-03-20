extends Area2D
class_name HurtboxComponent

signal hit_received(damage: float, source: Node)

@export var health_component: HealthComponent

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var dmg: float = area.damage
		if health_component:
			health_component.take_damage(dmg)
		hit_received.emit(dmg, area)
