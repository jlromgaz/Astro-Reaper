extends Node
class_name HealthComponent

signal health_changed(current: float, max: float)
signal health_depleted
signal damaged(amount: float)

@export var max_health: float = 100.0
@onready var current_health: float = max_health

func _ready() -> void:
	current_health = max_health

func take_damage(amount: float) -> void:
	current_health -= amount
	damaged.emit(amount)
	health_changed.emit(current_health, max_health)
	if current_health <= 0:
		health_depleted.emit()

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)

func set_max_health(value: float, heal_to_full: bool = true) -> void:
	max_health = value
	if heal_to_full:
		current_health = max_health
	health_changed.emit(current_health, max_health)
