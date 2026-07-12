extends GutTest
## Integration tests: pickup and comet scenes must carry procedural visuals
## and no legacy ColorRect/Polygon2D placeholders.

const PickupVisual := preload("res://scripts/pickups/pickup_visual.gd")


func test_xp_pickup_uses_pickup_visual() -> void:
	var pickup: Node = add_child_autofree(load("res://scenes/pickups/xp_pickup.tscn").instantiate())
	var visual: Node = pickup.get_node_or_null("PickupVisual")
	assert_not_null(visual, "XP pickup must have a PickupVisual node")
	if visual:
		assert_eq(visual.kind, PickupVisual.Kind.XP)
	assert_null(pickup.get_node_or_null("Sprite"), "XP pickup must not keep the ColorRect placeholder")


func test_health_pickup_uses_pickup_visual() -> void:
	var pickup: Node = add_child_autofree(load("res://scenes/pickups/pickup_health.tscn").instantiate())
	var visual: Node = pickup.get_node_or_null("PickupVisual")
	assert_not_null(visual, "Health pickup must have a PickupVisual node")
	if visual:
		assert_eq(visual.kind, PickupVisual.Kind.HEALTH)
	assert_null(pickup.get_node_or_null("Sprite"), "Health pickup must not keep the ColorRect placeholder")


func test_comet_uses_comet_visual() -> void:
	var comet: Node = add_child_autofree(load("res://scenes/world/comet.tscn").instantiate())
	assert_not_null(comet.get_node_or_null("CometVisual"), "Comet must have a CometVisual node")
	assert_null(comet.get_node_or_null("Polygon"), "Comet must not keep the Polygon2D placeholder")
