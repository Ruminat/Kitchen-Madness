class_name UpgradeDisplay
extends RefCounted

const DS := preload("res://scripts/ui/design_system.gd")

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

	button.add_theme_stylebox_override("normal", _make_style(accent, DS.PARCHMENT))
	button.add_theme_stylebox_override(
		"hover", _make_style(accent.lightened(0.12), DS.PARCHMENT_LIGHT)
	)
	button.add_theme_stylebox_override(
		"focus", _make_style(accent.lightened(0.25), DS.PARCHMENT_FOCUS)
	)
	button.add_theme_stylebox_override(
		"pressed", _make_style(accent.darkened(0.12), DS.PARCHMENT_SUNK)
	)
	button.add_theme_color_override("font_color", DS.INK)
	button.add_theme_color_override("font_hover_color", DS.INK_STRONG)
	button.add_theme_color_override("font_focus_color", DS.INK_STRONG)
	button.add_theme_color_override("font_pressed_color", DS.INK_PRESSED)
	button.add_theme_font_size_override("font_size", DS.FONT_SIZE_LABEL)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT


## A parchment card with a bold accent stripe down its left edge (the rarity/stat cue).
static func _make_style(accent: Color, bg: Color) -> StyleBoxFlat:
	var style := DS.stylebox(bg, accent, DS.BORDER_THIN, DS.RADIUS_LG, 1)
	style.border_width_left = DS.BORDER_THICK + 1
	return DS.padded(style, DS.SPACE_XL, DS.SPACE_LG)
