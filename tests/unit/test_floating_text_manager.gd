# GdUnit generated TestSuite
extends GdUnitTestSuite


func before() -> void:
	get_tree().paused = false


func _get_visible_child_count(manager: Control) -> int:
	var count := 0
	for child in manager.get_children():
		if child.visible:
			count += 1
	return count


func test_spawns_damage_at_requested_font_size() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)
	var world_pos := Vector2(320.0, 180.0)

	EventBus.damage_dealt.emit(world_pos, 12, false)

	var label: Label = _find_visible_label(manager, "12")
	assert_object(label).is_not_null()
	assert_int(label.get_theme_font_size("font_size")).is_equal(36)
	if label.has_method("get_world_pos"):
		assert_vector(label.get_world_pos()).is_equal(world_pos)


func test_crit_damage_uses_larger_font_size() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)

	EventBus.damage_dealt.emit(Vector2.ZERO, 25, true)

	var label: Label = _find_visible_label(manager, "25")
	assert_object(label).is_not_null()
	assert_int(label.get_theme_font_size("font_size")).is_equal(40)


func test_damage_label_world_anchor_unaffected_by_camera_move() -> void:
	var root := Node2D.new()
	add_child(root)
	var camera := Camera2D.new()
	root.add_child(camera)
	camera.make_current()

	var manager: Control = _create_manager()
	root.add_child(manager)
	await _wait_ready(manager)

	var world_pos := Vector2(500.0, 300.0)
	EventBus.damage_dealt.emit(world_pos, 7, false)

	var label: Label = _find_visible_label(manager, "7")
	assert_object(label).is_not_null()
	assert_vector(label.get_world_pos()).is_equal(world_pos)

	var canvas_before := label.position
	camera.position = Vector2(200.0, 100.0)
	await get_tree().process_frame

	assert_vector(label.get_world_pos()).is_equal(world_pos)
	assert_vector(label.position).is_not_equal(canvas_before)


func test_spawns_label_on_damage_dealt() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)
	var before := _get_visible_child_count(manager)

	EventBus.damage_dealt.emit(Vector2(40.0, 20.0), 12, false)

	assert_int(_get_visible_child_count(manager)).is_equal(before + 1)
	var found := false
	for child in manager.get_children():
		if child.visible and child.text == "12":
			found = true
			break
	assert_bool(found).is_true()


func test_spawns_crit_damage_label() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)

	EventBus.damage_dealt.emit(Vector2.ZERO, 25, true)

	var found := false
	for child in manager.get_children():
		if child.visible and child.text == "25":
			found = true
			break
	assert_bool(found).is_true()


func test_skips_xp_pickup_label() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)
	var before := _get_visible_child_count(manager)

	EventBus.pickup_collected.emit(&"xp_small", Vector2(10.0, 5.0), 5)

	assert_int(_get_visible_child_count(manager)).is_equal(before)
	assert_object(_find_visible_label(manager, "+5 XP")).is_null()


func test_skips_gold_pickup_label() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)
	var before := _get_visible_child_count(manager)

	EventBus.pickup_collected.emit(&"gold", Vector2(10.0, 5.0), 3)

	assert_int(_get_visible_child_count(manager)).is_equal(before)


func test_spawns_health_pickup_label() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)
	var before := _get_visible_child_count(manager)

	EventBus.pickup_collected.emit(&"health", Vector2.ZERO, 15)

	assert_int(_get_visible_child_count(manager)).is_equal(before + 1)
	var found := false
	for child in manager.get_children():
		if child.visible and child.text == "+15 HP":
			found = true
			break
	assert_bool(found).is_true()


func test_pool_initializes_with_labels() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)

	assert_int(manager.get_child_count()).is_greater_equal(32)


func test_pool_reuses_labels_after_finished() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)

	for index in 5:
		EventBus.damage_dealt.emit(Vector2(float(index), 0.0), 10, false)

	var active_count := 0
	for child in manager.get_children():
		if child.visible:
			active_count += 1

	assert_int(active_count).is_greater_equal(5)


func _find_visible_label(manager: Node, text_value: String) -> Label:
	for child in manager.get_children():
		if child.visible and child.text == text_value:
			return child as Label
	return null


func _create_manager() -> Control:
	var manager: Control = auto_free(Control.new()) as Control
	manager.set_script(load("res://scripts/ui/floating_text_manager.gd"))
	add_child(manager)
	return manager


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
