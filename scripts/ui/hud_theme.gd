class_name HudTheme
extends RefCounted
## Component-level theming for the in-game UI. Every value here is sourced from
## DesignSystem tokens — this file only composes tokens into the concrete
## StyleBoxes and label styles each HUD/menu widget needs.

const DS := preload("res://scripts/ui/design_system.gd")

# Back-compat aliases so older call sites keep resolving through the tokens.
const COLOR_TEXT := DS.TEXT
const COLOR_PARCHMENT := DS.PARCHMENT
const COLOR_METAL := DS.METAL
const DISPLAY_FONT := DS.FONT_DISPLAY
const GREASE_COUNTER_LABEL_FONT := DS.FONT_LABEL
const GREASE_COUNTER_VALUE_FONT := DS.FONT_VALUE
const GREASE_COUNTER_BADGE_TEXTURE := preload("res://assets/ui/grease_counter_badge.png")
const GREASE_COUNTER_DROP_TEXTURE := preload("res://assets/ui/grease_counter_drop.png")


static func make_paper_panel_style(accent: Color) -> StyleBoxFlat:
	var style := DS.stylebox(DS.PARCHMENT, accent, DS.BORDER_THICK, DS.RADIUS_MD, 2)
	return DS.padded(style, DS.SPACE_XS, DS.SPACE_XS)


static func make_metal_panel_style(_accent: Color) -> StyleBoxFlat:
	var style := DS.stylebox(DS.METAL, DS.METAL_EDGE, DS.BORDER_THICK, DS.RADIUS_LG, 3)
	return DS.padded(style, DS.SPACE_XS, DS.SPACE_XS)


static func make_top_hud_style() -> StyleBoxFlat:
	var style := DS.stylebox(DS.BRASS, DS.BRASS_EDGE, DS.BORDER_THICK, DS.RADIUS_MD, 2)
	return DS.padded(style, DS.SPACE_MD, DS.SPACE_XS)


static func make_weapon_slot_style() -> StyleBoxFlat:
	return DS.stylebox(DS.PARCHMENT, DS.INK, DS.BORDER_THIN, DS.RADIUS_SM)


static func make_button_style(accent: Color, bg: Color) -> StyleBoxFlat:
	var style := DS.stylebox(bg, accent, DS.BORDER_THIN, DS.RADIUS_MD)
	return DS.padded(style, DS.SPACE_LG, DS.SPACE_SM)


static func make_settings_field_style() -> StyleBoxFlat:
	var style := make_button_style(DS.INK, Color(0.66, 0.55, 0.36, 0.92))
	style.border_width_left = DS.BORDER_HAIRLINE
	style.border_width_top = DS.BORDER_HAIRLINE
	style.border_width_right = DS.BORDER_HAIRLINE
	style.border_width_bottom = DS.BORDER_HAIRLINE
	return style


static func make_settings_row_style() -> StyleBoxFlat:
	var bg := Color(DS.PARCHMENT_SUNK.r, DS.PARCHMENT_SUNK.g, DS.PARCHMENT_SUNK.b, 0.5)
	return DS.stylebox(bg, Color(0.2, 0.13, 0.06, 0.72), DS.BORDER_HAIRLINE, DS.RADIUS_MD)


static func make_transparent_button_style() -> StyleBoxFlat:
	return DS.stylebox(Color(0, 0, 0, 0), Color(0, 0, 0, 0), 0, 0)


static func make_settings_slider_track(fill: Color) -> StyleBoxFlat:
	var style := DS.stylebox(fill, DS.INK_STRONG, DS.BORDER_HAIRLINE, DS.RADIUS_MD)
	style.content_margin_top = DS.SPACE_XS
	style.content_margin_bottom = DS.SPACE_XS
	return style


static func make_settings_slider_grabber() -> StyleBoxFlat:
	var style := DS.stylebox(Color(0.62, 0.58, 0.49, 1.0), DS.INK, DS.BORDER_THIN, DS.RADIUS_SM)
	style.content_margin_left = DS.SPACE_SM
	style.content_margin_right = DS.SPACE_SM
	style.content_margin_top = DS.SPACE_MD
	style.content_margin_bottom = DS.SPACE_MD
	return style


static func apply_settings_slider_style(slider: HSlider) -> void:
	slider.add_theme_stylebox_override("slider", make_settings_slider_track(DS.BLOOD_TROUGH))
	slider.add_theme_stylebox_override(
		"grabber_area", make_settings_slider_track(DS.GREASE.darkened(0.15))
	)
	slider.add_theme_stylebox_override(
		"grabber_area_highlight", make_settings_slider_track(DS.GREASE)
	)
	slider.add_theme_stylebox_override("grabber", make_settings_slider_grabber())
	slider.add_theme_stylebox_override("grabber_highlight", make_settings_slider_grabber())


