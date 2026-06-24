extends Node

signal render_scale_changed(index: int, scale_factor: float)

const CONFIG_PATH := "user://settings.cfg"
const CONFIG_SECTION := "video"
const CONFIG_RENDER_SCALE := "render_scale_index"

const RENDER_SCALE_OPTIONS: Array[Dictionary] = [
	{"id": "native", "label": "Native", "scale_factor": 1.0, "percent": 100},
	{"id": "balanced", "label": "Balanced", "scale_factor": 1.25, "percent": 80},
	{"id": "performance", "label": "Performance", "scale_factor": 1.5, "percent": 67},
	{"id": "potato", "label": "Potato", "scale_factor": 2.0, "percent": 50},
]

var render_scale_index := 0


func _ready() -> void:
	_load_settings()
	_apply_render_scale()


func get_render_scale_options() -> Array[Dictionary]:
	return RENDER_SCALE_OPTIONS.duplicate(true)


func get_render_scale_label() -> String:
	var option := _current_render_scale_option()
	return "%s (%d%%)" % [option.get("label", "Native"), option.get("percent", 100)]


func get_render_scale_factor() -> float:
	return float(_current_render_scale_option().get("scale_factor", 1.0))


func set_render_scale_index(index: int) -> void:
	var next_index := clampi(index, 0, RENDER_SCALE_OPTIONS.size() - 1)
	if next_index == render_scale_index:
		_apply_render_scale()
		return

	render_scale_index = next_index
	_apply_render_scale()
	_save_settings()


func cycle_render_scale(direction: int) -> void:
	var step := 0
	if direction > 0:
		step = 1
	elif direction < 0:
		step = -1
	if step == 0:
		return

	set_render_scale_index(render_scale_index + step)


func _current_render_scale_option() -> Dictionary:
	var index := clampi(render_scale_index, 0, RENDER_SCALE_OPTIONS.size() - 1)
	return RENDER_SCALE_OPTIONS[index]


func _apply_render_scale() -> void:
	var root := get_tree().root
	if root == null:
		return

	root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_EXPAND
	root.content_scale_factor = get_render_scale_factor()
	render_scale_changed.emit(render_scale_index, root.content_scale_factor)


func _load_settings() -> void:
	var config := ConfigFile.new()
	var result := config.load(CONFIG_PATH)
	if result != OK:
		return

	var value: int = int(config.get_value(CONFIG_SECTION, CONFIG_RENDER_SCALE, render_scale_index))
	render_scale_index = clampi(value, 0, RENDER_SCALE_OPTIONS.size() - 1)


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.load(CONFIG_PATH)
	config.set_value(CONFIG_SECTION, CONFIG_RENDER_SCALE, render_scale_index)
	config.save(CONFIG_PATH)
