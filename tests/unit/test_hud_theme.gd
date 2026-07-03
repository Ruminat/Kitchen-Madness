# GdUnit generated TestSuite
extends GdUnitTestSuite

const DS := preload("res://scripts/ui/design_system.gd")
const HudThemeScript := preload("res://scripts/ui/hud_theme.gd")
const ShopDisplayScript := preload("res://scripts/ui/shop_display.gd")


func test_button_style_uses_border_and_radius_tokens() -> void:
	var style: StyleBoxFlat = HudThemeScript.make_button_style(DS.GREASE, DS.PARCHMENT)
	assert_int(style.border_width_left).is_equal(DS.BORDER_THIN)
	assert_int(style.corner_radius_top_left).is_equal(DS.RADIUS_MD)
	assert_float(style.content_margin_left).is_equal(float(DS.SPACE_LG))
	assert_float(style.content_margin_top).is_equal(float(DS.SPACE_SM))
	assert_that(style.border_color).is_equal(DS.GREASE)


func test_weapon_slot_style_uses_thin_border_small_radius() -> void:
	var style: StyleBoxFlat = HudThemeScript.make_weapon_slot_style()
	assert_int(style.border_width_left).is_equal(DS.BORDER_THIN)
	assert_int(style.corner_radius_top_left).is_equal(DS.RADIUS_SM)


func test_paper_panel_style_uses_accent_and_thick_border() -> void:
	var accent := DS.HERB
	var style: StyleBoxFlat = HudThemeScript.make_paper_panel_style(accent)
	assert_that(style.border_color).is_equal(accent)
	assert_int(style.border_width_left).is_equal(DS.BORDER_THICK)
	assert_that(style.bg_color).is_equal(DS.PARCHMENT)


func test_action_button_style_registers_all_states() -> void:
	var button: Button = auto_free(Button.new())
	HudThemeScript.apply_action_button_style(button, DS.GREASE)
	for state in ["normal", "hover", "focus", "pressed", "disabled"]:
		assert_object(button.get_theme_stylebox(state)).is_not_null()
	assert_object(button.get_theme_font("font")).is_equal(DS.FONT_DISPLAY)


func test_shop_offer_accents_come_from_design_tokens() -> void:
	assert_that(ShopDisplayScript.VISUALS[WeaponShopOffer.OfferType.ADD_WEAPON].accent).is_equal(
		DS.HERB
	)
	assert_that(ShopDisplayScript.VISUALS[WeaponShopOffer.OfferType.SELL_WEAPON].accent).is_equal(
		DS.RARITY_EPIC
	)
