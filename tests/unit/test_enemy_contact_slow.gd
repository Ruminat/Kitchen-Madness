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


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
