class_name UpgradeDisplay
extends RefCounted

const DEFAULT_VISUAL := {"emoji": "✨", "accent": Color(0.55, 0.72, 0.95)}

const VISUALS: Dictionary = {
	&"max_health_flat": {"emoji": "❤️", "accent": Color(0.88, 0.28, 0.38)},
	&"armor_flat": {"emoji": "🛡️", "accent": Color(0.52, 0.62, 0.88)},
	&"damage_percent": {"emoji": "⚔️", "accent": Color(0.95, 0.48, 0.28)},
	&"attack_speed_percent": {"emoji": "⚡", "accent": Color(0.95, 0.82, 0.32)},
	&"move_speed_percent": {"emoji": "👟", "accent": Color(0.42, 0.82, 0.52)},
	&"luck_flat": {"emoji": "🍀", "accent": Color(0.38, 0.82, 0.48)},
	&"pickup_range_flat": {"emoji": "🧲", "accent": Color(0.42, 0.68, 0.95)},
	&"xp_gain_percent": {"emoji": "📘", "accent": Color(0.35, 0.58, 0.95)},
}


static func get_visual(effect: StringName) -> Dictionary:
	return VISUALS.get(effect, DEFAULT_VISUAL)


static func format_card_text(upgrade: Resource, hotkey: String) -> String:
	var effect: StringName = upgrade.get("effect")
	var visual := get_visual(effect)
	var title: String = upgrade.get("title")
	var description: String = upgrade.get("description")
	return "%s  %s   %s\n%s" % [visual.emoji, title, hotkey, description]


static func apply_card_style(button: Button, upgrade: Resource) -> void:
	var effect: StringName = upgrade.get("effect")
	var accent: Color = get_visual(effect).accent

	var normal := _make_style(accent, Color(0.11, 0.12, 0.16, 1.0), 5)
	var hover := _make_style(accent.lightened(0.15), Color(0.14, 0.15, 0.2, 1.0), 5)
	var focus := _make_style(accent.lightened(0.35), Color(0.16, 0.18, 0.24, 1.0), 6)
	var pressed := _make_style(accent.darkened(0.1), Color(0.09, 0.1, 0.13, 1.0), 5)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color(0.92, 0.94, 0.97))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(0.82, 0.84, 0.9))
	button.add_theme_font_size_override("font_size", 17)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT


static func _make_style(accent: Color, bg: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_width_left = border_width
	style.border_color = accent
	style.set_corner_radius_all(10)
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style
