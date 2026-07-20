# GdUnit generated TestSuite
extends GdUnitTestSuite

const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")
const PAN_DEF := preload("res://resources/weapons/frying_pan.tres")
const TOMATO_DEF := preload("res://resources/weapons/rotten_tomato.tres")
const MELEE_SCRIPT := preload("res://scripts/weapons/melee_weapon.gd")
const PROJECTILE_SCRIPT := preload("res://scripts/weapons/projectile_weapon.gd")


func test_weapon_roster_loads_three_kitchen_weapons() -> void:
	var roster := WeaponRoster.load_roster()
	assert_int(roster.size()).is_equal(3)


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


func test_melee_weapons_use_melee_script_without_projectiles() -> void:
	for weapon in [KNIFE_DEF, PAN_DEF]:
		assert_object(weapon.weapon_script).is_same(MELEE_SCRIPT)
		assert_int(weapon.weapon_type).is_equal(WeaponDefinition.WeaponType.MELEE)
		assert_object(weapon.projectile_scene).is_null()


func test_rotten_tomato_is_a_ranged_projectile_weapon() -> void:
	assert_object(TOMATO_DEF.weapon_script).is_same(PROJECTILE_SCRIPT)
	assert_int(TOMATO_DEF.weapon_type).is_equal(WeaponDefinition.WeaponType.PROJECTILE)
	assert_object(TOMATO_DEF.projectile_scene).is_not_null()


func test_weapons_author_design_unit_stats() -> void:
	# Design-unit stats from plans.md R3.
	assert_int(KNIFE_DEF.damage).is_equal(25)
	assert_float(KNIFE_DEF.fire_rate).is_equal(0.8)
	assert_float(KNIFE_DEF.area).is_equal(20.0)
	assert_float(KNIFE_DEF.attack_range).is_equal(10.0)

	assert_int(PAN_DEF.damage).is_equal(60)
	assert_float(PAN_DEF.fire_rate).is_equal(1.9)

	assert_int(TOMATO_DEF.damage).is_equal(40)
	assert_float(TOMATO_DEF.fire_rate).is_equal(1.2)
	assert_float(TOMATO_DEF.attack_range).is_equal(80.0)
