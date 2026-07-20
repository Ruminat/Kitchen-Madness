# GdUnit generated TestSuite
extends GdUnitTestSuite

const ARMOR_UPGRADE := preload("res://resources/upgrades/armor.tres")


func test_format_card_text_includes_title_hotkey_and_description() -> void:
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = &"max_health_percent"
	upgrade.title = "Hearty"
	upgrade.description = "+5% max HP"

	var text := UpgradeDisplay.format_card_text(upgrade, "[1]")

	assert_str(text).contains("Hearty")
	assert_str(text).contains("[1]")
	assert_str(text).contains("+5% max HP")


func test_get_visual_returns_accent_for_known_and_unknown_effects() -> void:
	assert_bool(UpgradeDisplay.get_visual(&"armor_flat").has("accent")).is_true()
	assert_bool(UpgradeDisplay.get_visual(&"unknown_effect").has("accent")).is_true()


func test_apply_icon_sets_button_icon() -> void:
	var button: Button = auto_free(Button.new())

	UpgradeDisplay.apply_icon(button, ARMOR_UPGRADE)

	assert_object(button.icon).is_same(ARMOR_UPGRADE.icon)
	assert_bool(button.expand_icon).is_true()
