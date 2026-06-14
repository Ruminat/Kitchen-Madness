# GdUnit generated TestSuite
extends GdUnitTestSuite


func before() -> void:
	get_tree().paused = false


func test_spawns_label_on_damage_dealt() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)
	var before := manager.get_child_count()

	EventBus.damage_dealt.emit(Vector2(40.0, 20.0), 12, false)

	assert_int(manager.get_child_count()).is_equal(before + 1)
	var label: Label = manager.get_child(before) as Label
	assert_str(label.text).is_equal("12")


func test_spawns_crit_damage_label() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)

	EventBus.damage_dealt.emit(Vector2.ZERO, 25, true)

	var label: Label = manager.get_child(manager.get_child_count() - 1) as Label
	assert_str(label.text).is_equal("25")


func test_spawns_xp_pickup_label() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)
	var before := manager.get_child_count()

	EventBus.pickup_collected.emit(&"xp_small", Vector2(10.0, 5.0), 5)

	assert_int(manager.get_child_count()).is_equal(before + 1)
	var label: Label = manager.get_child(before) as Label
	assert_str(label.text).is_equal("+5 XP")


func test_spawns_health_pickup_label() -> void:
	var manager: Control = _create_manager()
	await _wait_ready(manager)
	var before := manager.get_child_count()

	EventBus.pickup_collected.emit(&"health", Vector2.ZERO, 15)

	assert_int(manager.get_child_count()).is_equal(before + 1)
	var label: Label = manager.get_child(before) as Label
	assert_str(label.text).is_equal("+15 HP")


func _create_manager() -> Control:
	var manager: Control = auto_free(Control.new()) as Control
	manager.set_script(load("res://scripts/ui/floating_text_manager.gd"))
	add_child(manager)
	return manager


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
