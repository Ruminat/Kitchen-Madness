class_name HudActionButton
extends Button

const HudThemeScript = preload("res://scripts/ui/hud_theme.gd")

var _title := ""
var _count := -1


func configure(title: String, accent: Color) -> void:
	_title = title
	focus_mode = Control.FOCUS_NONE
	custom_minimum_size = Vector2(184, 52)
	HudThemeScript.apply_action_button_style(self, accent)
	add_theme_font_size_override("font_size", 18)
	_refresh_text()


func set_count(count: int) -> void:
	## A count < 0 hides the badge entirely (e.g. the shop button).
	_count = count
	if _count == 0:
		disabled = true
	elif _count > 0:
		disabled = false
	_refresh_text()


func _refresh_text() -> void:
	if _count > 0:
		text = "%s (%d)" % [_title, _count]
	else:
		text = _title