static func apply_transparent_button_style(button: Button) -> void:
	var transparent := make_transparent_button_style()
	button.add_theme_font_override("font", DS.FONT_DISPLAY)
	button.add_theme_font_size_override("font_size", DS.FONT_SIZE_SUBHEADING)
	button.add_theme_stylebox_override("normal", transparent)
	button.add_theme_stylebox_override("hover", transparent)
	button.add_theme_stylebox_override("focus", transparent)
	button.add_theme_stylebox_override("pressed", transparent)
	button.add_theme_color_override("font_color", DS.TEXT)
	button.add_theme_color_override("font_hover_color", DS.TEXT.lightened(0.08))
	button.add_theme_color_override("font_focus_color", DS.TEXT)
	button.add_theme_color_override("font_pressed_color", DS.INK_PRESSED)


static func apply_action_button_style(button: Button, accent: Color) -> void:
	button.add_theme_font_override("font", DS.FONT_DISPLAY)
	button.add_theme_font_size_override("font_size", DS.FONT_SIZE_SUBHEADING)
	button.add_theme_stylebox_override("normal", make_button_style(accent, DS.PARCHMENT))
	button.add_theme_stylebox_override(
		"hover", make_button_style(accent.lightened(0.12), DS.PARCHMENT_LIGHT)
	)
	button.add_theme_stylebox_override(
		"focus", make_button_style(accent.lightened(0.25), DS.PARCHMENT_FOCUS)
	)
	button.add_theme_stylebox_override(
		"pressed", make_button_style(accent.darkened(0.15), DS.PARCHMENT_SUNK)
	)
	button.add_theme_stylebox_override(
		"disabled", make_button_style(accent.darkened(0.35), Color(0.48, 0.42, 0.32, 1.0))
	)
	button.add_theme_color_override("font_color", DS.TEXT)
	button.add_theme_color_override("font_hover_color", DS.TEXT)
	button.add_theme_color_override("font_focus_color", DS.TEXT)
	button.add_theme_color_override("font_pressed_color", DS.INK_PRESSED)
	button.add_theme_color_override("font_disabled_color", DS.TEXT_DISABLED)


static func apply_settings_button_style(button: BaseButton) -> void:
	button.tooltip_text = "Settings"
	if button is TextureButton:
		button.custom_minimum_size = Vector2(76, 76)
		return
	var text_button := button as Button
	if text_button == null:
		return
	text_button.text = "SET"
	apply_action_button_style(text_button, DS.GREASE.darkened(0.14))
	text_button.custom_minimum_size = Vector2(70, 42)
	text_button.add_theme_font_size_override("font_size", DS.FONT_SIZE_BODY)


