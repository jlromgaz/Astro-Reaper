extends GutTest
## Regression tests for player stats, weapon slots, damage, and ship visual
## (scripts/player/player.gd, scripts/player/player_ship_visual.gd).

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const SHIP_STELLAR := preload("res://data/ships/ship_stellar.tres")
const WEAPON_BLASTER := preload("res://scripts/weapons/weapon_blaster.gd")
const WEAPON_LASER := preload("res://scripts/weapons/weapon_laser.gd")

var player: CharacterBody2D


func before_each() -> void:
	player = add_child_autofree(PLAYER_SCENE.instantiate())
	# Let the deferred _emit_spawned run so the starting weapon is attached.
	await get_tree().process_frame


## --- Ship initialization ---

func test_initialize_ship_applies_stats() -> void:
	player.initialize_ship(SHIP_STELLAR)
	assert_eq(player.max_hp, SHIP_STELLAR.base_hp)
	assert_eq(player.current_hp, SHIP_STELLAR.base_hp)
	assert_eq(player.move_speed, SHIP_STELLAR.base_speed)
	assert_eq(player.damage_mult, SHIP_STELLAR.base_damage_mult)
	assert_eq(player.fire_rate_mult, SHIP_STELLAR.base_fire_rate_mult)
	assert_eq(player.pickup_radius, SHIP_STELLAR.base_pickup_radius)


func test_initialize_ship_tints_visual() -> void:
	player.initialize_ship(SHIP_STELLAR)
	var visual := player.get_node("ShipVisual")
	assert_eq(visual._body_color, SHIP_STELLAR.color)


## --- Weapon slots ---

func test_starts_with_one_blaster_at_level_1() -> void:
	assert_eq(player.get_weapon_slots().size(), 1)
	assert_eq(player.get_weapon_level("weapon_blaster"), 1)


func test_adding_owned_weapon_levels_it_up() -> void:
	player.add_weapon(WEAPON_BLASTER)
	assert_eq(player.get_weapon_slots().size(), 1, "Duplicate weapon must not create a new slot")
	assert_eq(player.get_weapon_level("weapon_blaster"), 2)
	assert_eq(player.get_total_projectile_count(), 2, "Level-up must add one projectile")


func test_adding_new_weapon_creates_slot() -> void:
	player.add_weapon(WEAPON_LASER)
	assert_eq(player.get_weapon_slots().size(), 2)
	assert_eq(player.get_weapon_level("weapon_laser"), 1)


func test_add_projectile_to_all() -> void:
	player.add_weapon(WEAPON_LASER)
	player.add_projectile_to_all()
	assert_eq(player.get_total_projectile_count(), 4, "2 weapons x (1 base + 1 bonus) projectiles")


## --- Damage, shield, healing ---

func test_take_damage_reduces_hp() -> void:
	var hp_before: float = player.current_hp
	player.take_damage(10.0, null)
	assert_eq(player.current_hp, hp_before - 10.0)


func test_bullet_invincibility_blocks_second_hit() -> void:
	# i-frames only apply to Area2D (bullet) hits, not body contacts
	var bullet: Area2D = autofree(Area2D.new())
	player.take_damage(10.0, bullet)
	var hp_after_first: float = player.current_hp
	player.take_damage(10.0, bullet)
	assert_eq(player.current_hp, hp_after_first, "Second bullet hit inside i-frame window must be blocked")


func test_shield_absorbs_projectile_damage() -> void:
	player.add_shield()
	var projectile: Area2D = autofree(Area2D.new())
	player.take_damage(5.0, projectile)
	assert_eq(player.shield_hp, 15.0)
	assert_eq(player.current_hp, player.max_hp, "Shield must fully absorb the hit")


func test_heal_clamps_to_max_hp() -> void:
	player.current_hp = player.max_hp - 5.0
	player.heal(50.0)
	assert_eq(player.current_hp, player.max_hp)


## --- Ship visual hit feedback ---

func test_visual_flashes_on_player_damaged() -> void:
	var visual := player.get_node("ShipVisual")
	assert_eq(visual._flash_timer, 0.0)
	EventBus.player_damaged.emit(10.0, null)
	assert_gt(visual._flash_timer, 0.0, "Visual must flash when player takes damage")
