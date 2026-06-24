# GdUnit generated TestSuite
extends GdUnitTestSuite

const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")
const ShopCard = preload("res://scripts/ui/shop_card.gd")


func test_format_weapon_shop_offer_includes_emoji_and_cost() -> void:
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	offer.title = "Add Kitchen Knife"
	offer.description = "Fast stabs at the closest target."

	var text := ShopDisplay.format_card_text(offer, "— 12 Grease  ·  [1]")

	assert_str(text).contains("🆕")
	assert_str(text).contains("Add Kitchen Knife")
	assert_str(text).contains("Fast stabs")


func test_stat_upgrade_detection() -> void:
	var stat_upgrade := UpgradeDefinition.new()
	stat_upgrade.effect = &"damage_percent"

	assert_bool(ShopManager.is_stat_upgrade(stat_upgrade)).is_true()
	assert_bool(ShopManager.is_stat_upgrade(WeaponShopOffer.new())).is_false()


func test_get_type_label_for_offer_types() -> void:
	var add_offer := WeaponShopOffer.new()
	add_offer.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	assert_str(ShopDisplay.get_type_label(add_offer)).is_equal("NEW")

	var damage_offer := WeaponShopOffer.new()
	damage_offer.offer_type = WeaponShopOffer.OfferType.WEAPON_DAMAGE
	assert_str(ShopDisplay.get_type_label(damage_offer)).is_equal("SHARPEN")


func test_get_weapon_icon_from_add_offer() -> void:
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	offer.weapon = KNIFE_DEF

	assert_object(ShopDisplay.get_weapon_icon(offer)).is_not_null()


func test_get_weapon_icon_from_upgrade_offer() -> void:
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.WEAPON_DAMAGE
	offer.weapon_id = "kitchen_knife"

	assert_object(ShopDisplay.get_weapon_icon(offer)).is_not_null()


func test_format_price_uses_grease_label() -> void:
	assert_str(ShopDisplay.format_price(12, true)).is_equal("Grease 12")
	assert_str(ShopDisplay.format_price(8, false)).is_equal("Grease 8")


func test_shop_card_configures_title_price_and_hotkey() -> void:
	var card: ShopCard = auto_free(ShopCard.new()) as ShopCard
	add_child(card)
	await card.ready

	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	offer.weapon = KNIFE_DEF
	offer.title = "Add Kitchen Knife"
	offer.description = "Fast close-range stabs in a tight forward arc."
	offer.gold_cost = 9

	card.configure(offer, 0, 20)

	assert_bool(card.disabled).is_false()
	assert_str(card.tooltip_text).contains("Fast close-range stabs")


func test_shop_card_shows_sold_state() -> void:
	var card: ShopCard = auto_free(ShopCard.new()) as ShopCard
	add_child(card)
	await card.ready

	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	offer.weapon = KNIFE_DEF
	offer.title = "Add Kitchen Knife"
	offer.description = "Fast close-range stabs in a tight forward arc."
	offer.gold_cost = 9

	card.configure(offer, 0, 20, true)

	assert_bool(card.disabled).is_true()
	assert_str(card.text).is_empty()
