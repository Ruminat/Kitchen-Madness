class_name WeaponBelt
extends PanelContainer

const DS := preload("res://scripts/ui/design_system.gd")
const BODY_FONT := DS.FONT_BODY
const HudThemeScript = preload("res://scripts/ui/hud_theme.gd")

var _slot_icons: Array[TextureRect] = []
var _slot_labels: Array[Label] = []


func _init() -> void:
	name = "WeaponBelt"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(516, 78)
	add_theme_stylebox_override("panel", HudThemeScript.make_metal_panel_style(DS.GREASE))
	_build_slots()


func _build_slots() -> void:
	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", DS.SPACE_MD)
	margin.add_theme_constant_override("margin_top", DS.SPACE_SM)
	margin.add_theme_constant_override("margin_right", DS.SPACE_MD)
	margin.add_theme_constant_override("margin_bottom", DS.SPACE_SM)
	add_child(margin)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", DS.SPACE_SM)
	margin.add_child(row)

	for index in 6:
		var slot := PanelContainer.new()
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.custom_minimum_size = Vector2(72, 62)
		slot.add_theme_stylebox_override("panel", HudThemeScript.make_weapon_slot_style())
		row.add_child(slot)

		var slot_margin := MarginContainer.new()
		slot_margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot_margin.add_theme_constant_override("margin_left", DS.SPACE_XS)
		slot_margin.add_theme_constant_override("margin_top", DS.SPACE_XS)
		slot_margin.add_theme_constant_override("margin_right", DS.SPACE_XS)
		slot_margin.add_theme_constant_override("margin_bottom", DS.SPACE_XS)
		slot.add_child(slot_margin)

		var stack := VBoxContainer.new()
		stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack.add_theme_constant_override("separation", 1)
		slot_margin.add_child(stack)

		var icon := TextureRect.new()
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.custom_minimum_size = Vector2(48, 40)
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		stack.add_child(icon)
		_slot_icons.append(icon)

		var label := Label.new()
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.text = str(index + 1)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		DS.style_label(label, BODY_FONT, DS.FONT_SIZE_CAPTION, DS.INK_ON_DARK)
		stack.add_child(label)
		_slot_labels.append(label)


func apply_bottom_center_layout() -> void:
	anchor_left = 0.5
	anchor_top = 1.0
	anchor_right = 0.5
	anchor_bottom = 1.0
	offset_left = -258.0
	offset_top = -92.0
	offset_right = 258.0
	offset_bottom = -16.0


func update_loadout(weapons: Array[WeaponDefinition]) -> void:
	for index in _slot_icons.size():
		var has_weapon := index < weapons.size() and weapons[index] != null
		var icon := _slot_icons[index]
		var label := _slot_labels[index]
		icon.texture = weapons[index].icon if has_weapon else null
		icon.modulate = Color.WHITE if has_weapon else Color(0.22, 0.18, 0.14, 0.42)
		label.add_theme_color_override(
			"font_color", Color(0.98, 0.86, 0.58, 1.0) if has_weapon else Color(0.58, 0.5, 0.4, 1.0)
		)
