# GdUnit generated TestSuite
extends GdUnitTestSuite


func _make_target_with_idle(base_scale: Vector2) -> Array:
	var target: Node2D = auto_free(Node2D.new()) as Node2D
	target.scale = base_scale
	var idle := IdleSquash.new()
	target.add_child(idle)
	add_child(target)
	if not idle.is_node_ready():
		await idle.ready
	return [target, idle]


func test_idle_squash_stretches_and_squashes_the_target() -> void:
	var pair := await _make_target_with_idle(Vector2(2.0, 2.0))
	var target: Node2D = pair[0]
	var idle: IdleSquash = pair[1]

	# Quarter cycle -> sin = 1 -> maximum squash.
	idle._time = idle.cycle_seconds * 0.25
	idle._process(0.0)

	assert_float(target.scale.x).is_greater(2.0)
	assert_float(target.scale.y).is_less(2.0)
	assert_float(target.position.y).is_greater(0.0)


func test_set_active_false_restores_rest_pose() -> void:
	var pair := await _make_target_with_idle(Vector2(3.0, 3.0))
	var target: Node2D = pair[0]
	var idle: IdleSquash = pair[1]

	idle._time = idle.cycle_seconds * 0.25
	idle._process(0.0)
	idle.set_active(false)

	assert_vector(target.scale).is_equal(Vector2(3.0, 3.0))
	assert_vector(target.position).is_equal(Vector2.ZERO)


func test_hidden_target_is_not_animated() -> void:
	var pair := await _make_target_with_idle(Vector2(1.5, 1.5))
	var target: Node2D = pair[0]
	var idle: IdleSquash = pair[1]

	target.visible = false
	idle._time = idle.cycle_seconds * 0.25
	idle._process(0.1)

	assert_vector(target.scale).is_equal(Vector2(1.5, 1.5))
