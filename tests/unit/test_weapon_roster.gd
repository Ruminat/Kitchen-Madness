# GdUnit generated TestSuite
extends GdUnitTestSuite

const PEPPER_DEF := preload("res://resources/weapons/pepper_grinder_gun.tres")
const SOUP_DEF := preload("res://resources/weapons/boiling_soup_splash.tres")
const ONION_RING_DEF := preload("res://resources/weapons/onion_ring_blade.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")
const PAN_DEF := preload("res://resources/weapons/frying_pan.tres")
const GARLIC_DEF := preload("res://resources/weapons/garlic_bomb.tres")
const LADLE_DEF := preload("res://resources/weapons/ladle_boomerang.tres")
const TOASTER_DEF := preload("res://resources/weapons/toaster_turret.tres")
const BURST_SCRIPT := preload("res://scripts/weapons/burst_weapon.gd")
const BOOMERANG_SCRIPT := preload("res://scripts/weapons/boomerang_weapon.gd")
const TURRET_SCRIPT := preload("res://scripts/weapons/turret_weapon.gd")
const ORBIT_SCRIPT := preload("res://scripts/weapons/orbit_weapon.gd")
const MELEE_SCRIPT := preload("res://scripts/weapons/melee_weapon.gd")


class MockOrbitEnemy:
	extends Node2D

	var last_damage := 0

	func take_damage(amount: int) -> void:
		last_damage = amount

	func get_collision_radius() -> float:
		return 12.0


func test_weapon_roster_loads_eight_kitchen_weapons() -> void:
	var roster := WeaponRoster.load_roster()
	assert_int(roster.size()).is_equal(8)


func test_each_weapon_has_required_fields() -> void:
	for weapon in WeaponRoster.load_roster():
		assert_str(weapon.id).is_not_empty()
		assert_str(weapon.display_name).is_not_empty()
		assert_str(weapon.description).is_not_empty()
		assert_object(weapon.icon).is_not_null()
		assert_object(weapon.weapon_script).is_not_null()


func test_weapon_ids_are_unique() -> void:
	var seen: Dictionary = {}
	for weapon in WeaponRoster.load_roster():
		assert_bool(seen.has(weapon.id)).is_false()
		seen[weapon.id] = true


func test_get_by_id_returns_matching_weapon() -> void:
	assert_object(WeaponRoster.get_by_id("kitchen_knife")).is_same(KNIFE_DEF)
	assert_object(WeaponRoster.get_by_id("missing_weapon")).is_null()


func test_projectile_weapons_reference_projectile_scene() -> void:
	for weapon in [PEPPER_DEF, SOUP_DEF, GARLIC_DEF, LADLE_DEF, TOASTER_DEF]:
		assert_object(weapon.projectile_scene).is_not_null()


func test_melee_weapons_use_melee_script_without_projectiles() -> void:
	for weapon in [KNIFE_DEF, PAN_DEF]:
		assert_object(weapon.weapon_script).is_same(MELEE_SCRIPT)
		assert_int(weapon.weapon_type).is_equal(WeaponDefinition.WeaponType.MELEE)
		assert_object(weapon.projectile_scene).is_null()


func test_special_weapons_use_expected_scripts() -> void:
	assert_object(GARLIC_DEF.weapon_script).is_same(BURST_SCRIPT)
	assert_object(LADLE_DEF.weapon_script).is_same(BOOMERANG_SCRIPT)
	assert_object(TOASTER_DEF.weapon_script).is_same(TURRET_SCRIPT)
	assert_object(ONION_RING_DEF.weapon_script).is_same(ORBIT_SCRIPT)


func test_orbit_blade_hit_emits_damage_dealt_once() -> void:
	var weapon: Node2D = Node2D.new()
	weapon.set_script(ORBIT_SCRIPT)
	add_child(weapon)
	weapon.setup(ONION_RING_DEF, Rect2(), null)

	var enemy := MockOrbitEnemy.new()
	enemy.add_to_group("enemies")
	add_child(enemy)
	enemy.global_position = Vector2(58.0, 0.0)

	var emission_info := {"count": 0, "amount": 0, "is_crit": true}
	EventBus.damage_dealt.connect(
		func(_pos: Vector2, amount: int, is_crit: bool) -> void:
			emission_info.count += 1
			emission_info.amount = amount
			emission_info.is_crit = is_crit
	)

	weapon._check_blade_hits(Vector2(58.0, 0.0), ONION_RING_DEF.damage)

	assert_int(emission_info.count).is_equal(1)
	assert_int(emission_info.amount).is_equal(ONION_RING_DEF.damage)
	assert_bool(emission_info.is_crit).is_false()
	assert_int(enemy.last_damage).is_equal(ONION_RING_DEF.damage)
