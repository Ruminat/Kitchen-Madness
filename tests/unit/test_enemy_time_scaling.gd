# GdUnit generated TestSuite
extends GdUnitTestSuite

const ENEMY_SCENE := preload("res://scenes/enemy/enemy.tscn")
const CHASER_DEF := preload("res://resources/enemies/chaser.tres")


func test_configure_for_time_scales_health_and_contact_damage() -> void:
	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	if not enemy.is_node_ready():
		await enemy.ready
	enemy.configure_for_time(CHASER_DEF, 180.0)

	var health := enemy.health_component
	var expected_health := LevelDefinition.resolve_enemy_health(CHASER_DEF.max_health, 180.0)
	var expected_damage := LevelDefinition.resolve_contact_damage(CHASER_DEF.contact_damage, 180.0)
	assert_int(health.max_health).is_equal(expected_health)
	assert_int(enemy.get_contact_damage()).is_equal(expected_damage)


func test_configure_uses_level_start_scaling() -> void:
	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	if not enemy.is_node_ready():
		await enemy.ready
	enemy.configure(CHASER_DEF)

	assert_int(enemy.health_component.max_health).is_equal(CHASER_DEF.max_health)
	assert_int(enemy.get_contact_damage()).is_equal(CHASER_DEF.contact_damage)
