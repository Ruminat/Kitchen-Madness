extends Label

const FLOAT_DISTANCE := 36.0
const DURATION := 0.7


func play(text_value: String, canvas_pos: Vector2, color: Color) -> void:
	text = text_value
	add_theme_color_override("font_color", color)
	add_theme_font_size_override("font_size", 15)
	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	position = canvas_pos
	pivot_offset = size * 0.5
	modulate.a = 1.0

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "position:y", position.y - FLOAT_DISTANCE, DURATION).set_ease(
		Tween.EASE_OUT
	)
	tween.tween_property(self, "modulate:a", 0.0, DURATION).set_delay(0.15)
	tween.finished.connect(queue_free)
