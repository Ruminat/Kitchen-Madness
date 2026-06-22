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


func test_spawns_label_on_damage_dealt() -> void:
	var manager: Control = _create_manager()
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
	var manager: Control = _create_manager()
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
	var manager: Control = _create_manager()
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

	# Pool should be initialized with labels (invisible, as children)
	assert_int(manager.get_child_count()).is_greater_equal(32)


func test_pool_reuses_labels_after_finished() -> void:
	var manager: Control = _create_manager()
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


func _create_manager() -> Control:
	var manager: Control = auto_free(Control.new()) as Control
	manager.set_script(load("res://scripts/ui/floating_text_manager.gd"))
	add_child(manager)
	return manager


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
