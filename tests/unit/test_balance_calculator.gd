# GdUnit generated TestSuite
extends GdUnitTestSuite

const PEPPER_DEF := preload("res://resources/weapons/pepper_grinder_gun.tres")
const SOUP_DEF := preload("res://resources/weapons/boiling_soup_splash.tres")
const ONION_RING_DEF := preload("res://resources/weapons/onion_ring_blade.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")
const WAVE_01_DEF := preload("res://resources/waves/wave_01.tres")
const WAVE_02_DEF := preload("res://resources/waves/wave_02.tres")
const CHASER_DEF := preload("res://resources/enemies/chaser.tres")


func test_calculate_weapon_dps_returns_positive_value() -> void:
	var dps := BalanceCalculator.calculate_weapon_dps(PEPPER_DEF)
	assert_float(dps).is_greater(0.0)


func test_calculate_weapon_dps_formula_is_correct() -> void:
	var weapon := WeaponDefinition.new()
	weapon.damage = 10
	weapon.fire_rate = 0.5
	weapon.pellet_count = 1

	var expected_dps := 10.0 / 0.5
	var actual_dps := BalanceCalculator.calculate_weapon_dps(weapon, 1.0)
	assert_float(actual_dps).is_equal_approx(expected_dps, 0.01)


func test_calculate_weapon_dps_with_pellets_multiplies_damage() -> void:
	var weapon := WeaponDefinition.new()
	weapon.damage = 10
	weapon.fire_rate = 1.0
	weapon.pellet_count = 3

	var expected_dps := 30.0
	var actual_dps := BalanceCalculator.calculate_weapon_dps(weapon, 1.0)
	assert_float(actual_dps).is_equal_approx(expected_dps, 0.01)


func test_calculate_weapon_dps_with_hit_rate_reduces_output() -> void:
	var weapon := WeaponDefinition.new()
	weapon.damage = 10
	weapon.fire_rate = 1.0
	weapon.pellet_count = 1

	var full_dps := BalanceCalculator.calculate_weapon_dps(weapon, 1.0)
	var half_dps := BalanceCalculator.calculate_weapon_dps(weapon, 0.5)
	assert_float(half_dps).is_equal_approx(full_dps * 0.5, 0.01)


func test_calculate_orbit_dps_returns_positive_value() -> void:
	var dps := BalanceCalculator.calculate_orbit_dps(ONION_RING_DEF)
	assert_float(dps).is_greater(0.0)


func test_null_weapon_returns_zero_dps() -> void:
	assert_float(BalanceCalculator.calculate_weapon_dps(null)).is_equal(0.0)
	assert_float(BalanceCalculator.calculate_orbit_dps(null)).is_equal(0.0)
	assert_float(BalanceCalculator.calculate_effective_dps(null)).is_equal(0.0)


func test_estimate_wave_kills_returns_positive() -> void:
	var kills := BalanceCalculator.estimate_wave_kills(WAVE_01_DEF)
	assert_int(kills).is_greater(0)


func test_estimate_wave_kills_formula() -> void:
	var wave := WaveDefinition.new()
	wave.duration = 10.0
	wave.spawn_interval = 1.0
	wave.spawn_multiplier_start = 1.0
	wave.spawn_multiplier_end = 1.0

	var expected_kills := 10
	var actual_kills := BalanceCalculator.estimate_wave_kills(wave)
	assert_int(actual_kills).is_equal(expected_kills)


func test_estimate_wave_gold_returns_positive() -> void:
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var gold := BalanceCalculator.estimate_wave_gold(WAVE_01_DEF, enemies)
	assert_int(gold).is_greater(0)


func test_estimate_wave_xp_returns_positive() -> void:
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var xp := BalanceCalculator.estimate_wave_xp(WAVE_01_DEF, enemies)
	assert_int(xp).is_greater(0)


func test_calculate_wave_hp_budget_returns_positive() -> void:
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var budget := BalanceCalculator.calculate_wave_hp_budget(WAVE_01_DEF, enemies)
	assert_int(budget).is_greater(0)


func test_compare_weapon_dps_returns_dictionary() -> void:
	var weapons: Array[WeaponDefinition] = [PEPPER_DEF, KNIFE_DEF]
	var comparison := BalanceCalculator.compare_weapon_dps(weapons)
	assert_dict(comparison).is_not_empty()
	assert_dict(comparison).contains_key("pepper_grinder_gun")
	assert_dict(comparison).contains_key("kitchen_knife")


func test_compare_wave_budgets_returns_dictionary() -> void:
	var waves: Array[WaveDefinition] = [WAVE_01_DEF, WAVE_02_DEF]
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var comparison := BalanceCalculator.compare_wave_budgets(waves, enemies)
	assert_dict(comparison).is_not_empty()


func test_wave_1_duration_matches_target() -> void:
	assert_float(WAVE_01_DEF.duration).is_equal(12.0)


func test_wave_2_duration_matches_target() -> void:
	assert_float(WAVE_02_DEF.duration).is_equal(17.0)


func test_kitchen_weapons_have_reasonable_dps() -> void:
	var weapons: Array[WeaponDefinition] = [PEPPER_DEF, SOUP_DEF, ONION_RING_DEF, KNIFE_DEF]
	for weapon in weapons:
		var dps := BalanceCalculator.calculate_effective_dps(weapon)
		assert_float(dps).is_greater(10.0)
		assert_float(dps).is_less(200.0)
