extends GutTest
## Tests for the projectile size upgrade (megabonk-style): +10% projectile
## scale and +5% damage per stack; bullets read the owner's size multiplier.

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const BLASTER_SCENE := preload("res://scenes/bullets/bullet_blaster.tscn")
const MISSILE_SCENE := preload("res://scenes/bullets/bullet_missile.tscn")


class BigShip:
	extends Node2D
	var projectile_size_mult := 1.5


func test_player_has_size_multiplier_default_one() -> void:
	var player: CharacterBody2D = add_child_autofree(PLAYER_SCENE.instantiate())
	await get_tree().process_frame
	assert_eq(player.projectile_size_mult, 1.0)


func test_size_upgrade_grows_projectiles_and_damage() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	var player: CharacterBody2D = add_child_autofree(PLAYER_SCENE.instantiate())
	await get_tree().process_frame
	hud._player = player
	var dmg_before: float = player.damage_mult
	var upgrade := UpgradeData.new()
	upgrade.display_name = "+10% Size"
	upgrade.type = "stat_size"
	hud._on_upgrade_selected(upgrade)
	assert_almost_eq(player.projectile_size_mult, 1.1, 0.001)
	assert_almost_eq(player.damage_mult, dmg_before * 1.05, 0.001,
		"Bigger projectiles must also hit a bit harder")


func test_blaster_bullet_scales_with_owner_mult() -> void:
	var ship := BigShip.new()
	add_child_autofree(ship)
	var bullet: Area2D = add_child_autofree(BLASTER_SCENE.instantiate())
	bullet.setup(10.0, 300.0, ship)
	assert_almost_eq(bullet.scale.x, 1.5, 0.001,
		"Blaster bullets must grow with the owner's size multiplier")


func test_missile_scales_with_owner_mult() -> void:
	var ship := BigShip.new()
	add_child_autofree(ship)
	var missile: Area2D = add_child_autofree(MISSILE_SCENE.instantiate())
	missile.setup(10.0, 200.0, ship)
	assert_almost_eq(missile.scale.x, 1.5, 0.001,
		"Missiles must grow with the owner's size multiplier")


func test_size_upgrade_resource_exists() -> void:
	# The resource and its mechanic (this whole file) are kept working —
	# only the offer pool excludes it for now, pending a rework.
	var res: UpgradeData = load("res://data/upgrades/upgrade_size.tres")
	assert_not_null(res)
	assert_eq(res.type, "stat_size")
	assert_false(res.is_weapon, "Size is a stat upgrade (amber), not a weapon")


func test_size_upgrade_is_disabled_from_the_offer_pool() -> void:
	var hud: CanvasLayer = add_child_autofree(HUD_SCENE.instantiate())
	await get_tree().process_frame
	for u in hud._upgrade_pool:
		assert_ne(u.type, "stat_size", "Size upgrade must not be offered while disabled")