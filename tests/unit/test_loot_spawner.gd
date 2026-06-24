# GdUnit generated TestSuite
extends GdUnitTestSuite

const XP_ORB_SCENE := preload("res://scenes/pickups/xp_orb.tscn")


class MockEnemy:
	extends Node2D

	var definition: EnemyDefinition


func test_zero_xp_drop_chance_spawns_no_orb() -> void:
	var spawner := _create_spawner()
	spawner.xp_drop_chance = 0.0
	var enemy := _create_enemy_with_xp()

	EventBus.enemy_killed.emit(enemy, null)

	assert_int(spawner.pickup_container.get_child_count()).is_equal(0)


func test_guaranteed_xp_drop_chance_spawns_orb() -> void:
	var spawner := _create_spawner()
	spawner.xp_drop_chance = 1.0
	var enemy := _create_enemy_with_xp()

	EventBus.enemy_killed.emit(enemy, null)

	assert_int(spawner.pickup_container.get_child_count()).is_equal(1)


func test_zero_health_drop_chance_spawns_no_health() -> void:
	var spawner := _create_spawner()
	spawner.health_drop_chance = 0.0
	var enemy := _create_enemy_with_xp()

	EventBus.enemy_killed.emit(enemy, null)

	assert_int(spawner.pickup_container.get_child_count()).is_equal(0)


func _create_spawner() -> LootSpawner:
	var container: Node2D = auto_free(Node2D.new()) as Node2D
	add_child(container)

	var health_drop := DropDefinition.new()
	health_drop.id = "health"
	health_drop.scene = XP_ORB_SCENE
	health_drop.value = 15

	var spawner: LootSpawner = auto_free(LootSpawner.new()) as LootSpawner
	spawner.xp_drop_chance = 0.0
	spawner.configure(container, health_drop)
	add_child(spawner)
	return spawner


func _create_enemy_with_xp() -> MockEnemy:
	var xp_drop := DropDefinition.new()
	xp_drop.id = "xp_small"
	xp_drop.scene = XP_ORB_SCENE
	xp_drop.value = 5

	var definition := EnemyDefinition.new()
	definition.xp_drop = xp_drop

	var enemy: MockEnemy = auto_free(MockEnemy.new()) as MockEnemy
	enemy.definition = definition
	add_child(enemy)
	return enemy
