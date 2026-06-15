# GdUnit generated TestSuite
extends GdUnitTestSuite


class MockEnemy:
	extends Node2D

	var definition: EnemyDefinition


class MockLuckyPlayer:
	extends Node

	var luck := 0

	func _init(initial_luck: int) -> void:
		luck = initial_luck

	func get_gold_multiplier() -> float:
		return 1.0 + float(luck) * 0.01


func before() -> void:
	get_tree().paused = false


func test_enemy_kill_awards_gold_from_definition() -> void:
	var gold_system := _create_gold_system()
	var enemy := _create_enemy(3)

	EventBus.enemy_killed.emit(enemy, null)

	assert_int(gold_system.gold).is_equal(3)


func test_zero_gold_reward_does_not_change_balance() -> void:
	var gold_system := _create_gold_system()
	var enemy := _create_enemy(0)

	EventBus.enemy_killed.emit(enemy, null)

	assert_int(gold_system.gold).is_equal(0)


func test_spend_gold_deducts_and_emits() -> void:
	var gold_system := _create_gold_system()
	gold_system.add_gold(10)

	assert_bool(gold_system.spend_gold(4)).is_true()
	assert_int(gold_system.gold).is_equal(6)


func test_spend_gold_fails_when_insufficient() -> void:
	var gold_system := _create_gold_system()
	gold_system.add_gold(5)

	assert_bool(gold_system.spend_gold(8)).is_false()
	assert_int(gold_system.gold).is_equal(5)


func test_luck_boosts_gold_from_kills() -> void:
	var gold_system := _create_gold_system()
	var player: MockLuckyPlayer = auto_free(MockLuckyPlayer.new(10)) as MockLuckyPlayer
	player.add_to_group("player")
	add_child(player)
	var enemy := _create_enemy(10)

	EventBus.enemy_killed.emit(enemy, null)

	assert_int(gold_system.gold).is_equal(11)


func _create_gold_system() -> GoldSystem:
	var gold_system: GoldSystem = auto_free(GoldSystem.new()) as GoldSystem
	add_child(gold_system)
	return gold_system


func _create_enemy(reward: int) -> MockEnemy:
	var definition := EnemyDefinition.new()
	definition.gold_reward = reward

	var enemy: MockEnemy = auto_free(MockEnemy.new()) as MockEnemy
	enemy.definition = definition
	add_child(enemy)
	return enemy