static func apply_game_ui_theme(ui: CanvasLayer) -> void:
	const STAT_BAR_SCRIPT := preload("res://scripts/ui/stat_bar.gd")

	ui.shop_overlay.color = Color(0.0, 0.0, 0.0, 0.24)
	ui.hud_panel.add_theme_stylebox_override("panel", make_top_hud_style())
	ui.xp_panel.add_theme_stylebox_override("panel", make_paper_panel_style(DS.PARCHMENT_DARK))
	ui.level_up_panel.add_theme_stylebox_override("panel", make_paper_panel_style(DS.HERB))
	ui.shop_panel.add_theme_stylebox_override("panel", make_metal_panel_style(DS.GREASE))
	ui.character_select_panel.add_theme_stylebox_override(
		"panel", make_paper_panel_style(DS.GREASE)
	)
	ui.settings_panel.add_theme_stylebox_override("panel", make_transparent_button_style())
	var preview_style := DS.stylebox(
		DS.PARCHMENT_SUNK, DS.GREASE.darkened(0.25), DS.BORDER_HAIRLINE, DS.RADIUS_MD
	)
	ui.character_preview_panel.add_theme_stylebox_override("panel", preview_style)

	ui.hp_bar.set_script(STAT_BAR_SCRIPT)
	ui.hp_bar.setup_bar(DS.BLOOD_TROUGH, DS.BLOOD, 18.0, DS.RADIUS_SM)
	ui.xp_bar.set_script(STAT_BAR_SCRIPT)
	ui.xp_bar.setup_bar(DS.BLOOD_TROUGH, DS.BLOOD, 12.0, DS.RADIUS_SM)

	for label in [ui.hp_label, ui.timer_label, ui.kill_label, ui.hp_value_label, ui.level_label]:
		DS.style_label(label, DS.FONT_BODY, DS.FONT_SIZE_BODY, DS.TEXT)

	DS.style_label(ui.grease_title_label, DS.FONT_LABEL, DS.FONT_SIZE_SUBHEADING, DS.TEXT_MUTED)
	DS.style_label(ui.gold_label, DS.FONT_VALUE, DS.FONT_SIZE_HERO, DS.INK_STRONG)
	ui.gold_label.add_theme_color_override("font_shadow_color", Color(0.83, 0.68, 0.42, 0.35))
	ui.gold_label.add_theme_constant_override("shadow_offset_x", DS.BORDER_HAIRLINE)
	ui.gold_label.add_theme_constant_override("shadow_offset_y", DS.BORDER_HAIRLINE)
	DS.style_label(ui.shop_gold_label, DS.FONT_DISPLAY, DS.FONT_SIZE_SUBHEADING, DS.GREASE)
	DS.style_label(ui.shop_reroll_cost_label, DS.FONT_BODY, DS.FONT_SIZE_SUBHEADING, DS.TEXT_MUTED)

	apply_action_button_style(ui.restart_button, DS.BLOOD)
	apply_settings_button_style(ui.settings_button)
	apply_action_button_style(ui.shop_reroll_button, DS.GREASE)
	apply_action_button_style(ui.shop_continue_button, DS.HERB)
	apply_transparent_button_style(ui.settings_apply_button)
	apply_transparent_button_style(ui.settings_close_button)
	for row_bg_path in [
		"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/ResolutionRowBg",
		"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/MusicVolumeRowBg",
		"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/SoundVolumeRowBg",
		"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/MuteRowBg",
	]:
		var row_bg := ui.get_node_or_null(row_bg_path) as Panel
		if row_bg:
			row_bg.add_theme_stylebox_override("panel", make_settings_row_style())
	ui.resolution_option.add_theme_font_override("font", DS.FONT_BODY)
	ui.resolution_option.add_theme_font_size_override("font_size", DS.FONT_SIZE_BODY)
	ui.resolution_option.add_theme_stylebox_override("normal", make_settings_field_style())
	ui.resolution_option.add_theme_stylebox_override(
		"hover", make_button_style(DS.INK_PRESSED, Color(0.78, 0.65, 0.42, 1.0))
	)
	ui.resolution_option.add_theme_stylebox_override(
		"focus", make_button_style(DS.GREASE.darkened(0.24), Color(0.82, 0.7, 0.46, 1.0))
	)
	ui.resolution_option.add_theme_color_override("font_color", DS.TEXT)
	ui.resolution_option.add_theme_color_override("font_hover_color", DS.TEXT)
	ui.resolution_option.add_theme_color_override("font_focus_color", DS.TEXT)
	apply_settings_slider_style(ui.music_volume_slider)
	apply_settings_slider_style(ui.sound_volume_slider)
	ui.mute_all_checkbox.add_theme_font_override("font", DS.FONT_BODY)
	ui.mute_all_checkbox.add_theme_font_size_override("font_size", DS.FONT_SIZE_BODY)
	ui.mute_all_checkbox.add_theme_color_override("font_color", DS.TEXT)
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
	ui.overlay_label.add_theme_font_size_override("font_size", DS.FONT_SIZE_HERO)
	DS.style_label(ui.restart_hint, DS.FONT_BODY, DS.FONT_SIZE_BODY, DS.TEXT_MUTED)

	for button in ui._upgrade_buttons:
		button.add_theme_font_size_override("font_size", DS.FONT_SIZE_LABEL)

	for title in [
		ui.shop_title_label,
		ui.level_up_title_label,
		ui.character_select_title_label,
		ui.settings_title_label,
	]:
		title.add_theme_font_override("font", DS.FONT_DISPLAY)
		title.add_theme_color_override("font_color", DS.TEXT)

	DS.style_label(ui.shop_title_label, DS.FONT_DISPLAY, DS.FONT_SIZE_TITLE, DS.TEXT)
	DS.style_label(ui.shop_hint_label, DS.FONT_BODY, DS.FONT_SIZE_BODY, DS.TEXT_MUTED)
	ui.level_up_title_label.add_theme_color_override("font_color", DS.HERB)
	DS.style_label(ui.level_up_hint_label, DS.FONT_BODY, DS.FONT_SIZE_CAPTION, DS.TEXT_MUTED)
	ui.character_select_title_label.add_theme_color_override("font_color", DS.GREASE)
	DS.style_label(
		ui.character_select_hint_label, DS.FONT_BODY, DS.FONT_SIZE_CAPTION, DS.TEXT_MUTED
	)
	ui.character_detail_label.add_theme_color_override("font_color", DS.TEXT)
	ui.settings_title_label.add_theme_color_override("font_color", DS.TEAL)
	for label_path in [
		"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/ResolutionRow/NameLabel",
		"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/MusicVolumeRow/NameLabel",
		"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/MusicVolumeRow/ValueLabel",
		"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/SoundVolumeRow/NameLabel",
		"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/SoundVolumeRow/ValueLabel",
		"SettingsOverlay/CenterContainer/PanelContainer/SettingsContent/MuteRow/NameLabel",
	]:
		var label := ui.get_node_or_null(label_path) as Label
		if label:
			DS.style_label(label, DS.FONT_BODY, DS.FONT_SIZE_BODY, DS.TEXT)
