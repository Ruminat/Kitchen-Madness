extends ProgressBar

const TWEEN_DURATION := 0.22

var _fill_style: StyleBoxFlat
var _fill_tween: Tween


func setup_bar(
	bg_color: Color,
	fill_color: Color,
	bar_height: float = 8.0,
	corner_radius: int = 3
) -> void:
	custom_minimum_size.y = bar_height
	show_percentage = false

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = bg_color
	bg_style.set_corner_radius_all(corner_radius)
	add_theme_stylebox_override("background", bg_style)

	_fill_style = StyleBoxFlat.new()
	_fill_style.bg_color = fill_color
	_fill_style.set_corner_radius_all(corner_radius)
	add_theme_stylebox_override("fill", _fill_style)


func set_fill_color(color: Color) -> void:
	if _fill_style:
		_fill_style.bg_color = color


func set_value_smooth(target: float, maximum: float) -> void:
	max_value = maximum
	if _fill_tween:
		_fill_tween.kill()
	_fill_tween = create_tween()
	_fill_tween.tween_property(self, "value", target, TWEEN_DURATION).set_ease(Tween.EASE_OUT)
