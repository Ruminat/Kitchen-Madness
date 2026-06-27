class_name ReferenceHudLayout
extends RefCounted


static func apply(
	viewport_size: Vector2,
	hud_panel: Control,
	settings_button: Control,
	xp_panel: Control,
	weapon_belt: Control,
	shop_panel: Control,
	shop_grid: GridContainer,
	shop_cards: Array[Button]
) -> void:
	hud_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	hud_panel.anchor_left = 0.5
	hud_panel.anchor_right = 0.5
	hud_panel.offset_left = -360.0
	hud_panel.offset_top = 14.0
	hud_panel.offset_right = 360.0
	hud_panel.offset_bottom = 104.0

	settings_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	settings_button.offset_left = -116.0
	settings_button.offset_top = 18.0
	settings_button.offset_right = -16.0
	settings_button.offset_bottom = 50.0

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
