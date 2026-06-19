class_name ShopDisplay
extends RefCounted

const DEFAULT_VISUAL := {"emoji": "🍳", "accent": Color(0.82, 0.58, 0.28)}

const VISUALS: Dictionary = {
	WeaponShopOffer.OfferType.ADD_WEAPON: {"emoji": "🆕", "accent": Color(0.42, 0.78, 0.52)},
	WeaponShopOffer.OfferType.WEAPON_DAMAGE: {"emoji": "🔪", "accent": Color(0.95, 0.48, 0.28)},
	WeaponShopOffer.OfferType.WEAPON_ATTACK_SPEED:
	{"emoji": "⚡", "accent": Color(0.95, 0.82, 0.32)},
	WeaponShopOffer.OfferType.WEAPON_PELLET: {"emoji": "🥄", "accent": Color(0.55, 0.72, 0.95)},
}


static func get_visual(offer: WeaponShopOffer) -> Dictionary:
	return VISUALS.get(offer.offer_type, DEFAULT_VISUAL)


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
