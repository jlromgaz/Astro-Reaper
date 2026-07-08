extends GutTest
## Tests for contact damage stacking (multi-enemy additive damage).
## The player should lose HP from EVERY enemy in contact simultaneously,
## not just the first one. i-frames only apply to Area2D (bullet) hits.

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")

var player: CharacterBody2D


func before_each() -> void:
	player = add_child_autofree(PLAYER_SCENE.instantiate())
	await get_tree().process_frame
	player.max_hp = 100.0
	player.current_hp = 100.0
	player._invincibility_timer = 0.0


## Two body-contact sources (enemies) must BOTH deal damage in the same
## frame. Before fix: global 0.8s i-frame blocks the second hit.
func test_two_body_sources_both_deal_damage() -> void:
	var source_a := Node2D.new()
	var source_b := Node2D.new()
	add_child_autofree(source_a)
	add_child_autofree(source_b)
	player.take_damage(10.0, source_a)
	player.take_damage(10.0, source_b)
	assert_almost_eq(
		player.current_hp, 80.0, 0.1,
		"two distinct body sources must each deal 10 damage (total 20)"
	)


## A single body-contact source deals its damage normally.
func test_single_body_source_deals_damage() -> void:
	var source := Node2D.new()
	add_child_autofree(source)
	player.take_damage(15.0, source)
	assert_almost_eq(player.current_hp, 85.0, 0.1, "body source must deal damage")


## Three body-contact sources must all deal damage (additive stacking).
func test_three_body_sources_all_deal_damage() -> void:
	var source_a := Node2D.new()
	var source_b := Node2D.new()
	var source_c := Node2D.new()
	add_child_autofree(source_a)
	add_child_autofree(source_b)
	add_child_autofree(source_c)
	player.take_damage(5.0, source_a)
	player.take_damage(5.0, source_b)
	player.take_damage(5.0, source_c)
	assert_almost_eq(player.current_hp, 85.0, 0.1, "three body sources must deal 15 damage total")


## Area2D (bullet) hits should still apply a brief i-frame to prevent
## the same bullet hitting multiple times in one frame.
func test_area_source_blocked_while_iframe_active() -> void:
	var bullet := Area2D.new()
	add_child_autofree(bullet)
	player.take_damage(10.0, bullet)
	var hp_after_first: float = player.current_hp
	player.take_damage(10.0, bullet)
	assert_almost_eq(
		player.current_hp, hp_after_first, 0.1,
		"second Area2D hit within i-frame window must be blocked"
	)


## After the i-frame expires, Area2D hits should deal damage again.
func test_area_iframe_expires_and_damage_resumes() -> void:
	var bullet_a := Area2D.new()
	var bullet_b := Area2D.new()
	add_child_autofree(bullet_a)
	add_child_autofree(bullet_b)
	player.take_damage(10.0, bullet_a)
	player._invincibility_timer = 0.0  # manually expire
	player.take_damage(10.0, bullet_b)
	assert_almost_eq(
		player.current_hp, 80.0, 0.1,
		"area hit after i-frame expiry must deal damage"
	)
