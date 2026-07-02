# GdUnit generated TestSuite
extends GdUnitTestSuite

const PEPPER_DEF := preload("res://resources/weapons/pepper_grinder_gun.tres")
const SOUP_DEF := preload("res://resources/weapons/boiling_soup_splash.tres")
const ONION_RING_DEF := preload("res://resources/weapons/onion_ring_blade.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")
const LEVEL_01_DEF := preload("res://resources/levels/level_01.tres")
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


func test_estimate_level_kills_returns_positive() -> void:
	var kills := BalanceCalculator.estimate_level_kills(LEVEL_01_DEF)
	assert_int(kills).is_greater(0)


func test_estimate_level_kills_formula() -> void:
	var level := LevelDefinition.new()
	level.duration = 10.0
	level.spawn_interval = 1.0
	level.spawn_multiplier_start = 1.0
	level.spawn_multiplier_end = 1.0
	level.swarm_size_min = 1
	level.swarm_size_max = 1

	var expected_kills := 10
	var actual_kills := BalanceCalculator.estimate_level_kills(level)
	assert_int(actual_kills).is_equal(expected_kills)


func test_estimate_level_gold_returns_positive() -> void:
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var gold := BalanceCalculator.estimate_level_gold(LEVEL_01_DEF, enemies)
	assert_int(gold).is_greater(0)


func test_estimate_level_xp_returns_positive() -> void:
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var xp := BalanceCalculator.estimate_level_xp(LEVEL_01_DEF, enemies)
	assert_int(xp).is_greater(0)


func test_calculate_level_hp_budget_returns_positive() -> void:
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var budget := BalanceCalculator.calculate_level_hp_budget(LEVEL_01_DEF, enemies)
	assert_int(budget).is_greater(0)


func test_compare_weapon_dps_returns_dictionary() -> void:
	var weapons: Array[WeaponDefinition] = [PEPPER_DEF, KNIFE_DEF]
	var comparison := BalanceCalculator.compare_weapon_dps(weapons)
	assert_dict(comparison).is_not_empty()
	assert_dict(comparison).contains_keys(["pepper_grinder_gun"])
	assert_dict(comparison).contains_keys(["kitchen_knife"])


func test_compare_level_budgets_returns_dictionary() -> void:
	var levels: Array[LevelDefinition] = [LEVEL_01_DEF]
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var comparison := BalanceCalculator.compare_level_budgets(levels, enemies)
	assert_dict(comparison).is_not_empty()
	var level_one := comparison["level_01.tres"] as Dictionary
	assert_float(level_one.get("duration", 0.0)).is_equal(600.0)
	assert_int(level_one.get("estimated_kills", 0)).is_greater(0)


func test_enemy_hp_scaling_grows_hp_budget_over_flat_health() -> void:
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var flat_total := CHASER_DEF.max_health * BalanceCalculator.estimate_level_kills(LEVEL_01_DEF)
	var budget := BalanceCalculator.calculate_level_hp_budget(LEVEL_01_DEF, enemies)
	assert_int(budget).is_greater(flat_total)


func test_level_affordability_costs_scale_with_elapsed_time() -> void:
	var enemies: Array[EnemyDefinition] = [CHASER_DEF]
	var early := BalanceCalculator.estimate_level_affordability(LEVEL_01_DEF, enemies, 0.0)
	var late := BalanceCalculator.estimate_level_affordability(LEVEL_01_DEF, enemies, 540.0)
	assert_int(early.get("cheap_item_cost", 0)).is_equal(8)
	assert_int(early.get("weapon_item_cost", 0)).is_equal(12)
	assert_int(late.get("cheap_item_cost", 0)).is_greater(early.get("cheap_item_cost", 0))
	assert_int(late.get("weapon_item_cost", 0)).is_greater(early.get("weapon_item_cost", 0))


func test_level_1_duration_matches_target() -> void:
	assert_float(LEVEL_01_DEF.duration).is_equal(600.0)


func test_kitchen_weapons_have_reasonable_dps() -> void:
	var weapons: Array[WeaponDefinition] = [PEPPER_DEF, SOUP_DEF, ONION_RING_DEF, KNIFE_DEF]
	for weapon in weapons:
		var w_path := weapon.weapon_script.get_path() if weapon.weapon_script else ""
		var is_orbit := w_path.contains("orbit")
		var is_burst := w_path.contains("burst")
		var dps := BalanceCalculator.calculate_effective_dps(weapon, is_orbit, is_burst)
		assert_float(dps).is_greater(10.0)
		assert_float(dps).is_less(200.0)
