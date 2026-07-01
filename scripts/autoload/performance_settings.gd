extends Node

signal render_scale_changed(index: int, scale_factor: float)

const CONFIG_PATH := "user://settings.cfg"
const CONFIG_SECTION := "video"
const CONFIG_RESOLUTION := "resolution_index"

const BASE_RENDER_SIZE := Vector2i(1920, 1080)
const RESOLUTION_OPTIONS: Array[Dictionary] = [
	{"id": "1920x1080", "label": "1920 x 1080", "size": Vector2i(1920, 1080)},
	{"id": "1600x900", "label": "1600 x 900", "size": Vector2i(1600, 900)},
	{"id": "1280x720", "label": "1280 x 720", "size": Vector2i(1280, 720)},
	{"id": "960x540", "label": "960 x 540", "size": Vector2i(960, 540)},
]

var resolution_index := 0


func _ready() -> void:
	_load_settings()
	_apply_resolution()


func get_resolution_options() -> Array[Dictionary]:
	return RESOLUTION_OPTIONS.duplicate(true)


func get_resolution_label() -> String:
	return str(_current_resolution_option().get("label", "1920 x 1080"))


func get_render_scale_factor() -> float:
	var size: Vector2i = _current_resolution_option().get("size", BASE_RENDER_SIZE)
	return float(BASE_RENDER_SIZE.x) / float(maxi(size.x, 1))


func set_resolution_index(index: int, save := true) -> void:
	var next_index := clampi(index, 0, RESOLUTION_OPTIONS.size() - 1)
	if next_index == resolution_index:
		_apply_resolution()
		return

	resolution_index = next_index
	_apply_resolution()
	if save:
		_save_settings()


func cycle_resolution(direction: int) -> void:
	var step := 0
	if direction > 0:
		step = 1
	elif direction < 0:
		step = -1
	if step == 0:
		return

	set_resolution_index(resolution_index + step)


func _current_resolution_option() -> Dictionary:
	var index := clampi(resolution_index, 0, RESOLUTION_OPTIONS.size() - 1)
	return RESOLUTION_OPTIONS[index]


func _apply_resolution() -> void:
	var root := get_tree().root
	if root == null:
		return

	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_factor = get_render_scale_factor()
	render_scale_changed.emit(resolution_index, root.content_scale_factor)


func _load_settings() -> void:
	var config := ConfigFile.new()
	var result := config.load(CONFIG_PATH)
	if result != OK:
		return

	var value: int = int(config.get_value(CONFIG_SECTION, CONFIG_RESOLUTION, resolution_index))
	resolution_index = clampi(value, 0, RESOLUTION_OPTIONS.size() - 1)


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value(CONFIG_SECTION, CONFIG_RESOLUTION, resolution_index)
	config.save(CONFIG_PATH)
