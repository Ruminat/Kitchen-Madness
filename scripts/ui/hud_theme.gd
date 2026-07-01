class_name HudTheme
extends RefCounted

const COLOR_TEXT := Color(0.12, 0.08, 0.045, 1.0)
const COLOR_PARCHMENT := Color(0.78, 0.67, 0.46, 0.98)
const COLOR_METAL := Color(0.16, 0.15, 0.13, 0.94)
const DISPLAY_FONT := preload("res://assets/fonts/bangers.ttf")
const GREASE_COUNTER_LABEL_FONT: FontFile = preload("res://assets/fonts/noto_sans_semibold.ttf")
const GREASE_COUNTER_VALUE_FONT: FontFile = preload("res://assets/fonts/noto_sans_black.ttf")
const GREASE_COUNTER_BADGE_TEXTURE := preload("res://assets/ui/grease_counter_badge.png")
const GREASE_COUNTER_DROP_TEXTURE := preload("res://assets/ui/grease_counter_drop.png")


static func make_paper_panel_style(accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_PARCHMENT
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	style.border_color = accent
	style.set_corner_radius_all(5)
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	style.shadow_color = Color(0.05, 0.035, 0.02, 0.55)
	style.shadow_size = 9
	style.shadow_offset = Vector2(3, 5)
	return style


static func make_metal_panel_style(_accent: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = COLOR_METAL
	style.border_width_left = 5
	style.border_width_top = 5
	style.border_width_right = 5
	style.border_width_bottom = 5
	style.border_color = Color(0.45, 0.42, 0.35, 1.0)
	style.set_corner_radius_all(8)
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.65)
	style.shadow_size = 12
	style.shadow_offset = Vector2(4, 7)
	return style


static func make_top_hud_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.69, 0.58, 0.39, 0.94)
	style.border_width_left = 5
	style.border_width_top = 5
	style.border_width_right = 5
	style.border_width_bottom = 5
	style.border_color = Color(0.12, 0.085, 0.05, 0.98)
	style.set_corner_radius_all(7)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	style.shadow_color = Color(0.04, 0.025, 0.01, 0.7)
	style.shadow_size = 10
	style.shadow_offset = Vector2(3, 5)
	return style


static func make_weapon_slot_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.76, 0.66, 0.47, 1.0)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.12, 0.085, 0.045, 1.0)
	style.set_corner_radius_all(5)
	return style


