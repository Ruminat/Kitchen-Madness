class_name GridSpriteSplitter
extends RefCounted

const DEFAULT_BACKGROUND_TOLERANCE := 0.08
const DEFAULT_ALPHA_THRESHOLD := 0.04
const DEFAULT_PADDING := 8


static func split_image(
	source: Image, columns: int, rows: int, options: Dictionary = {}
) -> Array[Image]:
	_validate_grid(source, columns, rows)

	var source_rgba := source.duplicate()
	if source_rgba.get_format() != Image.FORMAT_RGBA8:
		source_rgba.convert(Image.FORMAT_RGBA8)

	var sprites: Array[Image] = []
	for row in rows:
		for column in columns:
			var cell_rect := get_cell_rect(source_rgba.get_size(), columns, rows, column, row)
			var cell := _copy_region(source_rgba, cell_rect)
			sprites.append(process_cell(cell, options))
	return sprites


static func split_file(
	input_path: String,
	output_dir: String,
	columns: int,
	rows: int,
	name_pattern: String = "{stem}_{index}.png",
	options: Dictionary = {}
) -> Array[String]:
	var image := _load_image(input_path)
	if image == null:
		push_error("Could not load image '%s'." % input_path)
		return []

	var absolute_output_dir := ProjectSettings.globalize_path(output_dir)
	var dir_error := DirAccess.make_dir_recursive_absolute(absolute_output_dir)
	if dir_error != OK:
		push_error("Could not create output directory '%s' (error %d)." % [output_dir, dir_error])
		return []

	var sprites := split_image(image, columns, rows, options)
	var saved_paths: Array[String] = []
	var stem := input_path.get_file().get_basename()
	var names: PackedStringArray = options.get("names", PackedStringArray())
	for index in sprites.size():
		var row := floori(float(index) / float(columns))
		var column := index % columns
		var sprite_name := names[index] if index < names.size() else ""
		var file_name := _format_name(name_pattern, stem, sprite_name, index, row, column)
		if file_name.get_extension().is_empty():
			file_name += ".png"
		var save_path := absolute_output_dir.path_join(file_name)
		var save_error := sprites[index].save_png(save_path)
		if save_error != OK:
			push_error("Could not save sprite '%s' (error %d)." % [save_path, save_error])
			continue
		saved_paths.append(save_path)
	return saved_paths


static func process_cell(cell: Image, options: Dictionary = {}) -> Image:
	var cell_rgba := cell.duplicate()
	if cell_rgba.get_format() != Image.FORMAT_RGBA8:
		cell_rgba.convert(Image.FORMAT_RGBA8)

	var output_size: Vector2i = options.get("output_size", cell_rgba.get_size())
	if output_size.x <= 0 or output_size.y <= 0:
		output_size = cell_rgba.get_size()

	var padding: int = maxi(options.get("padding", DEFAULT_PADDING), 0)
	var alpha_threshold: float = options.get("alpha_threshold", DEFAULT_ALPHA_THRESHOLD)
	var background_tolerance: float = options.get(
		"background_tolerance", DEFAULT_BACKGROUND_TOLERANCE
	)
	var background_colors: Array[Color] = _resolve_background_colors(cell_rgba, options)
	var make_transparent: bool = options.get("make_background_transparent", true)
	var allow_upscale: bool = options.get("allow_upscale", true)

	var background_mask := _build_edge_background_mask(
		cell_rgba, background_colors, background_tolerance, alpha_threshold
	)
	var content_rect := detect_content_rect(cell_rgba, background_mask, alpha_threshold)
	var output := Image.create(output_size.x, output_size.y, false, Image.FORMAT_RGBA8)
	output.fill(options.get("output_background_color", Color(0.0, 0.0, 0.0, 0.0)))
	if content_rect.size.x <= 0 or content_rect.size.y <= 0:
		return output

	var cleaned := _apply_background_mask(cell_rgba, background_mask, make_transparent)
	var subject := _copy_region(cleaned, content_rect)
	var max_subject_size := Vector2i(
		maxi(output_size.x - padding * 2, 1), maxi(output_size.y - padding * 2, 1)
	)
	var scaled_size := _fit_size(subject.get_size(), max_subject_size, allow_upscale)
	if scaled_size != subject.get_size():
		subject.resize(scaled_size.x, scaled_size.y, Image.INTERPOLATE_LANCZOS)

	var destination := Vector2i(
		floori(float(output_size.x - subject.get_width()) / 2.0),
		floori(float(output_size.y - subject.get_height()) / 2.0)
	)
	output.blit_rect(subject, Rect2i(Vector2i.ZERO, subject.get_size()), destination)
	return output


