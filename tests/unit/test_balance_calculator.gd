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
	assert_dict(comparison).contains_keys(["pepper_grinder_gun"])
	assert_dict(comparison).contains_keys(["kitchen_knife"])


func test_compare_wave_budgets_returns_dictionary() -> void:
	var waves: Array[WaveDefinition] = [WAVE_01_DEF, WAVE_02_DEF]
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var comparison := BalanceCalculator.compare_wave_budgets(waves, enemies)
	assert_dict(comparison).is_not_empty()
	var wave_two := comparison["wave_02.tres"] as Dictionary
	assert_int(wave_two.get("wave_number", 0)).is_equal(2)
	assert_int(wave_two.get("estimated_kills", 0)).is_greater(
		BalanceCalculator.estimate_wave_kills(WAVE_01_DEF, 1)
	)


func test_wave_one_kill_estimate_stays_in_target_band() -> void:
	var kills := BalanceCalculator.estimate_wave_kills(WAVE_01_DEF, 1)
	assert_int(kills).is_greater_equal(8)
	assert_int(kills).is_less_equal(20)


func test_wave_hp_budget_grows_faster_than_flat_enemy_health() -> void:
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var wave_one_budget := BalanceCalculator.calculate_wave_hp_budget(WAVE_01_DEF, enemies, 1)
	var wave_three_budget := BalanceCalculator.calculate_wave_hp_budget(
		preload("res://resources/waves/wave_03.tres"), enemies, 3
	)
	assert_int(wave_three_budget).is_greater(wave_one_budget * 2)


func test_wave_one_affordability_targets_one_to_two_purchases() -> void:
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var affordability := BalanceCalculator.estimate_wave_affordability(WAVE_01_DEF, enemies, 1)
	assert_float(affordability.get("cheap_purchases", 0.0)).is_greater_equal(0.6)
	assert_float(affordability.get("cheap_purchases", 0.0)).is_less_equal(1.6)
	assert_float(affordability.get("weapon_purchases", 0.0)).is_less_equal(1.2)


func test_wave_1_duration_matches_target() -> void:
	assert_float(WAVE_01_DEF.duration).is_equal(12.0)


func test_wave_2_duration_matches_target() -> void:
	assert_float(WAVE_02_DEF.duration).is_equal(17.0)


func test_kitchen_weapons_have_reasonable_dps() -> void:
	var weapons: Array[WeaponDefinition] = [PEPPER_DEF, SOUP_DEF, ONION_RING_DEF, KNIFE_DEF]
	for weapon in weapons:
		var w_path := weapon.weapon_script.get_path() if weapon.weapon_script else ""
		var is_orbit := w_path.contains("orbit")
		var is_burst := w_path.contains("burst")
		var dps := BalanceCalculator.calculate_effective_dps(weapon, is_orbit, is_burst)
		assert_float(dps).is_greater(10.0)
		assert_float(dps).is_less(200.0)
