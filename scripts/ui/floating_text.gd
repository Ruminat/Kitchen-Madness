extends Label

signal finished

const FLOAT_DISTANCE := 48.0
const DURATION := 0.85
const POP_SCALE := 1.4
const POP_DURATION := 0.1
const SPAWN_SCALE := 0.3
const SPAWN_DURATION := 0.08

var _is_crit := false
var _tween: Tween

@onready var shadow: Label = $Shadow


func _ready() -> void:
	_create_shadow()


func _create_shadow() -> void:
	shadow = Label.new()
	shadow.name = "Shadow"
	shadow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shadow.add_theme_color_override("font_color", Color(0, 0, 0, 0.6))
	add_child(shadow)
	shadow.position = Vector2(2, 2)
	shadow.size = size


func play(text_value: String, canvas_pos: Vector2, color: Color) -> void:
	_play_internal(text_value, canvas_pos, color, false)


func play_damage(text_value: String, canvas_pos: Vector2, color: Color, is_crit: bool) -> void:
	_is_crit = is_crit
	_play_internal(text_value, canvas_pos, color, is_crit)


func _play_internal(text_value: String, canvas_pos: Vector2, color: Color, is_crit: bool) -> void:
	text = text_value
	shadow.text = text_value

	add_theme_color_override("font_color", color)
	var font_size := 26 if is_crit else 18
	add_theme_font_size_override("font_size", font_size)
	shadow.add_theme_font_size_override("font_size", font_size)

	horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pivot_offset = size * 0.5
	shadow.pivot_offset = shadow.size * 0.5

	# Random slight offset for variety
	var random_offset := Vector2(randf_range(-8, 8), randf_range(-5, 5))
	position = canvas_pos + random_offset
	shadow.position = position + Vector2(2, 2)

	# Start invisible and tiny for spawn punch effect
	scale = Vector2(SPAWN_SCALE, SPAWN_SCALE)
	shadow.scale = scale
	modulate.a = 0.0
	shadow.modulate.a = 0.0

	if _tween and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)

	# Spawn punch - scale up quickly with elastic bounce
	var target_scale := Vector2(1.6, 1.6) if is_crit else Vector2.ONE
	(
		_tween
		. chain()
		. tween_property(self, "scale", target_scale * 1.3, SPAWN_DURATION)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_ELASTIC)
	)
	(
		_tween
		. parallel()
		. tween_property(shadow, "scale", target_scale * 1.3, SPAWN_DURATION)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_ELASTIC)
	)

	# Fade in
	_tween.parallel().tween_property(self, "modulate:a", 1.0, SPAWN_DURATION * 0.5)
	_tween.parallel().tween_property(shadow, "modulate:a", 0.6, SPAWN_DURATION * 0.5)

	# Main animation
	if is_crit:
		_crit_animation(_tween, target_scale)
	else:
		_normal_animation(_tween, target_scale)

	_tween.finished.connect(_on_finished)


