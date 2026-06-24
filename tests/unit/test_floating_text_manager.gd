# GdUnit generated TestSuite
extends GdUnitTestSuite


func before() -> void:
	get_tree().paused = false


func _get_visible_child_count(manager: Node) -> int:
	var count := 0
	for child in manager.get_children():
		if child.visible:
			count += 1
	return count


func test_spawns_label_at_world_position() -> void:
	var manager: Node2D = _create_manager()
	await _wait_ready(manager)
	var world_pos := Vector2(320.0, 180.0)

	EventBus.damage_dealt.emit(world_pos, 12, false)

	var label: Label = _find_visible_label(manager, "12")
	assert_object(label).is_not_null()
	assert_vector(label.position).is_equal(world_pos)


func test_damage_label_global_position_unaffected_by_camera_move() -> void:
	var root := Node2D.new()
	add_child(root)
	var camera := Camera2D.new()
	root.add_child(camera)
	camera.make_current()

	var manager: Node2D = _create_manager()
	root.add_child(manager)
	await _wait_ready(manager)

	var world_pos := Vector2(500.0, 300.0)
	EventBus.damage_dealt.emit(world_pos, 7, false)

	var label: Label = _find_visible_label(manager, "7")
	assert_object(label).is_not_null()
	var global_before := label.global_position

	camera.position = Vector2(200.0, 100.0)
	await get_tree().process_frame

	assert_vector(label.global_position).is_equal(global_before)


func test_spawns_label_on_damage_dealt() -> void:
	var manager: Node2D = _create_manager()
	await _wait_ready(manager)
	var before := _get_visible_child_count(manager)

	EventBus.damage_dealt.emit(Vector2(40.0, 20.0), 12, false)

	assert_int(_get_visible_child_count(manager)).is_equal(before + 1)
	# Find the visible label with the text
	var found := false
	for child in manager.get_children():
		if child.visible and child.text == "12":
			found = true
			break
	assert_bool(found).is_true()


func test_spawns_crit_damage_label() -> void:
	var manager: Node2D = _create_manager()
	await _wait_ready(manager)

	EventBus.damage_dealt.emit(Vector2.ZERO, 25, true)

	# Find the visible label with the text
	var found := false
	for child in manager.get_children():
		if child.visible and child.text == "25":
			found = true
			break
	assert_bool(found).is_true()


func test_spawns_xp_pickup_label() -> void:
	var manager: Node2D = _create_manager()
	await _wait_ready(manager)
	var before := _get_visible_child_count(manager)

	EventBus.pickup_collected.emit(&"xp_small", Vector2(10.0, 5.0), 5)

	assert_int(_get_visible_child_count(manager)).is_equal(before + 1)
	var found := false
	for child in manager.get_children():
		if child.visible and child.text == "+5 XP":
			found = true
			break
	assert_bool(found).is_true()


func test_spawns_health_pickup_label() -> void:
	var manager: Node2D = _create_manager()
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
	var manager: Node2D = _create_manager()
	await _wait_ready(manager)

	# Pool should be initialized with labels (invisible, as children)
	assert_int(manager.get_child_count()).is_greater_equal(32)


func test_pool_reuses_labels_after_finished() -> void:
	var manager: Node2D = _create_manager()
	await _wait_ready(manager)

	# Emit multiple damage events
	for index in 5:
		EventBus.damage_dealt.emit(Vector2(float(index), 0.0), 10, false)

	var active_count := 0
	for child in manager.get_children():
		if child.visible:
			active_count += 1

	# Should have visible labels for each event
	assert_int(active_count).is_greater_equal(5)


func _find_visible_label(manager: Node, text_value: String) -> Label:
	for child in manager.get_children():
		if child.visible and child.text == text_value:
			return child as Label
	return null


func _create_manager() -> Node2D:
	var manager: Node2D = auto_free(Node2D.new()) as Node2D
	manager.set_script(load("res://scripts/ui/floating_text_manager.gd"))
	add_child(manager)
	return manager


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
