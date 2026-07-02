class_name HudActionBar
extends Node
## Owns the bottom-corner Upgrades and Shop HUD buttons and their pending badge.

signal shop_pressed
signal upgrades_pressed

const HudActionButtonScript = preload("res://scripts/ui/hud_action_button.gd")
const COLOR_UPGRADE_ACCENT := Color(0.37, 0.66, 0.21, 1.0)
const COLOR_SHOP_ACCENT := Color(0.98, 0.72, 0.13, 1.0)

var upgrades_button: HudActionButton
var shop_button: HudActionButton


func build(host: Node, insert_before: int) -> void:
	upgrades_button = HudActionButtonScript.new()
	upgrades_button.name = "UpgradesButton"
	host.add_child(upgrades_button)
	upgrades_button.configure("UPGRADES", COLOR_UPGRADE_ACCENT)
	upgrades_button.set_count(0)
	upgrades_button.pressed.connect(func() -> void: upgrades_pressed.emit())

	shop_button = HudActionButtonScript.new()
	shop_button.name = "ShopButton"
	host.add_child(shop_button)
	shop_button.configure("SHOP", COLOR_SHOP_ACCENT)
	shop_button.set_count(-1)
	shop_button.pressed.connect(func() -> void: shop_pressed.emit())

	# Keep the HUD buttons beneath the full-screen modal overlays.
	host.move_child(upgrades_button, insert_before)
	host.move_child(shop_button, insert_before)

	EventBus.upgrades_pending_changed.connect(_on_pending_changed)


func layout() -> void:
	if upgrades_button:
		upgrades_button.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
		upgrades_button.offset_left = 16.0
		upgrades_button.offset_top = -128.0
		upgrades_button.offset_right = 200.0
		upgrades_button.offset_bottom = -76.0

	if shop_button:
		shop_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
		shop_button.offset_left = -200.0
		shop_button.offset_top = -68.0
		shop_button.offset_right = -16.0
		shop_button.offset_bottom = -16.0


func _on_pending_changed(count: int) -> void:
	if upgrades_button:
		upgrades_button.set_count(count)