static func detect_content_rect(
	image: Image, background_mask: PackedByteArray, alpha_threshold: float
) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1

	for y in image.get_height():
		for x in image.get_width():
			var index := y * image.get_width() + x
			if background_mask[index] == 1:
				continue
			if image.get_pixel(x, y).a <= alpha_threshold:
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)

	if max_x < min_x or max_y < min_y:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


static func get_cell_rect(
	image_size: Vector2i, columns: int, rows: int, column: int, row: int
) -> Rect2i:
	var x0 := roundi(float(column) * float(image_size.x) / float(columns))
	var x1 := roundi(float(column + 1) * float(image_size.x) / float(columns))
	var y0 := roundi(float(row) * float(image_size.y) / float(rows))
	var y1 := roundi(float(row + 1) * float(image_size.y) / float(rows))
	return Rect2i(x0, y0, x1 - x0, y1 - y0)


static func _validate_grid(source: Image, columns: int, rows: int) -> void:
	assert(source != null)
	assert(source.get_width() > 0)
	assert(source.get_height() > 0)
	assert(columns > 0)
	assert(rows > 0)


static func _load_image(input_path: String) -> Image:
	var bytes := FileAccess.get_file_as_bytes(input_path)
	if bytes.is_empty():
		var empty_file_fallback := Image.new()
		var empty_file_error := empty_file_fallback.load(input_path)
		if empty_file_error == OK:
			return empty_file_fallback
		return null

	var image := _load_image_from_known_header(bytes)
	if image:
		return image

	var fallback := Image.new()
	var fallback_error := fallback.load(input_path)
	if fallback_error == OK:
		return fallback
	return null


static func _load_image_from_known_header(bytes: PackedByteArray) -> Image:
	var image := Image.new()
	var error := ERR_FILE_UNRECOGNIZED
	if _has_png_header(bytes):
		error = image.load_png_from_buffer(bytes)
	elif _has_jpeg_header(bytes):
		error = image.load_jpg_from_buffer(bytes)
	elif _has_webp_header(bytes):
		error = image.load_webp_from_buffer(bytes)
	elif _has_bmp_header(bytes):
		error = image.load_bmp_from_buffer(bytes)

	if error == OK:
		return image
	return null


static func _has_png_header(bytes: PackedByteArray) -> bool:
	return (
		bytes.size() >= 8
		and bytes[0] == 0x89
		and bytes[1] == 0x50
		and bytes[2] == 0x4e
		and bytes[3] == 0x47
	)


static func _has_jpeg_header(bytes: PackedByteArray) -> bool:
	return bytes.size() >= 3 and bytes[0] == 0xff and bytes[1] == 0xd8 and bytes[2] == 0xff


static func _has_webp_header(bytes: PackedByteArray) -> bool:
	return (
		bytes.size() >= 12
		and bytes[0] == 0x52
		and bytes[1] == 0x49
		and bytes[2] == 0x46
		and bytes[3] == 0x46
		and bytes[8] == 0x57
		and bytes[9] == 0x45
		and bytes[10] == 0x42
		and bytes[11] == 0x50
	)


static func _has_bmp_header(bytes: PackedByteArray) -> bool:
	return bytes.size() >= 2 and bytes[0] == 0x42 and bytes[1] == 0x4d


static func _copy_region(source: Image, rect: Rect2i) -> Image:
	var region := Image.create(rect.size.x, rect.size.y, false, Image.FORMAT_RGBA8)
	region.blit_rect(source, rect, Vector2i.ZERO)
	return region


static func _resolve_background_colors(cell: Image, options: Dictionary) -> Array[Color]:
	if options.has("background_colors"):
		return options["background_colors"]
	if options.has("background_color"):
		return [options["background_color"]]
	return _sample_background_colors(cell)


static func _sample_background_colors(image: Image) -> Array[Color]:
	var colors: Array[Color] = []
	const MERGE_TOLERANCE := 0.04
	var last_x := image.get_width() - 1
	var last_y := image.get_height() - 1

	for x in image.get_width():
		_add_unique_background_color(colors, image.get_pixel(x, 0), MERGE_TOLERANCE)
		_add_unique_background_color(colors, image.get_pixel(x, last_y), MERGE_TOLERANCE)
	for y in image.get_height():
		_add_unique_background_color(colors, image.get_pixel(0, y), MERGE_TOLERANCE)
		_add_unique_background_color(colors, image.get_pixel(last_x, y), MERGE_TOLERANCE)
	return colors


