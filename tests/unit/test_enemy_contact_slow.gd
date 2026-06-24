# GdUnit generated TestSuite
extends GdUnitTestSuite

const CHASER_DEFINITION := preload("res://resources/enemies/chaser.tres")
const ENEMY_SCENE := preload("res://scenes/enemy/enemy.tscn")


func test_apply_contact_slow_reduces_move_speed() -> void:
	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	enemy.configure(CHASER_DEFINITION)
	await _wait_ready(enemy)

	enemy.apply_contact_slow(2.0)

	var expected := CHASER_DEFINITION.move_speed * BaseEnemy.CONTACT_SLOW_MULTIPLIER
	assert_float(enemy.move_speed).is_equal(expected)


func test_contact_slow_expires_after_duration() -> void:
	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	enemy.configure(CHASER_DEFINITION)
	await _wait_ready(enemy)

	enemy.apply_contact_slow(0.2)
	enemy._physics_process(0.25)

	assert_float(enemy.move_speed).is_equal(CHASER_DEFINITION.move_speed)


func test_contact_slow_refreshes_timer() -> void:
	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	enemy.configure(CHASER_DEFINITION)
	await _wait_ready(enemy)

	enemy.apply_contact_slow(2.0)
	enemy._physics_process(1.5)
	enemy.apply_contact_slow(2.0)
	enemy._physics_process(1.0)

	var expected := CHASER_DEFINITION.move_speed * BaseEnemy.CONTACT_SLOW_MULTIPLIER
	assert_float(enemy.move_speed).is_equal(expected)


func test_enemy_stops_moving_when_overlapping_player() -> void:
	var player: Node2D = auto_free(Node2D.new()) as Node2D
	player.add_to_group("player")
	add_child(player)
	player.global_position = Vector2(100.0, 100.0)

	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	enemy.configure(CHASER_DEFINITION)
	enemy.set_target(player)
	await _wait_ready(enemy)

	var touch_distance := (
		CHASER_DEFINITION.radius
		+ BaseEnemy.PLAYER_BODY_RADIUS
		+ BaseEnemy.PLAYER_CONTACT_FORGIVENESS
	)
	enemy.global_position = player.global_position + Vector2(touch_distance - 1.0, 0.0)
	var start_pos := enemy.global_position

	enemy._physics_process(0.1)

	assert_vector(enemy.global_position).is_equal(start_pos)
	assert_vector(enemy.velocity).is_equal(Vector2.ZERO)


func test_take_damage_does_not_emit_damage_dealt() -> void:
	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	enemy.configure(CHASER_DEFINITION)
	await _wait_ready(enemy)

	var emission_info := {"count": 0}
	EventBus.damage_dealt.connect(
		func(_pos: Vector2, _amount: int, _is_crit: bool) -> void: emission_info.count += 1
	)

	enemy.take_damage(5)

	assert_int(emission_info.count).is_equal(0)
	assert_int(enemy.health_component.current_health).is_equal(CHASER_DEFINITION.max_health - 5)


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
