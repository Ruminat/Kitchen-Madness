# GdUnit generated TestSuite
extends GdUnitTestSuite

const DS := preload("res://scripts/ui/design_system.gd")


func test_spacing_scale_is_increasing_multiples_of_base() -> void:
	var scale := [DS.SPACE_XS, DS.SPACE_SM, DS.SPACE_MD, DS.SPACE_LG, DS.SPACE_XL, DS.SPACE_XXL]
	for i in scale.size():
		assert_int(scale[i] % DS.SPACE_XS).is_equal(0)
		if i > 0:
			assert_int(scale[i]).is_greater(scale[i - 1])


func test_radius_scale_is_strictly_increasing() -> void:
	assert_int(DS.RADIUS_SM).is_less(DS.RADIUS_MD)
	assert_int(DS.RADIUS_MD).is_less(DS.RADIUS_LG)


func test_border_weights_are_strictly_increasing() -> void:
	assert_int(DS.BORDER_HAIRLINE).is_less(DS.BORDER_THIN)
	assert_int(DS.BORDER_THIN).is_less(DS.BORDER_THICK)


func test_type_scale_is_strictly_increasing() -> void:
	var scale := [
		DS.FONT_SIZE_CAPTION,
		DS.FONT_SIZE_LABEL,
		DS.FONT_SIZE_BODY,
		DS.FONT_SIZE_SUBHEADING,
		DS.FONT_SIZE_HEADING,
		DS.FONT_SIZE_TITLE,
		DS.FONT_SIZE_DISPLAY,
		DS.FONT_SIZE_HERO,
	]
	for i in range(1, scale.size()):
		assert_int(scale[i]).is_greater(scale[i - 1])


func test_text_is_darker_than_every_surface() -> void:
	# Readability invariant: ink must sit clearly below each light surface.
	var text_luma := _luminance(DS.TEXT)
	for surface in [DS.PARCHMENT, DS.PARCHMENT_LIGHT, DS.PARCHMENT_FOCUS, DS.BRASS]:
		assert_float(text_luma).is_less(_luminance(surface) - 0.25)


func test_rarity_color_is_distinct_per_tier() -> void:
	var tiers := [
		DS.Rarity.COMMON,
		DS.Rarity.UNCOMMON,
		DS.Rarity.RARE,
		DS.Rarity.EPIC,
		DS.Rarity.LEGENDARY,
	]
	var seen: Array[Color] = []
	for tier in tiers:
		var color := DS.rarity_color(tier)
		assert_bool(seen.has(color)).is_false()
		seen.append(color)


func test_rarity_label_matches_tier() -> void:
	assert_str(DS.rarity_label(DS.Rarity.COMMON)).is_equal("COMMON")
	assert_str(DS.rarity_label(DS.Rarity.UNCOMMON)).is_equal("UNCOMMON")
	assert_str(DS.rarity_label(DS.Rarity.RARE)).is_equal("RARE")
	assert_str(DS.rarity_label(DS.Rarity.EPIC)).is_equal("EPIC")
	assert_str(DS.rarity_label(DS.Rarity.LEGENDARY)).is_equal("LEGENDARY")


func test_rarity_defaults_to_common_for_unknown_tier() -> void:
	assert_that(DS.rarity_color(999)).is_equal(DS.RARITY_COMMON)
	assert_str(DS.rarity_label(-1)).is_equal("COMMON")


func test_stylebox_applies_tokens_symmetrically() -> void:
	var style := DS.stylebox(DS.PARCHMENT, DS.INK, DS.BORDER_THIN, DS.RADIUS_MD)
	assert_that(style.bg_color).is_equal(DS.PARCHMENT)
	assert_that(style.border_color).is_equal(DS.INK)
	assert_int(style.border_width_left).is_equal(DS.BORDER_THIN)
	assert_int(style.border_width_top).is_equal(DS.BORDER_THIN)
	assert_int(style.border_width_right).is_equal(DS.BORDER_THIN)
	assert_int(style.border_width_bottom).is_equal(DS.BORDER_THIN)
	assert_int(style.corner_radius_top_left).is_equal(DS.RADIUS_MD)
	assert_int(style.corner_radius_bottom_right).is_equal(DS.RADIUS_MD)


func test_stylebox_default_elevation_has_no_shadow() -> void:
	var style := DS.stylebox(DS.PARCHMENT, DS.INK)
	assert_int(style.shadow_size).is_equal(0)


func test_shadowed_grows_with_elevation() -> void:
	var flat := DS.shadowed(StyleBoxFlat.new(), 0)
	var low := DS.shadowed(StyleBoxFlat.new(), 1)
	var high := DS.shadowed(StyleBoxFlat.new(), 3)
	assert_int(flat.shadow_size).is_equal(0)
	assert_int(low.shadow_size).is_greater(flat.shadow_size)
	assert_int(high.shadow_size).is_greater(low.shadow_size)


func test_shadowed_clamps_out_of_range_elevation() -> void:
	var clamped := DS.shadowed(StyleBoxFlat.new(), 99)
	var top := DS.shadowed(StyleBoxFlat.new(), DS.ELEVATION.size() - 1)
	assert_int(clamped.shadow_size).is_equal(top.shadow_size)


func test_padded_sets_symmetric_content_margins() -> void:
	var style := DS.padded(StyleBoxFlat.new(), DS.SPACE_LG, DS.SPACE_SM)
	assert_float(style.content_margin_left).is_equal(float(DS.SPACE_LG))
	assert_float(style.content_margin_right).is_equal(float(DS.SPACE_LG))
	assert_float(style.content_margin_top).is_equal(float(DS.SPACE_SM))
	assert_float(style.content_margin_bottom).is_equal(float(DS.SPACE_SM))


func test_style_label_applies_font_size_and_color() -> void:
	var label: Label = auto_free(Label.new())
	DS.style_label(label, DS.FONT_BODY, DS.FONT_SIZE_HEADING, DS.GREASE)
	assert_int(label.get_theme_font_size("font_size")).is_equal(DS.FONT_SIZE_HEADING)
	assert_that(label.get_theme_color("font_color")).is_equal(DS.GREASE)
	assert_object(label.get_theme_font("font")).is_equal(DS.FONT_BODY)


func _luminance(color: Color) -> float:
	return 0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b