static func _add_unique_background_color(
	colors: Array[Color], sample: Color, merge_tolerance: float
) -> void:
	for existing in colors:
		if _color_distance(sample, existing) <= merge_tolerance:
			return
	colors.append(sample)


static func _build_edge_background_mask(
	image: Image, background_colors: Array[Color], tolerance: float, alpha_threshold: float
) -> PackedByteArray:
	var width := image.get_width()
	var height := image.get_height()
	var mask := PackedByteArray()
	mask.resize(width * height)
	var queue: Array[Vector2i] = []

	for x in width:
		_try_enqueue_background(
			image, mask, queue, Vector2i(x, 0), background_colors, tolerance, alpha_threshold
		)
		_try_enqueue_background(
			image,
			mask,
			queue,
			Vector2i(x, height - 1),
			background_colors,
			tolerance,
			alpha_threshold
		)
	for y in height:
		_try_enqueue_background(
			image, mask, queue, Vector2i(0, y), background_colors, tolerance, alpha_threshold
		)
		_try_enqueue_background(
			image,
			mask,
			queue,
			Vector2i(width - 1, y),
			background_colors,
			tolerance,
			alpha_threshold
		)

	var read_index := 0
	while read_index < queue.size():
		var point := queue[read_index]
		read_index += 1
		_try_enqueue_background(
			image, mask, queue, point + Vector2i.LEFT, background_colors, tolerance, alpha_threshold
		)
		_try_enqueue_background(
			image,
			mask,
			queue,
			point + Vector2i.RIGHT,
			background_colors,
			tolerance,
			alpha_threshold
		)
		_try_enqueue_background(
			image, mask, queue, point + Vector2i.UP, background_colors, tolerance, alpha_threshold
		)
		_try_enqueue_background(
			image, mask, queue, point + Vector2i.DOWN, background_colors, tolerance, alpha_threshold
		)
	return mask


static func _try_enqueue_background(
	image: Image,
	mask: PackedByteArray,
	queue: Array[Vector2i],
	point: Vector2i,
	background_colors: Array[Color],
	tolerance: float,
	alpha_threshold: float
) -> void:
	if point.x < 0 or point.y < 0 or point.x >= image.get_width() or point.y >= image.get_height():
		return
	var index := point.y * image.get_width() + point.x
	if mask[index] == 1:
		return
	var color := image.get_pixel(point.x, point.y)
	if (
		color.a > alpha_threshold
		and not _matches_any_background(color, background_colors, tolerance)
	):
		return
	mask[index] = 1
	queue.append(point)


static func _matches_any_background(
	color: Color, background_colors: Array[Color], tolerance: float
) -> bool:
	for background_color in background_colors:
		if _color_distance(color, background_color) <= tolerance:
			return true
	return false


static func _color_distance(a: Color, b: Color) -> float:
	var dr := a.r - b.r
	var dg := a.g - b.g
	var db := a.b - b.b
	return sqrt(dr * dr + dg * dg + db * db)


static func _apply_background_mask(
	image: Image, mask: PackedByteArray, make_transparent: bool
) -> Image:
	var cleaned := image.duplicate()
	if not make_transparent:
		return cleaned

	for y in cleaned.get_height():
		for x in cleaned.get_width():
			var index: int = y * cleaned.get_width() + x
			if mask[index] == 1:
				cleaned.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
	return cleaned


static func _fit_size(source_size: Vector2i, max_size: Vector2i, allow_upscale: bool) -> Vector2i:
	var scale: float = minf(
		float(max_size.x) / float(source_size.x), float(max_size.y) / float(source_size.y)
	)
	if not allow_upscale:
		scale = minf(scale, 1.0)
	return Vector2i(
		maxi(roundi(float(source_size.x) * scale), 1), maxi(roundi(float(source_size.y) * scale), 1)
	)


static func _format_name(
	pattern: String, stem: String, sprite_name: String, index: int, row: int, column: int
) -> String:
	return (
		pattern
		. format(
			{
				"stem": stem,
				"name": sprite_name,
				"index": "%02d" % [index + 1],
				"index0": str(index),
				"row": "%02d" % [row + 1],
				"row0": str(row),
				"col": "%02d" % [column + 1],
				"col0": str(column),
			}
		)
	)
