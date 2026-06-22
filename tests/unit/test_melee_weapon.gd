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


func test_kitchen_knife_is_melee_weapon() -> void:
	assert_int(KNIFE_DEF.weapon_type).is_equal(WeaponDefinition.WeaponType.MELEE)
	assert_object(KNIFE_DEF.weapon_script).is_same(MELEE_SCRIPT)
	assert_object(KNIFE_DEF.projectile_scene).is_null()


func test_frying_pan_is_melee_weapon_with_knockback() -> void:
	assert_int(PAN_DEF.weapon_type).is_equal(WeaponDefinition.WeaponType.MELEE)
	assert_float(PAN_DEF.melee_arc_degrees).is_equal(180.0)
	assert_float(PAN_DEF.melee_knockback).is_greater(0.0)


func test_is_target_in_arc_accepts_forward_target() -> void:
	var in_arc := MELEE_SCRIPT.is_target_in_arc(
		Vector2.ZERO, Vector2.RIGHT, Vector2(40.0, 0.0), 12.0, 50.0, 60.0
	)
	assert_bool(in_arc).is_true()


func test_is_target_in_arc_rejects_out_of_range_target() -> void:
	var in_arc := MELEE_SCRIPT.is_target_in_arc(
		Vector2.ZERO, Vector2.RIGHT, Vector2(120.0, 0.0), 12.0, 50.0, 180.0
	)
	assert_bool(in_arc).is_false()


func test_is_target_in_arc_rejects_behind_target_for_narrow_arc() -> void:
	var in_arc := MELEE_SCRIPT.is_target_in_arc(
		Vector2.ZERO, Vector2.RIGHT, Vector2(-30.0, 0.0), 12.0, 50.0, 50.0
	)
	assert_bool(in_arc).is_false()


func test_is_target_in_arc_accepts_side_target_for_wide_arc() -> void:
	var in_arc := MELEE_SCRIPT.is_target_in_arc(
		Vector2.ZERO, Vector2.RIGHT, Vector2(20.0, 35.0), 12.0, 60.0, 180.0
	)
	assert_bool(in_arc).is_true()


func test_melee_swing_hits_enemy_in_arc() -> void:
	var weapon: Node2D = Node2D.new()
	weapon.set_script(MELEE_SCRIPT)
	add_child(weapon)
	weapon.setup(KNIFE_DEF, Rect2(), null)

	var enemy := MockMeleeEnemy.new()
	add_child(enemy)
	enemy.global_position = Vector2(40.0, 0.0)

	var emission_info := {"count": 0, "amount": 0}
	EventBus.damage_dealt.connect(
		func(_pos: Vector2, amount: int, _is_crit: bool) -> void:
			emission_info.count += 1
			emission_info.amount = amount
	)

	weapon._perform_swing(Vector2.ZERO, enemy)

	assert_int(enemy.last_damage).is_equal(KNIFE_DEF.damage)
	assert_int(emission_info.count).is_equal(1)
	assert_int(emission_info.amount).is_equal(KNIFE_DEF.damage)


func test_melee_swing_applies_knockback_for_frying_pan() -> void:
	var weapon: Node2D = Node2D.new()
	weapon.set_script(MELEE_SCRIPT)
	add_child(weapon)
	weapon.setup(PAN_DEF, Rect2(), null)

	var enemy := MockMeleeEnemy.new()
	add_child(enemy)
	enemy.global_position = Vector2(30.0, 0.0)

	weapon._perform_swing(Vector2.ZERO, enemy)

	assert_int(enemy.last_damage).is_equal(PAN_DEF.damage)
	assert_int(enemy.knockback_calls).is_equal(1)
	assert_float(enemy.last_knockback.length()).is_greater(0.0)
