# GdUnit generated TestSuite
# Regression coverage for shop robustness: stale/invalid offers must never burn
# Grease or misfire, and the loadout must stay consistent through buy/sell.
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const NEWBIE_DEF := preload("res://resources/characters/the_newbie.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")
const PAN_DEF := preload("res://resources/weapons/frying_pan.tres")
const TOMATO_DEF := preload("res://resources/weapons/rotten_tomato.tres")


class MockShopUi:
	extends Node
	signal shop_purchase_requested(offer: Resource)
	signal shop_reroll_requested
	signal shop_continue_requested
	signal shop_open_requested
	var loadout_size := -1

	func refresh_shop(_o: Array[Resource], _g: int, _s: Array[bool] = [], _r: int = 0) -> void:
		pass

	func update_weapon_loadout(weapons: Array) -> void:
		loadout_size = weapons.size()


func before() -> void:
	get_tree().paused = false


func after() -> void:
	get_tree().paused = false


func test_buying_upgrade_for_unowned_weapon_refunds_and_marks_slot_sold() -> void:
	var bits := await _shop_with_gold(30)
	var manager: ShopManager = bits[0]
	var ui: MockShopUi = bits[1]
	var gold: GoldSystem = bits[2]

	var offer := _upgrade_offer(WeaponShopOffer.OfferType.WEAPON_DAMAGE, "frying_pan", 8)
	_arm(manager, [offer])
	ui.shop_purchase_requested.emit(offer)

	# No Grease lost to an offer that cannot apply; the dead offer is greyed out.
	assert_int(gold.gold).is_equal(30)
	assert_bool(manager._is_slot_sold(0)).is_true()


func test_selling_weapon_invalidates_its_stale_upgrade_offer() -> void:
	var bits := await _shop_with_gold(30)
	var manager: ShopManager = bits[0]
	var ui: MockShopUi = bits[1]
	var gold: GoldSystem = bits[2]
	var controller: WeaponController = bits[3]
	controller.add_weapon(PAN_DEF)  # own knife (starter) + pan

	var sell := _sell_offer("frying_pan", 6)
	var sharpen := _upgrade_offer(WeaponShopOffer.OfferType.WEAPON_DAMAGE, "frying_pan", 8)
	_arm(manager, [sell, sharpen])

	ui.shop_purchase_requested.emit(sell)
	assert_bool(controller.has_weapon("frying_pan")).is_false()

	# The orphaned "sharpen pan" offer must be greyed out and non-chargeable.
	assert_bool(manager._is_slot_sold(1)).is_true()
	var after_sell := gold.gold
	ui.shop_purchase_requested.emit(sharpen)
	assert_int(gold.gold).is_equal(after_sell)


func test_reaching_weapon_cap_invalidates_other_add_offers() -> void:
	var bits := await _shop_with_gold(200)
	var manager: ShopManager = bits[0]
	var ui: MockShopUi = bits[1]
	var controller: WeaponController = bits[3]
	# Fill to five of six slots (knife starter + four), leaving one free.
	for _index in 4:
		controller.add_weapon(PAN_DEF)
	assert_int(controller.weapon_count()).is_equal(5)

	var add_tomato := _add_offer(TOMATO_DEF, 12)
	var add_pan := _add_offer(PAN_DEF, 12)  # already owned -> also invalid
	_arm(manager, [add_tomato, add_pan])
	ui.shop_purchase_requested.emit(add_tomato)  # sixth weapon caps the loadout

	assert_int(controller.weapon_count()).is_equal(6)
	assert_bool(controller.can_add_weapon()).is_false()
	assert_bool(manager._is_slot_sold(1)).is_true()


func test_buying_a_weapon_keeps_every_previously_owned_weapon() -> void:
	var bits := await _shop_with_gold(200)
	var manager: ShopManager = bits[0]
	var ui: MockShopUi = bits[1]
	var controller: WeaponController = bits[3]
	controller.add_weapon(PAN_DEF)  # knife (starter) + pan
	var before := controller.get_owned_weapon_ids()

	var offer := _add_offer(TOMATO_DEF, 10)
	_arm(manager, [offer])
	ui.shop_purchase_requested.emit(offer)

	for id in before:
		assert_bool(controller.has_weapon(id)).is_true()
	assert_bool(controller.has_weapon("rotten_tomato")).is_true()
	assert_int(controller.weapon_count()).is_equal(3)
	assert_int(ui.loadout_size).is_equal(3)


func _shop_with_gold(amount: int) -> Array:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	if not player.is_node_ready():
		await player.ready
	player.configure(NEWBIE_DEF)
	var pc := Node2D.new()
	add_child(pc)
	player.setup(Rect2(-100.0, -100.0, 200.0, 200.0), pc)

	var manager: ShopManager = auto_free(ShopManager.new()) as ShopManager
	add_child(manager)
	var ui: MockShopUi = auto_free(MockShopUi.new()) as MockShopUi
	add_child(ui)
	var gold: GoldSystem = auto_free(GoldSystem.new()) as GoldSystem
	add_child(gold)
	gold.add_gold(amount)
	manager.configure(player, ui, gold, func() -> void: pass)
	return [manager, ui, gold, player.get_node("WeaponController")]


func _arm(manager: ShopManager, offers: Array[Resource]) -> void:
	manager._current_offers = offers
	manager._shop_open = true
	manager._reset_sold_slots()


func _add_offer(weapon: WeaponDefinition, cost: int) -> WeaponShopOffer:
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	offer.weapon = weapon
	offer.gold_cost = cost
	return offer


func _upgrade_offer(offer_type: int, weapon_id: String, cost: int) -> WeaponShopOffer:
	var offer := WeaponShopOffer.new()
	offer.offer_type = offer_type
	offer.weapon_id = weapon_id
	offer.amount = 0.1
	offer.gold_cost = cost
	return offer


func _sell_offer(weapon_id: String, refund: int) -> WeaponShopOffer:
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.SELL_WEAPON
	offer.weapon_id = weapon_id
	offer.gold_cost = refund
	return offer
