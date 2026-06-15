extends SceneTree

const Splitter := preload("res://tools/grid_sprite_splitter.gd")
const USAGE := """
Split a generated character grid into centered PNG sprites.

Usage:
  godot --headless --path . -s res://tools/split_grid_sprites.gd -- --input INPUT --output-dir DIR --grid 3x3

Options:
  --input, -i PATH              Source image path.
  --output-dir, -o DIR          Directory where PNG sprites are written.
  --grid CxR                    Grid size, for example 3x3.
  --cols N                      Column count. Use with --rows.
  --rows N                      Row count. Use with --cols.
  --pattern PATTERN             Output name pattern. Default: {stem}_{index}.png
                                Tokens: {stem}, {name}, {index}, {index0}, {row}, {row0}, {col}, {col0}
  --names CSV                   Optional comma-separated names in grid order. Use with {name}.
  --output-size WxH             Output sprite size. Example: 256x256. A single N means NxN.
  --padding N                   Empty pixels kept around the centered subject. Default: 8.
  --background-color HEX        Override sampled corner background. Example: #000000.
  --background-tolerance N      Background color tolerance from 0.0 to 1.732. Default: 0.08.
  --alpha-threshold N           Pixels at or below this alpha are background. Default: 0.04.
  --keep-background             Keep the original cell background instead of making it transparent.
  --no-upscale                  Do not enlarge subjects smaller than the output box.
  --help, -h                    Show this help.
"""


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var parsed := _parse_args(args)
	if parsed.get("help", false):
		print(USAGE)
		quit(0)
		return

	var error_message := _validate_args(parsed)
	if not error_message.is_empty():
		printerr(error_message)
		printerr(USAGE)
		quit(1)
		return

	var options := _build_split_options(parsed)
	var saved_paths: Array[String] = Splitter.split_file(
		parsed["input"],
		parsed["output_dir"],
		parsed["cols"],
		parsed["rows"],
		parsed.get("pattern", "{stem}_{index}.png"),
		options
	)
	if saved_paths.is_empty():
		quit(1)
		return

	print("Saved %d sprites:" % saved_paths.size())
	for path in saved_paths:
		print("  %s" % path)
	quit(0)


func _parse_args(args: PackedStringArray) -> Dictionary:
	var parsed := {}
	var index := 0
	while index < args.size():
		var arg := args[index]
		match arg:
			"--help", "-h":
				parsed["help"] = true
			"--input", "-i":
				index += 1
				parsed["input"] = _read_value(args, index, arg)
			"--output-dir", "-o":
				index += 1
				parsed["output_dir"] = _read_value(args, index, arg)
			"--grid":
				index += 1
				var grid := _read_value(args, index, arg).split("x")
				if grid.size() == 2:
					parsed["cols"] = grid[0].to_int()
					parsed["rows"] = grid[1].to_int()
			"--cols":
				index += 1
				parsed["cols"] = _read_value(args, index, arg).to_int()
			"--rows":
				index += 1
				parsed["rows"] = _read_value(args, index, arg).to_int()
			"--pattern":
				index += 1
				parsed["pattern"] = _read_value(args, index, arg)
			"--names":
				index += 1
				parsed["names"] = _parse_names(_read_value(args, index, arg))
			"--output-size":
				index += 1
				parsed["output_size"] = _parse_size(_read_value(args, index, arg))
			"--padding":
				index += 1
				parsed["padding"] = _read_value(args, index, arg).to_int()
			"--background-color":
				index += 1
				parsed["background_color"] = Color.html(_read_value(args, index, arg))
			"--background-tolerance":
				index += 1
				parsed["background_tolerance"] = _read_value(args, index, arg).to_float()
			"--alpha-threshold":
				index += 1
				parsed["alpha_threshold"] = _read_value(args, index, arg).to_float()
			"--keep-background":
				parsed["make_background_transparent"] = false
			"--no-upscale":
				parsed["allow_upscale"] = false
			_:
				printerr("Unknown argument: %s" % arg)
		index += 1
	return parsed


func _read_value(args: PackedStringArray, index: int, option_name: String) -> String:
	if index >= args.size():
		printerr("Missing value for %s." % option_name)
		return ""
	return args[index]


func _parse_size(value: String) -> Vector2i:
	if value.contains("x"):
		var parts := value.split("x")
		if parts.size() == 2:
			return Vector2i(parts[0].to_int(), parts[1].to_int())
	var side := value.to_int()
	return Vector2i(side, side)


func _parse_names(value: String) -> PackedStringArray:
	var names := PackedStringArray()
	for raw_name in value.split(","):
		var cleaned_name := raw_name.strip_edges()
		if not cleaned_name.is_empty():
			names.append(cleaned_name)
	return names


func _validate_args(parsed: Dictionary) -> String:
	if not parsed.has("input") or parsed["input"].is_empty():
		return "Missing --input."
	if not parsed.has("output_dir") or parsed["output_dir"].is_empty():
		return "Missing --output-dir."
	if parsed.get("cols", 0) <= 0 or parsed.get("rows", 0) <= 0:
		return "Missing or invalid grid size. Use --grid CxR or --cols N --rows N."
	return ""


func _build_split_options(parsed: Dictionary) -> Dictionary:
	var options := {}
	for key in [
		"output_size",
		"padding",
		"background_color",
		"background_tolerance",
		"alpha_threshold",
		"make_background_transparent",
		"allow_upscale",
		"names",
	]:
		if parsed.has(key):
			options[key] = parsed[key]
	return options