static func make_button_style(accent: Color, bg: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = accent
	style.set_corner_radius_all(5)
	style.content_margin_left = 14
	style.content_margin_right = 14
	style.content_margin_top = 7
	style.content_margin_bottom = 7
	return style


static func apply_action_button_style(button: Button, accent: Color) -> void:
	button.add_theme_font_override("font", DISPLAY_FONT)
	button.add_theme_font_size_override("font_size", 22)
	button.add_theme_stylebox_override("normal", make_button_style(accent, COLOR_PARCHMENT))
	button.add_theme_stylebox_override(
		"hover", make_button_style(accent.lightened(0.12), Color(0.86, 0.76, 0.55, 1.0))
	)
	button.add_theme_stylebox_override(
		"focus", make_button_style(accent.lightened(0.25), Color(0.9, 0.8, 0.58, 1.0))
	)
	button.add_theme_stylebox_override(
		"pressed", make_button_style(accent.darkened(0.15), Color(0.66, 0.54, 0.36, 1.0))
	)
	button.add_theme_stylebox_override(
		"disabled", make_button_style(accent.darkened(0.35), Color(0.48, 0.42, 0.32, 1.0))
	)
	button.add_theme_color_override("font_color", COLOR_TEXT)
	button.add_theme_color_override("font_hover_color", COLOR_TEXT)
	button.add_theme_color_override("font_focus_color", COLOR_TEXT)
	button.add_theme_color_override("font_pressed_color", Color(0.18, 0.1, 0.04, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.37, 0.31, 0.24, 1.0))


static func apply_settings_button_style(button: Button) -> void:
	button.text = "SET"
	button.tooltip_text = "Settings"
	apply_action_button_style(button, Color(0.84, 0.59, 0.16, 1.0))
	button.custom_minimum_size = Vector2(70, 42)
	button.add_theme_font_size_override("font_size", 19)


static func apply_game_ui_theme(ui: CanvasLayer) -> void:
	const STAT_BAR_SCRIPT := preload("res://scripts/ui/stat_bar.gd")
	const BODY_FONT := preload("res://assets/fonts/jersey15.ttf")
	const COLOR_MUTED := Color(0.38, 0.28, 0.18, 1.0)
	const COLOR_GREASE := Color(0.98, 0.72, 0.13, 1.0)
	const COLOR_BAR_BG := Color(0.18, 0.12, 0.07, 1.0)
	const COLOR_BAR_FILL := Color(0.78, 0.12, 0.08, 1.0)
	const COLOR_XP_FILL := Color(0.74, 0.13, 0.07, 1.0)
	const COLOR_LEVEL_UP_ACCENT := Color(0.37, 0.66, 0.21, 1.0)
	const COLOR_CHARACTER_ACCENT := Color(0.86, 0.61, 0.18, 1.0)
	const COLOR_SETTINGS_ACCENT := Color(0.28, 0.49, 0.46, 1.0)
	const COLOR_PARCHMENT_DARK := Color(0.48, 0.37, 0.23, 1.0)

	ui.shop_overlay.color = Color(0.0, 0.0, 0.0, 0.24)
	ui.hud_panel.add_theme_stylebox_override("panel", make_top_hud_style())
	ui.xp_panel.add_theme_stylebox_override("panel", make_paper_panel_style(COLOR_PARCHMENT_DARK))
	ui.level_up_panel.add_theme_stylebox_override(
		"panel", make_paper_panel_style(COLOR_LEVEL_UP_ACCENT)
	)
	ui.shop_panel.add_theme_stylebox_override("panel", make_metal_panel_style(COLOR_GREASE))
	ui.character_select_panel.add_theme_stylebox_override(
		"panel", make_paper_panel_style(COLOR_CHARACTER_ACCENT)
	)
	ui.settings_panel.add_theme_stylebox_override(
		"panel", make_paper_panel_style(COLOR_SETTINGS_ACCENT)
	)
	var preview_style := StyleBoxFlat.new()
	preview_style.bg_color = Color(0.58, 0.47, 0.31, 1.0)
	preview_style.border_width_left = 2
	preview_style.border_width_top = 2
	preview_style.border_width_right = 2
	preview_style.border_width_bottom = 2
	preview_style.border_color = COLOR_CHARACTER_ACCENT.darkened(0.25)
	preview_style.set_corner_radius_all(5)
	ui.character_preview_panel.add_theme_stylebox_override("panel", preview_style)

	ui.hp_bar.set_script(STAT_BAR_SCRIPT)
	ui.hp_bar.setup_bar(COLOR_BAR_BG, COLOR_BAR_FILL, 18.0, 5)
	ui.xp_bar.set_script(STAT_BAR_SCRIPT)
	ui.xp_bar.setup_bar(COLOR_BAR_BG, COLOR_XP_FILL, 12.0, 4)

	for label in [
		ui.hp_label,
		ui.timer_label,
		ui.kill_label,
		ui.hp_value_label,
		ui.level_label,
	]:
		label.add_theme_color_override("font_color", COLOR_TEXT)
		label.add_theme_font_override("font", BODY_FONT)
		label.add_theme_font_size_override("font_size", 20)

	ui.grease_title_label.add_theme_color_override("font_color", COLOR_MUTED)
	ui.grease_title_label.add_theme_font_override("font", GREASE_COUNTER_LABEL_FONT)
	ui.grease_title_label.add_theme_font_size_override("font_size", 22)
	ui.gold_label.add_theme_color_override("font_color", Color(0.08, 0.045, 0.025, 1.0))
	ui.gold_label.add_theme_font_override("font", GREASE_COUNTER_VALUE_FONT)
	ui.gold_label.add_theme_font_size_override("font_size", 54)
	ui.gold_label.add_theme_color_override("font_shadow_color", Color(0.83, 0.68, 0.42, 0.35))
	ui.gold_label.add_theme_constant_override("shadow_offset_x", 2)
	ui.gold_label.add_theme_constant_override("shadow_offset_y", 2)
	ui.shop_gold_label.add_theme_color_override("font_color", COLOR_GREASE)
	ui.shop_gold_label.add_theme_font_override("font", DISPLAY_FONT)
	ui.shop_gold_label.add_theme_font_size_override("font_size", 24)
	ui.shop_reroll_cost_label.add_theme_color_override("font_color", COLOR_MUTED)
	ui.shop_reroll_cost_label.add_theme_font_override("font", BODY_FONT)
	ui.shop_reroll_cost_label.add_theme_font_size_override("font_size", 22)

	apply_action_button_style(ui.restart_button, COLOR_BAR_FILL)
	apply_settings_button_style(ui.settings_button)
	apply_action_button_style(ui.shop_reroll_button, COLOR_GREASE)
	apply_action_button_style(ui.shop_continue_button, COLOR_LEVEL_UP_ACCENT)
	apply_action_button_style(ui.settings_close_button, COLOR_SETTINGS_ACCENT)
	var grease_badge := ui.get_node_or_null("GreaseCounter/Badge") as TextureRect
	if grease_badge:
		grease_badge.texture = GREASE_COUNTER_BADGE_TEXTURE
		grease_badge.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		grease_badge.stretch_mode = TextureRect.STRETCH_SCALE
	var grease_drop := ui.get_node_or_null("GreaseCounter/Content/Row/GreaseDrop") as TextureRect
	if grease_drop:
		grease_drop.texture = GREASE_COUNTER_DROP_TEXTURE
		grease_drop.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		grease_drop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ui.overlay_label.add_theme_font_size_override("font_size", 48)
	ui.restart_hint.add_theme_color_override("font_color", COLOR_MUTED)
	ui.restart_hint.add_theme_font_size_override("font_size", 18)

	for button in ui._upgrade_buttons:
		button.add_theme_font_size_override("font_size", 17)

	for title in [
		ui.shop_title_label,
		ui.level_up_title_label,
		ui.character_select_title_label,
		ui.settings_title_label,
	]:
		title.add_theme_font_override("font", DISPLAY_FONT)
		title.add_theme_color_override("font_color", COLOR_TEXT)

	ui.shop_title_label.add_theme_color_override("font_color", COLOR_TEXT)
	ui.shop_title_label.add_theme_font_size_override("font_size", 34)
	ui.shop_hint_label.add_theme_color_override("font_color", COLOR_MUTED)
	ui.shop_hint_label.add_theme_font_override("font", BODY_FONT)
	ui.shop_hint_label.add_theme_font_size_override("font_size", 19)
	ui.level_up_title_label.add_theme_color_override("font_color", COLOR_LEVEL_UP_ACCENT)
	ui.level_up_hint_label.add_theme_color_override("font_color", COLOR_MUTED)
	ui.level_up_hint_label.add_theme_font_size_override("font_size", 14)
	ui.character_select_title_label.add_theme_color_override("font_color", COLOR_CHARACTER_ACCENT)
	ui.character_select_hint_label.add_theme_color_override("font_color", COLOR_MUTED)
	ui.character_select_hint_label.add_theme_font_size_override("font_size", 14)
	ui.character_detail_label.add_theme_color_override("font_color", COLOR_TEXT)
	ui.settings_title_label.add_theme_color_override("font_color", COLOR_SETTINGS_ACCENT)
	ui.render_scale_value_label.add_theme_color_override("font_color", COLOR_TEXT)
	ui.render_scale_value_label.add_theme_font_size_override("font_size", 18)
