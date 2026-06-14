# GdUnit generated TestSuite
extends GdUnitTestSuite


func before() -> void:
	get_tree().paused = false


func test_starts_at_max_health() -> void:
	var health := _create_health_component(100, 0.0)
	await _wait_ready(health)
	assert_int(health.current_health).is_equal(100)
	assert_bool(health.is_alive()).is_true()


func test_take_damage_reduces_health() -> void:
	var health := _create_health_component(100, 0.0)
	await _wait_ready(health)
	health.take_damage(30)
	assert_int(health.current_health).is_equal(70)


func test_death_at_zero_emits_died() -> void:
	var health := _create_health_component(50, 0.0)
	await _wait_ready(health)
	health.take_damage(50)
	assert_int(health.current_health).is_equal(0)
	assert_bool(health.is_alive()).is_false()


func test_invincibility_blocks_rapid_damage() -> void:
	var health := _create_health_component(100, 0.1)
	await _wait_ready(health)
	health.take_damage(10)
	assert_int(health.current_health).is_equal(90)
	health.take_damage(10)
	assert_int(health.current_health).is_equal(90)
	await await_millis(150)
	health.take_damage(10)
	assert_int(health.current_health).is_equal(80)


func test_heal_caps_at_max_health() -> void:
	var health := _create_health_component(100, 0.0)
	await _wait_ready(health)
	health.take_damage(20)
	health.heal(10)
	assert_int(health.current_health).is_equal(90)
	health.heal(100)
	assert_int(health.current_health).is_equal(100)


func _create_health_component(max_health: int, invincibility: float) -> HealthComponent:
	var host: Node = auto_free(Node.new())
	add_child(host)
	var health := HealthComponent.new()
	health.max_health = max_health
	health.invincibility_time = invincibility
	host.add_child(health)
	return health


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
