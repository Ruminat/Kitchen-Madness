class_name ShopCard
extends Button

const COLOR_TEXT := Color(0.92, 0.94, 0.97, 1.0)
const COLOR_MUTED := Color(0.62, 0.66, 0.74, 1.0)
const COLOR_GREASE := Color(0.76, 0.84, 0.34, 1.0)
const COLOR_GREASE_DIM := Color(0.44, 0.48, 0.26, 1.0)

var _icon_rect: TextureRect
var _type_badge: Label
var _title_label: Label
var _desc_label: Label
var _hotkey_label: Label
var _price_label: Label
var _offer: Resource


func _ready() -> void:
	text = ""
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	focus_mode = Control.FOCUS_ALL
	custom_minimum_size = Vector2(244, 126)
	_build_layout()


func configure(offer: Resource, slot_index: int, player_gold: int, is_sold: bool = false) -> void:
	_offer = offer
	if offer == null:
		visible = true
		disabled = true
		tooltip_text = ""
		modulate = Color(0.62, 0.62, 0.66, 1.0)
		_title_label.text = "Empty Slot"
		_desc_label.text = "No offer available."
		_type_badge.text = "-"
		_icon_rect.texture = null
		_hotkey_label.text = "[%d]" % (slot_index + 1)
		_hotkey_label.visible = true
		_price_label.text = "-"
		return

	var cost := int(offer.get("gold_cost"))
	var can_afford := player_gold >= cost
	disabled = is_sold or not can_afford
	if is_sold:
		modulate = Color(0.68, 0.7, 0.72, 1.0)
	elif can_afford:
		modulate = Color.WHITE
	else:
		modulate = Color(0.72, 0.72, 0.76, 1.0)
	tooltip_text = str(offer.get("description"))

	if offer is WeaponShopOffer:
		var shop_offer := offer as WeaponShopOffer
		var visual := ShopDisplay.get_visual(shop_offer)
		_title_label.text = shop_offer.title
		_desc_label.text = shop_offer.description
		_type_badge.text = ShopDisplay.get_type_label(shop_offer)
		_type_badge.add_theme_color_override("font_color", visual.accent)
		_icon_rect.texture = ShopDisplay.get_weapon_icon(shop_offer)
		_icon_rect.modulate = Color.WHITE if _icon_rect.texture else Color(0.35, 0.37, 0.42, 0.5)
		ShopDisplay.apply_card_style(self, offer)
	else:
		_title_label.text = str(offer.get("title"))
		_desc_label.text = str(offer.get("description"))
		_type_badge.text = "UPGRADE"
		_icon_rect.texture = null
		ShopDisplay.apply_card_style(self, offer)

	_hotkey_label.text = "[%d]" % (slot_index + 1)
	_hotkey_label.visible = true
	_price_label.text = "SOLD" if is_sold else ShopDisplay.format_price(cost, can_afford)
	_price_label.add_theme_color_override(
		"font_color", COLOR_GREASE if can_afford and not is_sold else COLOR_GREASE_DIM
	)


func _build_layout() -> void:
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 4)
	margin.add_theme_constant_override("margin_top", 4)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 4)
	add_child(margin)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 14)
	margin.add_child(row)

	var icon_column := VBoxContainer.new()
	icon_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_column.custom_minimum_size = Vector2(56, 0)
	icon_column.add_theme_constant_override("separation", 4)
	row.add_child(icon_column)

	_icon_rect = TextureRect.new()
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon_rect.custom_minimum_size = Vector2(48, 48)
	_icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_column.add_child(_icon_rect)

	_type_badge = Label.new()
	_type_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_type_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_type_badge.add_theme_font_size_override("font_size", 11)
	icon_column.add_child(_type_badge)

	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 4)
	row.add_child(content)

	var title_row := HBoxContainer.new()
	title_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_row.add_theme_constant_override("separation", 8)
	content.add_child(title_row)

	_title_label = Label.new()
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.add_theme_color_override("font_color", COLOR_TEXT)
	_title_label.add_theme_font_size_override("font_size", 17)
	_title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title_row.add_child(_title_label)

	_hotkey_label = Label.new()
	_hotkey_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hotkey_label.add_theme_color_override("font_color", COLOR_GREASE)
	_hotkey_label.add_theme_font_size_override("font_size", 15)
	title_row.add_child(_hotkey_label)

	_desc_label = Label.new()
	_desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.max_lines_visible = 2
	_desc_label.add_theme_color_override("font_color", COLOR_MUTED)
	_desc_label.add_theme_font_size_override("font_size", 13)
	content.add_child(_desc_label)

	var price_column := VBoxContainer.new()
	price_column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	price_column.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(price_column)

	_price_label = Label.new()
	_price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_price_label.add_theme_font_size_override("font_size", 18)
	price_column.add_child(_price_label)
