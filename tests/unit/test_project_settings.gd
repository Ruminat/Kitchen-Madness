# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_application_name_is_kitchen_madness() -> void:
	assert_str(ProjectSettings.get_setting("application/config/name")).is_equal("Kitchen Madness")


func test_main_scene_points_at_game() -> void:
	assert_str(ProjectSettings.get_setting("application/run/main_scene")).is_equal(
		"res://scenes/main/game.tscn"
	)


func test_performance_settings_autoload_is_registered() -> void:
	assert_str(ProjectSettings.get_setting("autoload/PerformanceSettings")).is_equal(
		"*res://scripts/autoload/performance_settings.gd"
	)


func test_viewport_stretch_supports_render_scale() -> void:
	assert_str(ProjectSettings.get_setting("display/window/stretch/mode")).is_equal("viewport")


func test_resolution_options_are_presented_as_render_resolutions() -> void:
	var options := PerformanceSettings.get_resolution_options()

	assert_int(options.size()).is_equal(4)
	assert_str(options[0].get("label", "")).is_equal("1920 x 1080")
	var size: Vector2i = options[0].get("size", Vector2i.ZERO)
	assert_int(size.x).is_equal(1920)
	assert_int(size.y).is_equal(1080)


func test_resolution_index_changes_internal_render_scale_only() -> void:
	var previous_index := PerformanceSettings.resolution_index

	PerformanceSettings.set_resolution_index(2, false)

	assert_str(PerformanceSettings.get_resolution_label()).is_equal("1280 x 720")
	assert_float(PerformanceSettings.get_render_scale_factor()).is_equal_approx(1.5, 0.001)

	PerformanceSettings.set_resolution_index(previous_index, false)
