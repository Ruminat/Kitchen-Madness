# GdUnit generated TestSuite
extends GdUnitTestSuite

const ANT_DEF := preload("res://resources/enemies/ant.tres")
const MOTH_DEF := preload("res://resources/enemies/moth.tres")
const CHASER_DEF := preload("res://resources/enemies/chaser.tres")
const SPRINTER_DEF := preload("res://resources/enemies/sprinter.tres")


func test_ant_is_small_and_fragile() -> void:
	assert_str(ANT_DEF.id).is_equal("ant")
	assert_int(ANT_DEF.max_health).is_less(CHASER_DEF.max_health)
	assert_float(ANT_DEF.radius).is_less(CHASER_DEF.radius)


func test_moth_is_erratic_pest() -> void:
	assert_str(MOTH_DEF.id).is_equal("moth")
	assert_int(MOTH_DEF.max_health).is_less(CHASER_DEF.max_health)
	assert_float(MOTH_DEF.move_speed).is_less(SPRINTER_DEF.move_speed)


func test_moth_scene_uses_erratic_script() -> void:
	var scene := MOTH_DEF.scene.instantiate()
	assert_str(scene.get_script().resource_path).contains("moth_enemy.gd")
	scene.free()
