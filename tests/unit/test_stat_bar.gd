# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_setup_bar_configures_progress_bar() -> void:
	var bar: ProgressBar = _create_stat_bar()
	await _wait_ready(bar)
	bar.setup_bar(Color(0.1, 0.1, 0.1), Color(0.8, 0.2, 0.2), 10.0)

	assert_float(bar.custom_minimum_size.y).is_equal(10.0)
	assert_bool(bar.show_percentage).is_false()


func test_set_value_smooth_sets_max_value() -> void:
	var bar: ProgressBar = _create_stat_bar()
	await _wait_ready(bar)
	bar.setup_bar(Color.BLACK, Color.RED)
	bar.set_value_smooth(35.0, 100.0)

	assert_float(bar.max_value).is_equal(100.0)


func test_set_fill_color_updates_style() -> void:
	var bar: ProgressBar = _create_stat_bar()
	await _wait_ready(bar)
	bar.setup_bar(Color.BLACK, Color.RED)
	bar.set_fill_color(Color.GREEN)

	var fill_style: StyleBoxFlat = bar.get_theme_stylebox("fill") as StyleBoxFlat
	assert_object(fill_style).is_not_null()
	assert_that(fill_style.bg_color).is_equal(Color.GREEN)


func _create_stat_bar() -> ProgressBar:
	var bar: ProgressBar = auto_free(ProgressBar.new()) as ProgressBar
	bar.set_script(load("res://scripts/ui/stat_bar.gd"))
	add_child(bar)
	return bar


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
