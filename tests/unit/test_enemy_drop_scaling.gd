# GdUnit generated TestSuite
extends GdUnitTestSuite

const CHASER_DEF := preload("res://resources/enemies/chaser.tres")
const TANK_DEF := preload("res://resources/enemies/tank.tres")
const ANT_DEF := preload("res://resources/enemies/ant.tres")


func test_chaser_has_baseline_drop_multiplier() -> void:
	assert_float(CHASER_DEF.get_drop_chance_multiplier()).is_equal_approx(1.0, 0.01)


func test_ant_has_lower_drop_multiplier_than_chaser() -> void:
	assert_float(ANT_DEF.get_drop_chance_multiplier()).is_less(
		CHASER_DEF.get_drop_chance_multiplier()
	)


func test_tank_has_higher_drop_multiplier_than_chaser() -> void:
	assert_float(TANK_DEF.get_drop_chance_multiplier()).is_greater(
		CHASER_DEF.get_drop_chance_multiplier()
	)
