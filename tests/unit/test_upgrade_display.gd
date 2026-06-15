# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_format_card_text_includes_emoji_title_and_hotkey() -> void:
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = &"max_health_flat"
	upgrade.title = "Vitality"
	upgrade.description = "+15 max HP"

	var text := UpgradeDisplay.format_card_text(upgrade, "[1]")

	assert_str(text).contains("❤️")
	assert_str(text).contains("Vitality")
	assert_str(text).contains("[1]")
	assert_str(text).contains("+15 max HP")


func test_unknown_effect_uses_default_emoji() -> void:
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = &"unknown_effect"
	upgrade.title = "Mystery"
	upgrade.description = "Something weird"

	var text := UpgradeDisplay.format_card_text(upgrade, "[2]")

	assert_str(text).contains("✨")
	assert_str(text).contains("Mystery")
