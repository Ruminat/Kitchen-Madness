# GdUnit generated TestSuite
extends GdUnitTestSuite

const Splitter := preload("res://tools/grid_sprite_splitter.gd")


func test_split_image_centers_subjects_from_each_cell() -> void:
	var grid := _create_grid_image(Vector2i(99, 105), Color.BLACK)
	var colors: Array[Color] = [
		Color.RED,
		Color.GREEN,
		Color.BLUE,
		Color.YELLOW,
		Color.CYAN,
		Color.MAGENTA,
		Color.ORANGE,
		Color.PURPLE,
		Color.WHITE,
	]
	for index in colors.size():
		var row := floori(float(index) / 3.0)
		var cell: Rect2i = Splitter.get_cell_rect(Vector2i(99, 105), 3, 3, index % 3, row)
		var local_offset := Vector2i(3 + (index % 3) * 4, 4 + row * 3)
		_paint_rect(grid, Rect2i(cell.position + local_offset, Vector2i(12, 16)), colors[index])

	var sprites: Array[Image] = Splitter.split_image(
		grid,
		3,
		3,
		{
			"output_size": Vector2i(64, 64),
			"padding": 8,
			"background_color": Color.BLACK,
			"background_tolerance": 0.03,
		}
	)

	assert_int(sprites.size()).is_equal(9)
	for sprite in sprites:
		var rect := _alpha_rect(sprite)
		assert_int(abs(_rect_center_x(rect) - 32)).is_less_equal(1)
		assert_int(abs(_rect_center_y(rect) - 32)).is_less_equal(1)


func test_split_image_removes_only_edge_connected_background() -> void:
	var grid := _create_grid_image(Vector2i(30, 30), Color.BLACK)
	_paint_rect(grid, Rect2i(7, 7, 16, 16), Color(0.9, 0.3, 0.1))
	_paint_rect(grid, Rect2i(13, 13, 4, 4), Color.BLACK)

	var sprites: Array[Image] = Splitter.split_image(
		grid,
		1,
		1,
		{
			"output_size": Vector2i(30, 30),
			"padding": 0,
			"background_color": Color.BLACK,
			"background_tolerance": 0.03,
			"allow_upscale": false,
		}
	)
	var sprite: Image = sprites[0]

	assert_float(sprite.get_pixel(0, 0).a).is_equal(0.0)
	assert_float(sprite.get_pixel(15, 15).a).is_equal(1.0)
	assert_that(sprite.get_pixel(15, 15)).is_equal(Color.BLACK)


func test_get_cell_rect_covers_uneven_image_without_gaps() -> void:
	var image_size := Vector2i(101, 89)
	var covered_area := 0

	for row in 3:
		for column in 4:
			var rect: Rect2i = Splitter.get_cell_rect(image_size, 4, 3, column, row)
			assert_int(rect.size.x).is_greater(0)
			assert_int(rect.size.y).is_greater(0)
			covered_area += rect.size.x * rect.size.y

	assert_int(covered_area).is_equal(image_size.x * image_size.y)


func _create_grid_image(size: Vector2i, color: Color) -> Image:
	var image := Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(color)
	return image


func _paint_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			image.set_pixel(x, y, color)


func _alpha_rect(image: Image) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x, y).a <= 0.01:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func _rect_center_x(rect: Rect2i) -> int:
	return rect.position.x + floori(float(rect.size.x) / 2.0)


func _rect_center_y(rect: Rect2i) -> int:
	return rect.position.y + floori(float(rect.size.y) / 2.0)
