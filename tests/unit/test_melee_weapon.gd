# GdUnit generated TestSuite
extends GdUnitTestSuite

const MELEE_SCRIPT := preload("res://scripts/weapons/melee_weapon.gd")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")
const PAN_DEF := preload("res://resources/weapons/frying_pan.tres")


class MockMeleeEnemy:
	extends Node2D

	var last_damage := 0
	var knockback_calls := 0
	var last_knockback := Vector2.ZERO

	func _init() -> void:
		add_to_group("enemies")

	func take_damage(amount: int) -> void:
		last_damage = amount

	func get_collision_radius() -> float:
		return 12.0

	func apply_knockback(direction: Vector2, force: float) -> void:
		knockback_calls += 1
		last_knockback = direction * force


func after_test() -> void:
	# Keep the shared "enemies" group clean between tests (and suites).
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			enemy.remove_from_group("enemies")


func test_kitchen_knife_is_melee_weapon() -> void:
	assert_int(KNIFE_DEF.weapon_type).is_equal(WeaponDefinition.WeaponType.MELEE)
	assert_object(KNIFE_DEF.weapon_script).is_same(MELEE_SCRIPT)
	assert_object(KNIFE_DEF.projectile_scene).is_null()


func test_frying_pan_is_melee_weapon_with_knockback() -> void:
	assert_int(PAN_DEF.weapon_type).is_equal(WeaponDefinition.WeaponType.MELEE)
	assert_float(PAN_DEF.area).is_greater(0.0)
	assert_float(PAN_DEF.melee_knockback).is_greater(0.0)


func test_melee_swing_hits_the_target_enemy() -> void:
	var weapon := _melee_weapon(KNIFE_DEF)
	var enemy := _enemy(Vector2(40.0, 0.0))

	weapon._perform_swing(Vector2.ZERO, enemy)

	assert_int(enemy.last_damage).is_equal(KNIFE_DEF.damage)


func test_melee_hits_a_circle_around_the_target_not_a_cone() -> void:
	var weapon := _melee_weapon(KNIFE_DEF)
	# Circle radius = area (diameter) / 2 = 20 units / 2 = 10 units ≈ 73 px.
	var target := _enemy(Vector2(200.0, 0.0))
	var neighbor := _enemy(Vector2(200.0, 60.0))  # ~60 px from the target -> inside
	var far := _enemy(Vector2(200.0, 400.0))  # far from the target -> outside

	weapon._perform_swing(Vector2.ZERO, target)

	assert_int(target.last_damage).is_equal(KNIFE_DEF.damage)
	assert_int(neighbor.last_damage).is_equal(KNIFE_DEF.damage)
	assert_int(far.last_damage).is_equal(0)


func test_melee_only_targets_enemies_within_attack_range() -> void:
	var weapon := _melee_weapon(KNIFE_DEF)
	# Kitchen Knife attack_range = 10 units ≈ 73 px.
	var in_range := _enemy(Vector2(60.0, 0.0))
	assert_object(weapon._find_melee_target(Vector2.ZERO)).is_same(in_range)

	in_range.remove_from_group("enemies")
	_enemy(Vector2(400.0, 0.0))  # only a far enemy remains
	assert_object(weapon._find_melee_target(Vector2.ZERO)).is_null()


func test_melee_swing_applies_knockback_for_frying_pan() -> void:
	var weapon := _melee_weapon(PAN_DEF)
	var enemy := _enemy(Vector2(30.0, 0.0))

	weapon._perform_swing(Vector2.ZERO, enemy)

	assert_int(enemy.last_damage).is_equal(PAN_DEF.damage)
	assert_int(enemy.knockback_calls).is_equal(1)
	assert_float(enemy.last_knockback.length()).is_greater(0.0)


func _melee_weapon(definition: WeaponDefinition) -> Node2D:
	var weapon: Node2D = Node2D.new()
	weapon.set_script(MELEE_SCRIPT)
	add_child(weapon)
	weapon.setup(definition, Rect2(), null)
	weapon.set_crit_stats(0.0, 1.5)  # deterministic: no crit roll
	return weapon


func _enemy(position: Vector2) -> MockMeleeEnemy:
	var enemy: MockMeleeEnemy = auto_free(MockMeleeEnemy.new()) as MockMeleeEnemy
	add_child(enemy)
	enemy.global_position = position
	return enemy
