extends GutTest
## Unit tests for pickup and comet visuals. Written BEFORE implementation.

const PickupVisual := preload("res://scripts/pickups/pickup_visual.gd")
const CometVisual := preload("res://scripts/world/comet_visual.gd")


func _make_pickup_visual(kind: int) -> Node2D:
	var parent := Area2D.new()
	var visual: Node2D = PickupVisual.new()
	visual.name = "PickupVisual"
	visual.kind = kind
	parent.add_child(visual)
	add_child_autofree(parent)
	return visual


func test_xp_kind_uses_xp_gem_color() -> void:
	var visual := _make_pickup_visual(PickupVisual.Kind.XP)
	assert_eq(visual.body_color, Palette.XP_GEM)


func test_health_kind_uses_health_color() -> void:
	var visual := _make_pickup_visual(PickupVisual.Kind.HEALTH)
	assert_eq(visual.body_color, Palette.HEALTH)


func test_comet_visual_uses_comet_color() -> void:
	var parent := Area2D.new()
	var visual: Node2D = CometVisual.new()
	parent.add_child(visual)
	add_child_autofree(parent)
	assert_eq(visual.body_color, Palette.COMET)


func test_comet_visual_flashes_when_own_parent_damaged() -> void:
	var parent := Area2D.new()
	var visual: Node2D = CometVisual.new()
	parent.add_child(visual)
	add_child_autofree(parent)
	assert_eq(visual._flash_timer, 0.0)
	EventBus.enemy_damaged.emit(parent, 5.0)
	assert_gt(visual._flash_timer, 0.0, "Comet visual must flash when the comet takes damage")
