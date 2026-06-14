# GdUnit generated TestSuite
extends GdUnitTestSuite


func before() -> void:
	get_tree().paused = false


func test_starts_at_level_one_with_zero_xp() -> void:
	var xp_system: XpSystem = auto_free(XpSystem.new()) as XpSystem
	add_child(xp_system)
	await _wait_ready(xp_system)
	assert_int(xp_system.level).is_equal(1)
	assert_int(xp_system.current_xp).is_equal(0)
	assert_int(xp_system.xp_to_next).is_equal(20)


func test_pickup_adds_xp() -> void:
	var xp_system: XpSystem = auto_free(XpSystem.new()) as XpSystem
	add_child(xp_system)
	await _wait_ready(xp_system)
	EventBus.pickup_collected.emit(&"xp_small", Vector2.ZERO, 5)
	assert_int(xp_system.current_xp).is_equal(5)


func test_level_up_at_threshold() -> void:
	var xp_system: XpSystem = auto_free(XpSystem.new()) as XpSystem
	add_child(xp_system)
	await _wait_ready(xp_system)
	xp_system.add_xp(20)
	assert_int(xp_system.level).is_equal(2)
	assert_int(xp_system.current_xp).is_equal(0)


func test_health_pickup_ignored() -> void:
	var xp_system: XpSystem = auto_free(XpSystem.new()) as XpSystem
	add_child(xp_system)
	await _wait_ready(xp_system)
	EventBus.pickup_collected.emit(&"health", Vector2.ZERO, 15)
	assert_int(xp_system.current_xp).is_equal(0)


func test_level_up_emits_signal() -> void:
	var xp_system: XpSystem = auto_free(XpSystem.new()) as XpSystem
	add_child(xp_system)
	await _wait_ready(xp_system)
	var levels: Array[int] = []
	EventBus.level_up.connect(func(level: int) -> void: levels.append(level))
	xp_system.add_xp(20)
	assert_int(levels.size()).is_equal(1)
	assert_int(levels[0]).is_equal(2)


func test_xp_changed_emits_current_progress() -> void:
	var xp_system: XpSystem = auto_free(XpSystem.new()) as XpSystem
	add_child(xp_system)
	await _wait_ready(xp_system)
	var snapshots: Array[Vector3i] = []
	EventBus.xp_changed.connect(
		func(current: int, to_next: int, level: int) -> void:
			snapshots.append(Vector3i(current, to_next, level))
	)
	xp_system.add_xp(7)
	assert_int(snapshots.size()).is_greater_equal(1)
	var last: Vector3i = snapshots[snapshots.size() - 1]
	assert_int(last.x).is_equal(7)
	assert_int(last.y).is_equal(20)
	assert_int(last.z).is_equal(1)


func test_xp_to_next_increases_after_level_up() -> void:
	var xp_system: XpSystem = auto_free(XpSystem.new()) as XpSystem
	add_child(xp_system)
	await _wait_ready(xp_system)
	xp_system.add_xp(20)
	assert_int(xp_system.xp_to_next).is_equal(25)


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