func _crit_animation(tween: Tween, target_scale: Vector2) -> void:
	# Big punch then settle
	(
		tween
		. chain()
		. tween_property(self, "scale", target_scale * 1.5, POP_DURATION)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_BACK)
	)
	(
		tween
		. parallel()
		. tween_property(shadow, "scale", target_scale * 1.5, POP_DURATION)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_BACK)
	)

	# Rotation wobble
	tween.parallel().tween_property(self, "rotation", deg_to_rad(-8), POP_DURATION * 0.5).set_ease(
		Tween.EASE_OUT
	)
	tween.chain().tween_property(self, "rotation", deg_to_rad(6), POP_DURATION * 0.8)
	tween.chain().tween_property(self, "rotation", deg_to_rad(-4), POP_DURATION * 0.8)
	tween.chain().tween_property(self, "rotation", 0.0, POP_DURATION)

	# Settle to stable size
	tween.chain().tween_property(self, "scale", target_scale, POP_DURATION * 2.0).set_ease(
		Tween.EASE_IN_OUT
	)
	tween.parallel().tween_property(shadow, "scale", target_scale, POP_DURATION * 2.0).set_ease(
		Tween.EASE_IN_OUT
	)

	# Shake effect
	var shake_duration := 0.03
	var shake_amount := 3.0
	for i in range(6):
		var shake_offset := Vector2(randf_range(-shake_amount, shake_amount), 0)
		tween.chain().tween_property(self, "position", position + shake_offset, shake_duration)
		tween.chain().tween_property(
			shadow, "position", shadow.position + shake_offset, shake_duration
		)

	# Float upward with slight arc
	var arc_offset := Vector2(randf_range(-20, 20), -FLOAT_DISTANCE)
	tween.chain().tween_property(self, "position", position + arc_offset, DURATION * 0.6).set_ease(
		Tween.EASE_OUT
	)
	(
		tween
		. parallel()
		. tween_property(shadow, "position", shadow.position + arc_offset, DURATION * 0.6)
		. set_ease(Tween.EASE_OUT)
	)

	# Continue floating and fade
	(
		tween
		. chain()
		. tween_property(self, "position:y", position.y - FLOAT_DISTANCE * 0.5, DURATION * 0.4)
		. set_ease(Tween.EASE_IN)
	)
	(
		tween
		. parallel()
		. tween_property(
			shadow, "position:y", shadow.position.y - FLOAT_DISTANCE * 0.5, DURATION * 0.4
		)
		. set_ease(Tween.EASE_IN)
	)

	# Fade out at end
	tween.parallel().tween_property(self, "modulate:a", 0.0, DURATION * 0.3).set_delay(
		DURATION * 0.5
	)
	tween.parallel().tween_property(shadow, "modulate:a", 0.0, DURATION * 0.3).set_delay(
		DURATION * 0.5
	)


func _normal_animation(tween: Tween, target_scale: Vector2) -> void:
	# Quick pop then settle
	tween.chain().tween_property(self, "scale", target_scale * POP_SCALE, POP_DURATION).set_ease(
		Tween.EASE_OUT
	)
	(
		tween
		. parallel()
		. tween_property(shadow, "scale", target_scale * POP_SCALE, POP_DURATION)
		. set_ease(Tween.EASE_OUT)
	)

	tween.chain().tween_property(self, "scale", target_scale, POP_DURATION * 1.5).set_ease(
		Tween.EASE_IN_OUT
	)
	tween.parallel().tween_property(shadow, "scale", target_scale, POP_DURATION * 1.5).set_ease(
		Tween.EASE_IN_OUT
	)

	# Float straight up with slight wobble
	var wobble := 5.0
	tween.chain().tween_property(self, "position:x", position.x + wobble, DURATION * 0.3)
	tween.chain().tween_property(self, "position:x", position.x - wobble, DURATION * 0.4)
	tween.chain().tween_property(self, "position:x", position.x, DURATION * 0.3)

	# Upward float
	(
		tween
		. parallel()
		. tween_property(self, "position:y", position.y - FLOAT_DISTANCE, DURATION)
		. set_ease(Tween.EASE_OUT)
	)
	(
		tween
		. parallel()
		. tween_property(shadow, "position:y", shadow.position.y - FLOAT_DISTANCE, DURATION)
		. set_ease(Tween.EASE_OUT)
	)

	# Fade out
	tween.parallel().tween_property(self, "modulate:a", 0.0, DURATION * 0.4).set_delay(
		DURATION * 0.3
	)
	tween.parallel().tween_property(shadow, "modulate:a", 0.0, DURATION * 0.4).set_delay(
		DURATION * 0.3
	)


func _on_finished() -> void:
	# Reset for pool reuse
	scale = Vector2.ONE
	shadow.scale = Vector2.ONE
	rotation = 0.0
	modulate.a = 0.0
	shadow.modulate.a = 0.0
	finished.emit()
