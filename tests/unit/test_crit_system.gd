# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const PROJECTILE_SCENE := preload("res://scenes/projectiles/projectile.tscn")


class MockEnemy:
	extends Node2D

	var last_damage := 0

	func take_damage(amount: int) -> void:
		last_damage = amount


func test_player_starts_with_default_crit_stats() -> void:
	var player := await _create_player()

	assert_float(player.get_crit_chance()).is_equal(0.05)
	assert_float(player.get_crit_damage()).is_equal(1.5)


func test_crit_chance_increases_correctly() -> void:
	var player := await _create_player()

	player.increase_crit_chance(0.03)

	assert_float(player.get_crit_chance()).is_equal(0.08)


func test_crit_damage_increases_correctly() -> void:
	var player := await _create_player()

	player.increase_crit_damage(0.20)

	assert_float(player.get_crit_damage()).is_equal_approx(1.8, 0.001)


func test_crit_chance_capped_at_100_percent() -> void:
	var player := await _create_player()

	player.increase_crit_chance(0.5)
	player.increase_crit_chance(0.5)

	assert_float(player.get_crit_chance()).is_equal(1.0)


func test_crit_damage_stacks_multiplicatively() -> void:
	var player := await _create_player()

	player.increase_crit_damage(0.25)
	player.increase_crit_damage(0.25)

	assert_float(player.get_crit_damage()).is_equal(2.34375)


func test_upgrade_definition_applies_crit_chance() -> void:
	var player := await _create_player()
	var upgrade := _create_upgrade(&"crit_chance_flat", 0.04)

	upgrade.apply(player)

	assert_float(player.get_crit_chance()).is_equal(0.09)


func test_upgrade_definition_applies_crit_damage() -> void:
	var player := await _create_player()
	var upgrade := _create_upgrade(&"crit_damage_percent", 0.20)

	upgrade.apply(player)

	assert_float(abs(player.get_crit_damage() - 1.8)).is_less_equal(0.0001)


func test_projectile_with_100_crit_chance_always_crits() -> void:
	var projectile: Area2D = auto_free(PROJECTILE_SCENE.instantiate()) as Area2D
	add_child(projectile)
	projectile.setup(Vector2.RIGHT, Rect2(-100, -100, 200, 200), 10, 400.0, 1.0, null, Color.WHITE)
	projectile.set_crit_stats(1.0, 2.0)
	await _wait_ready(projectile)

	var enemy := MockEnemy.new()
	enemy.add_to_group("enemies")
	add_child(enemy)

	projectile._on_body_entered(enemy)

	assert_int(enemy.last_damage).is_equal(20)


func test_projectile_with_0_crit_chance_never_crits() -> void:
	var projectile: Area2D = auto_free(PROJECTILE_SCENE.instantiate()) as Area2D
	add_child(projectile)
	projectile.setup(Vector2.RIGHT, Rect2(-100, -100, 200, 200), 10, 400.0, 1.0, null, Color.WHITE)
	projectile.set_crit_stats(0.0, 2.0)
	await _wait_ready(projectile)

	var enemy := MockEnemy.new()
	enemy.add_to_group("enemies")
	add_child(enemy)

	projectile._on_body_entered(enemy)

	assert_int(enemy.last_damage).is_equal(10)


func test_crit_damage_emits_damage_dealt_signal() -> void:
	var projectile: Area2D = auto_free(PROJECTILE_SCENE.instantiate()) as Area2D
	add_child(projectile)
	projectile.setup(Vector2.RIGHT, Rect2(-100, -100, 200, 200), 10, 400.0, 1.0, null, Color.WHITE)
	projectile.set_crit_stats(1.0, 2.0)
	await _wait_ready(projectile)

	var damage_info := {"amount": 0, "is_crit": false}
	EventBus.damage_dealt.connect(
		func(_pos: Vector2, amount: int, is_crit: bool) -> void:
			damage_info.amount = amount
			damage_info.is_crit = is_crit
	)

	var enemy := MockEnemy.new()
	enemy.add_to_group("enemies")
	enemy.global_position = Vector2(50, 0)
	add_child(enemy)

	projectile._on_body_entered(enemy)

	assert_int(damage_info.amount).is_equal(20)
	assert_bool(damage_info.is_crit).is_true()


func test_projectile_hit_emits_damage_dealt_once() -> void:
	var projectile: Area2D = auto_free(PROJECTILE_SCENE.instantiate()) as Area2D
	add_child(projectile)
	projectile.setup(Vector2.RIGHT, Rect2(-100, -100, 200, 200), 10, 400.0, 1.0, null, Color.WHITE)
	projectile.set_crit_stats(0.0, 1.5)
	await _wait_ready(projectile)

	var emission_info := {"count": 0}
	EventBus.damage_dealt.connect(
		func(_pos: Vector2, _amount: int, _is_crit: bool) -> void: emission_info.count += 1
	)

	var enemy := MockEnemy.new()
	enemy.add_to_group("enemies")
	add_child(enemy)

	projectile._on_body_entered(enemy)

	assert_int(emission_info.count).is_equal(1)


func _create_player() -> CharacterBody2D:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	if not player.is_node_ready():
		await player.ready
	return player


func _create_upgrade(effect: StringName, amount: float) -> UpgradeDefinition:
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = effect
	upgrade.amount = amount
	return upgrade


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
