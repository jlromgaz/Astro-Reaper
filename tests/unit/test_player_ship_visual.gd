extends GutTest
## Unit tests for the player ship visual silhouettes
## (scripts/player/player_ship_visual.gd). Written BEFORE the
## implementation (TDD): one distinct procedural shape per selectable ship.

const ShipVisual := preload("res://scripts/player/player_ship_visual.gd")

const SHIP_IDS: Array[String] = ["stellar", "vanguard", "interceptor", "phantom"]


func _make_visual() -> Node2D:
	var parent := CharacterBody2D.new()
	var visual: Node2D = ShipVisual.new()
	visual.name = "ShipVisual"
	parent.add_child(visual)
	add_child_autofree(parent)
	return visual


## --- Ship id to shape mapping ---

func test_set_ship_shape_stellar() -> void:
	var visual := _make_visual()
	visual.set_ship_shape("stellar")
	assert_eq(visual._shape, ShipVisual.ShipShape.STELLAR)


func test_set_ship_shape_vanguard() -> void:
	var visual := _make_visual()
	visual.set_ship_shape("vanguard")
	assert_eq(visual._shape, ShipVisual.ShipShape.VANGUARD)


func test_set_ship_shape_interceptor() -> void:
	var visual := _make_visual()
	visual.set_ship_shape("interceptor")
	assert_eq(visual._shape, ShipVisual.ShipShape.INTERCEPTOR)


func test_set_ship_shape_phantom() -> void:
	var visual := _make_visual()
	visual.set_ship_shape("phantom")
	assert_eq(visual._shape, ShipVisual.ShipShape.PHANTOM)


func test_unknown_ship_id_defaults_to_stellar() -> void:
	var visual := _make_visual()
	visual.set_ship_shape("phantom")  # Move away from the default first
	visual.set_ship_shape("wat")
	assert_eq(visual._shape, ShipVisual.ShipShape.STELLAR, "Unknown id must fall back to STELLAR")


## --- Body silhouettes ---

func test_body_points_non_empty_and_distinct_per_shape() -> void:
	var visual := _make_visual()
	var seen: Array[PackedVector2Array] = []
	for ship_id in SHIP_IDS:
		visual.set_ship_shape(ship_id)
		var points: PackedVector2Array = visual._body_points()
		assert_gt(points.size(), 2, "%s silhouette must be a polygon" % ship_id)
		for previous in seen:
			assert_ne(points, previous, "%s silhouette must differ from the other ships" % ship_id)
		seen.append(points)


func test_each_shape_draws_without_errors() -> void:
	for ship_id in SHIP_IDS:
		var visual := _make_visual()
		visual.set_ship_shape(ship_id)
		await get_tree().process_frame
		assert_true(is_instance_valid(visual), "%s visual must survive a draw frame" % ship_id)
