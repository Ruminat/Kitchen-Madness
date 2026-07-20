class_name ShopCard
extends Button

const DS := preload("res://scripts/ui/design_system.gd")
const COLOR_INK := DS.INK
const COLOR_MUTED := DS.TEXT_MUTED
const COLOR_GREASE := DS.GREASE
const COLOR_GREASE_DIM := DS.GREASE_DIM
const COLOR_PAPER := DS.PARCHMENT
const COLOR_PAPER_DARK := DS.PARCHMENT_DARK
const DISPLAY_FONT := DS.FONT_DISPLAY
const BODY_FONT := DS.FONT_BODY

# Deliberate card geometry — sized once, reused everywhere.
const CARD_MIN_SIZE := Vector2(218, 270)
const RIBBON_HEIGHT := 24
const ICON_AREA_HEIGHT := 86
const ICON_SIZE := 72
const HOTKEY_SIZE := 30

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
	custom_minimum_size = CARD_MIN_SIZE
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
	var is_sell := ShopDisplay.is_sell_offer(offer)
	# Sells pay the player, so they are never gated by current Grease.
	var can_afford := is_sell or player_gold >= cost
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
		var offer_icon: Texture2D = offer.get("icon")
		_type_badge.text = _generic_type_label(offer)
		_type_badge.add_theme_color_override("font_color", COLOR_INK)
		_icon_rect.texture = offer_icon
		_icon_rect.modulate = Color.WHITE if offer_icon else Color(0.35, 0.31, 0.25, 0.5)
		_accent_strip.color = Color(0.35, 0.61, 0.58, 1.0)
		ShopDisplay.apply_card_style(self, offer)

	_hotkey_label.text = str(slot_index + 1)
	if is_sold:
		_price_label.text = "SOLD"
	elif is_sell:
		_price_label.text = "+%d" % cost
	else:
		_price_label.text = ShopDisplay.format_price(cost, can_afford)
	_price_label.add_theme_color_override(
		"font_color", COLOR_GREASE if can_afford and not is_sold else COLOR_GREASE_DIM
	)


func _build_layout() -> void:
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", DS.SPACE_SM)
	margin.add_theme_constant_override("margin_top", DS.SPACE_SM)
	margin.add_theme_constant_override("margin_right", DS.SPACE_SM)
	margin.add_theme_constant_override("margin_bottom", DS.SPACE_SM)
	add_child(margin)

	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", DS.SPACE_SM)
	margin.add_child(content)

	var header := VBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", DS.SPACE_XS)
	content.add_child(header)

	_accent_strip = ColorRect.new()
	_accent_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_accent_strip.custom_minimum_size = Vector2(0, RIBBON_HEIGHT)
	header.add_child(_accent_strip)

	_type_badge = Label.new()
	_type_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_type_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_type_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	DS.style_label(_type_badge, DISPLAY_FONT, DS.FONT_SIZE_LABEL, COLOR_INK)
	_type_badge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_accent_strip.add_child(_type_badge)

	_title_label = Label.new()
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	DS.style_label(_title_label, DISPLAY_FONT, DS.FONT_SIZE_SUBHEADING, COLOR_INK)
	_title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	header.add_child(_title_label)

	var icon_panel := PanelContainer.new()
	icon_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon_panel.custom_minimum_size = Vector2(0, ICON_AREA_HEIGHT)
	icon_panel.add_theme_stylebox_override("panel", _make_inset_style())
	content.add_child(icon_panel)

	_icon_rect = TextureRect.new()
	_icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_icon_rect.custom_minimum_size = Vector2(ICON_SIZE, ICON_SIZE)
	_icon_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	_icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_panel.add_child(_icon_rect)

	_desc_label = Label.new()
	_desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_desc_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.max_lines_visible = 3
	DS.style_label(_desc_label, BODY_FONT, DS.FONT_SIZE_BODY, COLOR_MUTED)
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_desc_label)

	var footer := HBoxContainer.new()
	footer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	footer.add_theme_constant_override("separation", DS.SPACE_SM)
	content.add_child(footer)

	var hotkey_panel := PanelContainer.new()
	hotkey_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hotkey_panel.custom_minimum_size = Vector2(HOTKEY_SIZE, HOTKEY_SIZE)
	hotkey_panel.add_theme_stylebox_override("panel", _make_hotkey_style())
	footer.add_child(hotkey_panel)

	_hotkey_label = Label.new()
	_hotkey_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hotkey_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_hotkey_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	DS.style_label(_hotkey_label, BODY_FONT, DS.FONT_SIZE_BODY, DS.INK_ON_DARK)
	hotkey_panel.add_child(_hotkey_label)

	_price_label = Label.new()
	_price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_price_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_price_label.add_theme_font_override("font", DISPLAY_FONT)
	_price_label.add_theme_font_size_override("font_size", DS.FONT_SIZE_SUBHEADING)
	footer.add_child(_price_label)


## Badge label for non-weapon offers (perks, skills, plain upgrades).
func _generic_type_label(offer: Resource) -> String:
	if offer is PerkShopOffer:
		return "PERK"
	if offer is SkillShopOffer:
		return "SKILL"
	if offer is EntityShopOffer:
		return _entity_label((offer as EntityShopOffer).entity)
	return "UPGRADE"


func _entity_label(entity: EntityDefinition) -> String:
	if entity == null:
		return "ALLY"
	match entity.kind:
		EntityDefinition.Kind.STRUCTURE:
			return "TOWER"
		EntityDefinition.Kind.TRAP:
			return "TRAP"
		_:
			return "PET"


func _make_inset_style() -> StyleBoxFlat:
	var bg := Color(DS.PARCHMENT_SUNK.r, DS.PARCHMENT_SUNK.g, DS.PARCHMENT_SUNK.b, 0.35)
	var style := DS.stylebox(bg, Color(0.22, 0.15, 0.08, 0.45), DS.BORDER_HAIRLINE, DS.RADIUS_SM)
	return DS.padded(style, DS.SPACE_SM, DS.SPACE_XS)


func _make_hotkey_style() -> StyleBoxFlat:
	return DS.stylebox(
		Color(0.13, 0.1, 0.07, 1.0), DS.PARCHMENT.darkened(0.1), DS.BORDER_HAIRLINE, DS.RADIUS_SM
	)
