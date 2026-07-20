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


func test_armor_reduces_damage_as_percentage() -> void:
	var health := _create_health_component(100, 0.0)
	await _wait_ready(health)
	health.increase_armor(3)
	var expected := StatUnits.apply_armor(20, 3)
	var dealt := health.take_damage(20)
	assert_int(dealt).is_equal(expected)
	assert_int(health.current_health).is_equal(100 - expected)
	assert_int(dealt).is_less(20)


func test_armor_keeps_minimum_of_one_damage() -> void:
	var health := _create_health_component(100, 0.0)
	await _wait_ready(health)
	health.increase_armor(1000)
	assert_int(health.take_damage(1)).is_equal(1)


func test_negative_armor_increases_damage() -> void:
	var health := _create_health_component(100, 0.0)
	await _wait_ready(health)
	health.increase_armor(-4)
	assert_int(health.take_damage(20)).is_greater(20)


func test_evasion_negates_damage_but_grants_iframes() -> void:
	var health := _create_health_component(100, 0.2)
	await _wait_ready(health)
	health.set_evasion(1.0)
	var evaded_signals: Array = []
	health.evaded.connect(func() -> void: evaded_signals.append(true))

	var dealt := health.take_damage(30)

	assert_int(dealt).is_equal(0)
	assert_int(health.current_health).is_equal(100)
	assert_int(evaded_signals.size()).is_equal(1)
	# The evade still triggers the invulnerability window.
	assert_bool(health.is_invincible()).is_true()


func test_take_damage_returns_amount_dealt() -> void:
	var health := _create_health_component(100, 0.0)
	await _wait_ready(health)
	assert_int(health.take_damage(15)).is_equal(15)


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
