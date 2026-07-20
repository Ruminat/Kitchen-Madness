# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_base_move_speed_converts_to_engine_pixels() -> void:
	# The whole point of the factor: 30 design speed == the historical 220 px/s.
	assert_float(StatUnits.speed_to_pixels(StatUnits.BASE_MOVE_SPEED_UNITS)).is_equal_approx(
		StatUnits.BASE_MOVE_SPEED_PIXELS, 0.001
	)


func test_area_and_speed_share_one_factor() -> void:
	# 1 move speed == 1 area/second, so both conversions use the same factor.
	assert_float(StatUnits.area_to_pixels(10.0)).is_equal_approx(
		StatUnits.speed_to_pixels(10.0), 0.001
	)
	assert_float(StatUnits.area_to_pixels(1.0)).is_equal_approx(
		StatUnits.PIXELS_PER_AREA_UNIT, 0.001
	)


func test_area_conversion_is_linear() -> void:
	assert_float(StatUnits.area_to_pixels(80.0)).is_equal_approx(
		StatUnits.area_to_pixels(40.0) * 2.0, 0.001
	)


func test_armor_multiplier_reduces_damage() -> void:
	assert_float(StatUnits.armor_damage_multiplier(0)).is_equal_approx(1.0, 0.0001)
	assert_float(StatUnits.armor_damage_multiplier(2)).is_less(1.0)
	# More armor reduces more.
	assert_float(StatUnits.armor_damage_multiplier(4)).is_less(StatUnits.armor_damage_multiplier(2))


func test_negative_armor_increases_damage() -> void:
	assert_float(StatUnits.armor_damage_multiplier(-2)).is_greater(1.0)


func test_armor_multiplier_is_clamped_both_ends() -> void:
	assert_float(StatUnits.armor_damage_multiplier(1000)).is_equal_approx(
		StatUnits.MIN_DAMAGE_MULTIPLIER, 0.0001
	)
	assert_float(StatUnits.armor_damage_multiplier(-1000)).is_equal_approx(
		StatUnits.MAX_DAMAGE_MULTIPLIER, 0.0001
	)


func test_apply_armor_keeps_minimum_of_one() -> void:
	assert_int(StatUnits.apply_armor(1, 1000)).is_equal(1)
	assert_int(StatUnits.apply_armor(0, 0)).is_equal(0)
	assert_int(StatUnits.apply_armor(100, 2)).is_less(100)
