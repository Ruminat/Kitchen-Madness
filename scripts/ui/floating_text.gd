extends Label

signal finished

const FLOAT_DISTANCE := 40.0
const DURATION := 0.7
const FONT_NORMAL_SIZE := 36
const FONT_CRIT_SIZE := 40

var _tween: Tween
var _world_pos := Vector2.ZERO
var _screen_y_offset := 0.0


func play(text_value: String, world_pos: Vector2, color: Color) -> void:
	_play_internal(text_value, world_pos, color, false)


func play_damage(text_value: String, world_pos: Vector2, color: Color, is_crit: bool) -> void:
	_play_internal(text_value, world_pos, color, is_crit)


func get_world_pos() -> Vector2:
	return _world_pos


func sync_canvas_position() -> void:
	if not visible:
		return

	var canvas_pos := get_viewport().get_canvas_transform() * _world_pos
	canvas_pos.y += _screen_y_offset
	position = canvas_pos
	pivot_offset = size * 0.5


func _play_internal(text_value: String, world_pos: Vector2, color: Color, is_crit: bool) -> void:
	text = text_value
	_world_pos = world_pos
	_screen_y_offset = 0.0

	add_theme_color_override("font_color", color)
	var font_size := FONT_CRIT_SIZE if is_crit else FONT_NORMAL_SIZE
	add_theme_font_size_override("font_size", font_size)

	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scale = Vector2.ONE
	modulate.a = 1.0
	rotation = 0.0

	reset_size()
	sync_canvas_position()

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()

	if is_crit:
		_crit_animation(_tween)
	else:
		_normal_animation(_tween)

	_tween.finished.connect(_on_finished)


func _set_screen_y_offset(offset: float) -> void:
	_screen_y_offset = offset
	sync_canvas_position()


func _crit_animation(tween: Tween) -> void:
	tween.tween_property(self, "rotation", deg_to_rad(-6), 0.06)
	tween.chain().tween_property(self, "rotation", deg_to_rad(4), 0.1)
	tween.chain().tween_property(self, "rotation", 0.0, 0.08)

	tween.chain().tween_method(_set_screen_y_offset, 0.0, -FLOAT_DISTANCE, DURATION * 0.6).set_ease(
		Tween.EASE_OUT
	)
	tween.parallel().tween_property(self, "modulate:a", 0.0, DURATION * 0.4).set_delay(
		DURATION * 0.3
	)


func _normal_animation(tween: Tween) -> void:
	tween.tween_method(_set_screen_y_offset, 0.0, -FLOAT_DISTANCE, DURATION).set_ease(
		Tween.EASE_OUT
	)
	tween.parallel().tween_property(self, "modulate:a", 0.0, DURATION * 0.4).set_delay(
		DURATION * 0.3
	)


func _on_finished() -> void:
	modulate.a = 0.0
	rotation = 0.0
	_screen_y_offset = 0.0
	finished.emit()
