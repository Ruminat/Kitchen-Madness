class_name ShopCard
extends Button

const COLOR_INK := Color(0.11, 0.075, 0.045, 1.0)
const COLOR_MUTED := Color(0.29, 0.2, 0.13, 1.0)
const COLOR_GREASE := Color(0.98, 0.72, 0.13, 1.0)
const COLOR_GREASE_DIM := Color(0.46, 0.34, 0.16, 1.0)
const COLOR_PAPER := Color(0.78, 0.67, 0.46, 1.0)
const COLOR_PAPER_DARK := Color(0.5, 0.39, 0.26, 1.0)
const DISPLAY_FONT := preload("res://assets/fonts/bangers.ttf")
const BODY_FONT := preload("res://assets/fonts/jersey15.ttf")

var _icon_rect: TextureRect
var _type_badge: Label
var _title_label: Label
var _desc_label: Label
var _hotkey_label: Label
var _price_label: Label
var _accent_strip: ColorRect
var _offer: Resource


func _ready() -> void:
	text = ""
	clip_text = true
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(218, 270)
	_build_layout()


func configure(offer: Resource, slot_index: int, player_gold: int, is_sold: bool = false) -> void:
	_offer = offer
	if offer == null:
		visible = true
		disabled = true
		tooltip_text = ""
		modulate = Color(0.7, 0.66, 0.58, 1.0)
		_title_label.text = "Empty Slot"
		_desc_label.text = "No offer available."
		_type_badge.text = "-"
		_icon_rect.texture = null
		_hotkey_label.text = str(slot_index + 1)
		_price_label.text = "-"
		_accent_strip.color = COLOR_PAPER_DARK
		return

	var cost := int(offer.get("gold_cost"))
	var can_afford := player_gold >= cost
	disabled = is_sold or not can_afford
	if is_sold:
		modulate = Color(0.72, 0.7, 0.65, 1.0)
	elif can_afford:
		modulate = Color.WHITE
	else:
		modulate = Color(0.78, 0.74, 0.68, 1.0)
	tooltip_text = str(offer.get("description"))

	if offer is WeaponShopOffer:
		var shop_offer := offer as WeaponShopOffer
		var visual := ShopDisplay.get_visual(shop_offer)
		_title_label.text = shop_offer.title
		_desc_label.text = shop_offer.description
		_type_badge.text = ShopDisplay.get_type_label(shop_offer)
		_type_badge.add_theme_color_override("font_color", COLOR_INK)
		_accent_strip.color = visual.accent
		_icon_rect.texture = ShopDisplay.get_weapon_icon(shop_offer)
		_icon_rect.modulate = Color.WHITE if _icon_rect.texture else Color(0.35, 0.31, 0.25, 0.5)
		ShopDisplay.apply_card_style(self, offer)
	else:
		_title_label.text = str(offer.get("title"))
		_desc_label.text = str(offer.get("description"))
		_type_badge.text = "UPGRADE"
		_icon_rect.texture = null
		_accent_strip.color = Color(0.35, 0.61, 0.58, 1.0)
		ShopDisplay.apply_card_style(self, offer)

	_hotkey_label.text = str(slot_index + 1)
	_price_label.text = "SOLD" if is_sold else ShopDisplay.format_price(cost, can_afford)
	_price_label.add_theme_color_override(
		"font_color", COLOR_GREASE if can_afford and not is_sold else COLOR_GREASE_DIM
	)


func _build_layout() -> void:
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	add_child(margin)

	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 7)
	margin.add_child(content)

	var header := VBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 3)
	content.add_child(header)

	_accent_strip = ColorRect.new()
	_accent_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_accent_strip.custom_minimum_size = Vector2(0, 22)
	header.add_child(_accent_strip)

	_type_badge = Label.new()
	_type_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_type_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_type_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_type_badge.add_theme_font_override("font", DISPLAY_FONT)
	_type_badge.add_theme_font_size_override("font_size", 18)
	_type_badge.add_theme_color_override("font_color", COLOR_INK)
	_type_badge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_accent_strip.add_child(_type_badge)

	_title_label = Label.new()
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_override("font", DISPLAY_FONT)
	_title_label.add_theme_color_override("font_color", COLOR_INK)
	_title_label.add_theme_font_size_override("font_size", 23)
	_title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	header.add_child(_title_label)

	var icon_panel := PanelContainer.new()
	icon_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_panel.custom_minimum_size = Vector2(0, 86)
	icon_panel.add_theme_stylebox_override("panel", _make_inset_style())
	content.add_child(icon_panel)

	_icon_rect = TextureRect.new()
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon_rect.custom_minimum_size = Vector2(72, 72)
	_icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_panel.add_child(_icon_rect)

	_desc_label = Label.new()
	_desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.max_lines_visible = 3
	_desc_label.add_theme_font_override("font", BODY_FONT)
	_desc_label.add_theme_color_override("font_color", COLOR_MUTED)
	_desc_label.add_theme_font_size_override("font_size", 18)
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_desc_label)

	var footer := HBoxContainer.new()
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_theme_constant_override("separation", 8)
	content.add_child(footer)

	var hotkey_panel := PanelContainer.new()
	hotkey_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotkey_panel.custom_minimum_size = Vector2(30, 30)
	hotkey_panel.add_theme_stylebox_override("panel", _make_hotkey_style())
	footer.add_child(hotkey_panel)

	_hotkey_label = Label.new()
	_hotkey_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hotkey_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hotkey_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_hotkey_label.add_theme_font_override("font", BODY_FONT)
	_hotkey_label.add_theme_color_override("font_color", Color(0.93, 0.88, 0.76, 1.0))
	_hotkey_label.add_theme_font_size_override("font_size", 18)
	hotkey_panel.add_child(_hotkey_label)

	_price_label = Label.new()
	_price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_price_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_price_label.add_theme_font_override("font", DISPLAY_FONT)
	_price_label.add_theme_font_size_override("font_size", 25)
	footer.add_child(_price_label)


func _make_inset_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.62, 0.51, 0.34, 0.35)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.22, 0.15, 0.08, 0.45)
	style.set_corner_radius_all(4)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style


func _make_hotkey_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.13, 0.1, 0.07, 1.0)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.7, 0.61, 0.43, 1.0)
	style.set_corner_radius_all(4)
	return style
