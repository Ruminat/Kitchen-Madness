# GdUnit generated TestSuite
extends GdUnitTestSuite

const ENEMY_SCENE := preload("res://scenes/enemy/enemy.tscn")
const CHASER_DEF := preload("res://resources/enemies/chaser.tres")
const TANK_DEF := preload("res://resources/enemies/tank.tres")


func test_tank_enemy_gets_health_bar() -> void:
	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	enemy.configure(TANK_DEF)
	await _wait_ready(enemy)
	assert_bool(enemy.has_node("EnemyHealthBar")).is_true()


func test_chaser_enemy_has_no_health_bar() -> void:
	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	enemy.configure(CHASER_DEF)
	await _wait_ready(enemy)
	assert_bool(enemy.has_node("EnemyHealthBar")).is_false()


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
