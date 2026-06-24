# GdUnit generated TestSuite
extends GdUnitTestSuite

const DropRates = preload("res://scripts/data/drop_rates.gd")


func test_xp_drop_chance_is_forty_percent() -> void:
	assert_float(DropRates.XP_DROP_CHANCE).is_equal_approx(0.40, 0.001)


func test_grease_drop_chance_is_fifty_percent() -> void:
	assert_float(DropRates.GREASE_DROP_CHANCE).is_equal_approx(0.50, 0.001)


func test_health_drop_chance_is_ten_times_rarer_than_before() -> void:
	assert_float(DropRates.HEALTH_DROP_CHANCE).is_equal_approx(0.005, 0.0001)


func test_max_health_drop_chance_scales_with_base_rate() -> void:
	assert_float(DropRates.MAX_HEALTH_DROP_CHANCE).is_equal_approx(0.022, 0.0001)


func test_scaled_drop_chance_boosts_tough_enemies() -> void:
	var tank := EnemyDefinition.new()
	tank.max_health = 50
	tank.is_elite = true

	var ant := EnemyDefinition.new()
	ant.max_health = 8

	assert_float(DropRates.scaled_drop_chance(0.5, tank)).is_greater(
		DropRates.scaled_drop_chance(0.5, ant)
	)


func test_roll_enemy_drop_respects_zero_chance() -> void:
	assert_bool(DropRates.roll_enemy_drop(0.0, null)).is_false()
