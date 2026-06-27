class_name ShopDisplay
extends RefCounted

const DEFAULT_VISUAL := {"emoji": "🍳", "accent": Color(0.74, 0.46, 0.18), "label": "OFFER"}

const VISUALS: Dictionary = {
	WeaponShopOffer.OfferType.ADD_WEAPON:
	{"emoji": "🆕", "accent": Color(0.35, 0.61, 0.21), "label": "NEW"},
	WeaponShopOffer.OfferType.WEAPON_DAMAGE:
	{"emoji": "🔪", "accent": Color(0.72, 0.17, 0.12), "label": "SHARPEN"},
	WeaponShopOffer.OfferType.WEAPON_ATTACK_SPEED:
	{"emoji": "⚡", "accent": Color(0.86, 0.62, 0.18), "label": "SPEED"},
	WeaponShopOffer.OfferType.WEAPON_PELLET:
	{"emoji": "🥄", "accent": Color(0.22, 0.45, 0.68), "label": "EXTRA"},
}


static func get_visual(offer: WeaponShopOffer) -> Dictionary:
	return VISUALS.get(offer.offer_type, DEFAULT_VISUAL)


static func get_type_label(offer: WeaponShopOffer) -> String:
	return String(get_visual(offer).label)


static func get_weapon_icon(offer: WeaponShopOffer) -> Texture2D:
	if offer.offer_type == WeaponShopOffer.OfferType.ADD_WEAPON and offer.weapon:
		return offer.weapon.icon

	if not offer.weapon_id.is_empty():
		var definition := WeaponRoster.get_by_id(offer.weapon_id)
		if definition:
			return definition.icon

	return null


static func format_price(cost: int, _can_afford: bool) -> String:
	return "Grease %d" % cost


static func format_card_text(offer: Resource, hotkey: String) -> String:
	if offer is WeaponShopOffer:
		var shop_offer := offer as WeaponShopOffer
		var visual := get_visual(shop_offer)
		return "%s  %s   %s\n%s" % [visual.emoji, shop_offer.title, hotkey, shop_offer.description]

	if offer.has_method("get") and offer.get("title"):
		return UpgradeDisplay.format_card_text(offer, hotkey)

	return "%s   %s" % [offer, hotkey]


static func apply_card_style(button: Button, offer: Resource) -> void:
	if offer is WeaponShopOffer:
		var accent: Color = get_visual(offer as WeaponShopOffer).accent
		_apply_style(button, accent)
		return

	UpgradeDisplay.apply_card_style(button, offer)


static func _apply_style(button: Button, accent: Color) -> void:
	var normal := _make_style(accent, Color(0.78, 0.67, 0.46, 1.0), 3)
	var hover := _make_style(accent.lightened(0.1), Color(0.86, 0.76, 0.54, 1.0), 4)
	var focus := _make_style(accent.lightened(0.24), Color(0.9, 0.8, 0.57, 1.0), 5)
	var pressed := _make_style(accent.darkened(0.12), Color(0.68, 0.55, 0.36, 1.0), 3)
	var disabled := _make_style(accent.darkened(0.3), Color(0.48, 0.43, 0.34, 1.0), 2)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color(0.09, 0.065, 0.045))
	button.add_theme_color_override("font_hover_color", Color(0.05, 0.035, 0.025))
	button.add_theme_color_override("font_focus_color", Color(0.04, 0.025, 0.015))
	button.add_theme_color_override("font_pressed_color", Color(0.13, 0.08, 0.04))
	button.add_theme_color_override("font_disabled_color", Color(0.28, 0.25, 0.21))
	button.add_theme_font_size_override("font_size", 17)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT


static func _make_style(accent: Color, bg: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.border_color = accent
	style.set_corner_radius_all(5)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	style.shadow_color = Color(0.08, 0.055, 0.035, 0.45)
	style.shadow_size = 5
	style.shadow_offset = Vector2(2, 3)
	return style
