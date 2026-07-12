class_name ShipResource
extends Resource
## Defines a playable ship's base stats and starting weapon.

@export var ship_id: String = ""
@export var ship_name: String = "Unknown Ship"
@export var description: String = ""

## Visual
@export var color: Color = Color(0.2, 0.8, 1.0, 1.0)

## Base stats
@export var base_hp: float = 100.0
@export var base_speed: float = 120.0
@export var base_damage_mult: float = 1.0
@export var base_fire_rate_mult: float = 1.0
@export var base_pickup_radius: float = 40.0

## Starting weapon script path (e.g., "res://scripts/weapons/weapon_blaster.gd")
@export var starting_weapon_path: String = "res://scripts/weapons/weapon_blaster.gd"

## Passive bonus description (for UI display)
@export var passive_name: String = ""
@export var passive_description: String = ""
