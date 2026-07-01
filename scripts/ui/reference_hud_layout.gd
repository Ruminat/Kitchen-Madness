class_name ReferenceHudLayout
extends RefCounted


static func apply(
	viewport_size: Vector2,
	hud_panel: Control,
	settings_button: Control,
	grease_counter: Control,
	xp_panel: Control,
	weapon_belt: Control,
	shop_panel: Control,
	shop_grid: GridContainer,
	shop_cards: Array[Button]
) -> void:
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	var hud_width := clampf(viewport_size.x - 420.0, 420.0, 540.0)
	hud_panel.anchor_left = 0.5
	hud_panel.anchor_right = 0.5
	hud_panel.offset_left = hud_width * -0.5
	hud_panel.offset_top = 14.0
	hud_panel.offset_right = hud_width * 0.5
	hud_panel.offset_bottom = 100.0

	grease_counter.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	var grease_width := clampf(viewport_size.x - 32.0, 288.0, 320.0)
	var grease_height := grease_width * 0.4
	grease_counter.offset_left = -16.0 - grease_width
	grease_counter.offset_top = 16.0
	grease_counter.offset_right = -16.0
	grease_counter.offset_bottom = 16.0 + grease_height

	var grease_row := grease_counter.get_node_or_null("Content/Row") as HBoxContainer
	var grease_drop := grease_counter.get_node_or_null("Content/Row/GreaseDrop") as TextureRect
	var text_stack := grease_counter.get_node_or_null("Content/Row/TextStack")
	var grease_title: Label = null
	var grease_gold: Label = null
	if text_stack:
		grease_title = text_stack.get_node_or_null("GreaseTitleLabel") as Label
		grease_gold = text_stack.get_node_or_null("GoldLabel") as Label
	if grease_drop:
		var drop_height := grease_height * 0.58
		var drop_width := drop_height * (178.0 / 256.0)
		grease_drop.custom_minimum_size = Vector2(drop_width, drop_height)
	if grease_row:
		grease_row.add_theme_constant_override("separation", 16)
	if grease_title:
		grease_title.add_theme_font_size_override("font_size", int(round(grease_height * 0.17)))
	if grease_gold:
		grease_gold.add_theme_font_size_override("font_size", int(round(grease_height * 0.42)))

	settings_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	settings_button.offset_left = -92.0
	settings_button.offset_top = grease_counter.offset_bottom + 8.0
	settings_button.offset_right = -16.0
	settings_button.offset_bottom = settings_button.offset_top + 42.0

	xp_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	xp_panel.offset_left = 16.0
	xp_panel.offset_top = -66.0
	xp_panel.offset_right = 462.0
	xp_panel.offset_bottom = -16.0

	if weapon_belt and weapon_belt.has_method("apply_bottom_center_layout"):
		weapon_belt.apply_bottom_center_layout()

	var shop_center := shop_panel.get_parent() as Control
	if shop_center:
		shop_center.anchor_left = 0.0
		shop_center.anchor_top = 1.0
		shop_center.anchor_right = 1.0
		shop_center.anchor_bottom = 1.0
		shop_center.offset_left = 0.0
		shop_center.offset_right = 0.0
		shop_center.offset_bottom = -8.0

	if viewport_size.x < 1180.0:
		shop_grid.columns = 3
		shop_panel.custom_minimum_size = Vector2(760, 0)
		if shop_center:
			shop_center.offset_top = -620.0
		for card in shop_cards:
			card.custom_minimum_size = Vector2(220, 242)
	else:
		shop_grid.columns = 5
		shop_panel.custom_minimum_size = Vector2(1240, 0)
		if shop_center:
			shop_center.offset_top = -388.0
		for card in shop_cards:
			card.custom_minimum_size = Vector2(218, 270)
