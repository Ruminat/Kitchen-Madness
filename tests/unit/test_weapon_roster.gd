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


func test_weapon_roster_loads_eight_kitchen_weapons() -> void:
	var roster := WeaponRoster.load_roster()
	assert_int(roster.size()).is_equal(8)


func test_each_weapon_has_required_fields() -> void:
	for weapon in WeaponRoster.load_roster():
		assert_str(weapon.id).is_not_empty()
		assert_str(weapon.display_name).is_not_empty()
		assert_str(weapon.description).is_not_empty()
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
	for weapon in [PEPPER_DEF, SOUP_DEF, KNIFE_DEF, PAN_DEF]:
		assert_object(weapon.projectile_scene).is_not_null()


func test_special_weapons_use_expected_scripts() -> void:
	assert_object(GARLIC_DEF.weapon_script).is_same(BURST_SCRIPT)
	assert_object(LADLE_DEF.weapon_script).is_same(BOOMERANG_SCRIPT)
	assert_object(TOASTER_DEF.weapon_script).is_same(TURRET_SCRIPT)
	assert_object(ONION_RING_DEF.weapon_script).is_same(ORBIT_SCRIPT)
