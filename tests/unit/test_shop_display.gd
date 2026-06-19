# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_format_weapon_shop_offer_includes_emoji_and_cost() -> void:
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	offer.title = "Add Kitchen Knife"
	offer.description = "Fast stabs at the closest target."

	var text := ShopDisplay.format_card_text(offer, "— 12 gold  ·  [1]")

	assert_str(text).contains("🆕")
	assert_str(text).contains("Add Kitchen Knife")
	assert_str(text).contains("Fast stabs")


func test_stat_upgrade_detection() -> void:
	var stat_upgrade := UpgradeDefinition.new()
	stat_upgrade.effect = &"damage_percent"

	assert_bool(ShopManager.is_stat_upgrade(stat_upgrade)).is_true()
	assert_bool(ShopManager.is_stat_upgrade(WeaponShopOffer.new())).is_false()
