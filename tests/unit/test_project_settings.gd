# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_application_name_is_kitchen_madness() -> void:
	assert_str(ProjectSettings.get_setting("application/config/name")).is_equal("Kitchen Madness")


func test_main_scene_points_at_game() -> void:
	assert_str(ProjectSettings.get_setting("application/run/main_scene")).is_equal(
		"res://scenes/main/game.tscn"
	)
