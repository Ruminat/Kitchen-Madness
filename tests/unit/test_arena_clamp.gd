# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_clamps_position_inside_bounds() -> void:
	var bounds := Rect2(-100.0, -50.0, 200.0, 100.0)
	var clamped := ArenaClamp.clamp_position(Vector2(-200.0, 0.0), bounds, 10.0)
	assert_vector(clamped).is_equal(Vector2(-90.0, 0.0))


func test_clamps_position_on_all_edges() -> void:
	var bounds := Rect2(-10.0, -10.0, 20.0, 20.0)
	var top_left := ArenaClamp.clamp_position(Vector2(-100.0, -100.0), bounds, 5.0)
	assert_vector(top_left).is_equal(Vector2(-5.0, -5.0))
	var bottom_right := ArenaClamp.clamp_position(Vector2(100.0, 100.0), bounds, 5.0)
	assert_vector(bottom_right).is_equal(Vector2(5.0, 5.0))
