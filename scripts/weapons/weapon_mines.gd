extends Node2D
## Proximity mines — each fire cycle drops min(level, 3) armed mines at the
## owner ship's position. Mines handle arming, AOE damage, and expiry.

const PROJECTILE_SCENE := preload("res://scenes/bullets/bullet_mine.tscn")
const BASE_DAMAGE := 20.0
const MAX_MINES_PER_DROP := 3


func fire(owner_ship: Node2D, damage_mult: float = 1.0, _target: Node2D = null) -> void:
	var level := 1
	if owner_ship.has_method("get_weapon_level"):
		level = owner_ship.get_weapon_level("weapon_mines")
	var count := mini(maxi(level, 1), MAX_MINES_PER_DROP)
	for i in range(count):
		var mine: Area2D = PROJECTILE_SCENE.instantiate() as Area2D
		mine.global_position = owner_ship.global_position
		owner_ship.get_parent().add_child(mine)
		mine.setup(BASE_DAMAGE * damage_mult)
	DebugLog.log_info("WEAPON", "Mines: dropped %d mine(s)" % count)
