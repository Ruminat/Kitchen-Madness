class_name ShopDisplay
extends RefCounted

const DS := preload("res://scripts/ui/design_system.gd")

const DEFAULT_VISUAL := {"emoji": "🍳", "accent": DS.GREASE, "label": "OFFER"}

const VISUALS: Dictionary = {
	WeaponShopOffer.OfferType.ADD_WEAPON: {"emoji": "🆕", "accent": DS.HERB, "label": "NEW"},
	WeaponShopOffer.OfferType.WEAPON_DAMAGE: {"emoji": "🔪", "accent": DS.BLOOD, "label": "SHARPEN"},
	WeaponShopOffer.OfferType.WEAPON_ATTACK_SPEED:
	{"emoji": "⚡", "accent": DS.GREASE, "label": "SPEED"},
	WeaponShopOffer.OfferType.WEAPON_PELLET:
	{"emoji": "🥄", "accent": DS.RARITY_RARE, "label": "EXTRA"},
	WeaponShopOffer.OfferType.SELL_WEAPON:
	{"emoji": "💰", "accent": DS.RARITY_EPIC, "label": "SELL"},
}


static func is_sell_offer(offer: Resource) -> bool:
	return (
		offer is WeaponShopOffer
		and (offer as WeaponShopOffer).offer_type == WeaponShopOffer.OfferType.SELL_WEAPON
	)


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
	var normal := _make_style(accent, DS.PARCHMENT, DS.BORDER_THIN)
	var hover := _make_style(accent.lightened(0.1), DS.PARCHMENT_LIGHT, DS.BORDER_THIN)
	var focus := _make_style(accent.lightened(0.24), DS.PARCHMENT_FOCUS, DS.BORDER_THICK)
	var pressed := _make_style(accent.darkened(0.12), DS.PARCHMENT_SUNK, DS.BORDER_THIN)
	var disabled := _make_style(
		accent.darkened(0.3), Color(0.48, 0.43, 0.34, 1.0), DS.BORDER_HAIRLINE
	)

	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", DS.INK)
	button.add_theme_color_override("font_hover_color", DS.INK_STRONG)
	button.add_theme_color_override("font_focus_color", DS.INK_STRONG)
	button.add_theme_color_override("font_pressed_color", DS.INK_PRESSED)
	button.add_theme_color_override("font_disabled_color", DS.TEXT_DISABLED)
	button.add_theme_font_size_override("font_size", DS.FONT_SIZE_LABEL)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT


static func _make_style(accent: Color, bg: Color, border_width: int) -> StyleBoxFlat:
	var style := DS.stylebox(bg, accent, border_width, DS.RADIUS_MD, 1)
	return DS.padded(style, DS.SPACE_MD, DS.SPACE_SM)
