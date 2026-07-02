# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const CHEF_DEF := preload("res://resources/characters/chef.tres")
const PEPPER_DEF := preload("res://resources/weapons/pepper_grinder_gun.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")


class MockShopUi:
	extends Node

	signal shop_purchase_requested(offer: Resource)
	signal shop_reroll_requested
	signal shop_continue_requested
	signal shop_open_requested

	var shown := false
	var hidden := false
	var last_gold := 0
	var last_sold_slots: Array[bool] = []
	var last_reroll_cost := 0
	var offers: Array[Resource] = []

	func show_shop(
		shop_offers: Array[Resource], gold: int, sold_slots: Array[bool] = [], reroll_cost: int = 0
	) -> void:
		shown = true
		offers = shop_offers
		last_gold = gold
		last_sold_slots = sold_slots
		last_reroll_cost = reroll_cost

	func refresh_shop(
		shop_offers: Array[Resource], gold: int, sold_slots: Array[bool] = [], reroll_cost: int = 0
	) -> void:
		offers = shop_offers
		last_gold = gold
		last_sold_slots = sold_slots
		last_reroll_cost = reroll_cost

	func update_shop_gold(gold: int) -> void:
		last_gold = gold

	func hide_shop() -> void:
		hidden = true


func before() -> void:
	get_tree().paused = false


func after() -> void:
	get_tree().paused = false


func test_open_shop_shows_weapon_offers_and_pauses() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	gold_system.add_gold(30)
	manager.configure(player, ui, gold_system, func() -> void: pass)

	manager.open_shop()

	assert_bool(get_tree().paused).is_true()
	assert_bool(ui.shown).is_true()
	assert_int(ui.offers.size()).is_equal(5)
	assert_int(ui.last_gold).is_equal(30)
	for offer in ui.offers:
		assert_bool(offer is WeaponShopOffer).is_true()
		assert_bool(ShopManager.is_stat_upgrade(offer)).is_false()


func test_level_completed_does_not_auto_open_shop() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	manager.configure(player, ui, _create_gold_system(), func() -> void: pass)

	EventBus.level_completed.emit()

	assert_bool(ui.shown).is_false()
	assert_bool(manager._shop_open).is_false()


func test_ui_open_signal_opens_shop() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	manager.configure(player, ui, _create_gold_system(), func() -> void: pass)

	ui.shop_open_requested.emit()

	assert_bool(manager._shop_open).is_true()
	assert_bool(ui.shown).is_true()
	assert_bool(get_tree().paused).is_true()


func test_level_time_signal_updates_price_scaling() -> void:
	var manager := _create_manager()

	EventBus.level_time_changed.emit(120.0, 480.0)

	assert_float(manager._elapsed_level_seconds).is_equal(120.0)


func test_scaled_cost_grows_per_elapsed_minute() -> void:
	assert_int(ShopManager.scaled_cost_for_time(12, 0.0)).is_equal(12)
	assert_int(ShopManager.scaled_cost_for_time(12, 60.0)).is_equal(14)
	assert_int(ShopManager.scaled_cost_for_time(8, 180.0)).is_equal(12)


func test_starting_weapon_seeded_with_base_price() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	manager.configure(player, _create_ui(), _create_gold_system())

	var owned := _weapon_controller(player).get_owned_weapon_ids()
	assert_int(owned.size()).is_equal(1)
	assert_int(manager._sell_price(owned[0])).is_equal(6)


func test_sell_price_is_half_recorded_purchase_price() -> void:
	var manager := _create_manager()
	manager._weapon_purchase_price["kitchen_knife"] = 20
	assert_int(manager._sell_price("kitchen_knife")).is_equal(10)


func test_no_sell_offers_with_single_weapon() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	manager.configure(player, _create_ui(), _create_gold_system())
	manager.offer_count = 30

	for offer in manager.generate_offers():
		assert_bool(ShopDisplay.is_sell_offer(offer)).is_false()


func test_sell_offers_appear_with_multiple_weapons() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	manager.configure(player, _create_ui(), _create_gold_system())
	_weapon_controller(player).add_weapon(KNIFE_DEF)
	manager.offer_count = 30

	var sell_ids: Array[String] = []
	for offer in manager.generate_offers():
		if ShopDisplay.is_sell_offer(offer):
			sell_ids.append((offer as WeaponShopOffer).weapon_id)
	assert_bool(sell_ids.has("kitchen_knife")).is_true()


func test_selling_weapon_refunds_grease_and_removes_it() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	gold_system.add_gold(30)
	manager.configure(player, ui, gold_system, func() -> void: pass)
	_weapon_controller(player).add_weapon(KNIFE_DEF)
	manager._weapon_purchase_price["kitchen_knife"] = 12

	var sell_offer := _create_sell_offer("kitchen_knife", 6)
	manager._current_offers = [sell_offer]
	manager._reset_sold_slots()
	manager._shop_open = true

	ui.shop_purchase_requested.emit(sell_offer)

	assert_int(gold_system.gold).is_equal(36)
	assert_bool(_weapon_controller(player).has_weapon("kitchen_knife")).is_false()
	assert_bool(ui.last_sold_slots[0]).is_true()


func test_cannot_sell_last_weapon() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	manager.configure(player, ui, gold_system, func() -> void: pass)

	var last_id := _weapon_controller(player).get_owned_weapon_ids()[0]
	var sell_offer := _create_sell_offer(last_id, 6)
	manager._current_offers = [sell_offer]
	manager._reset_sold_slots()
	manager._shop_open = true

	ui.shop_purchase_requested.emit(sell_offer)

	assert_int(gold_system.gold).is_equal(0)
	assert_bool(_weapon_controller(player).has_weapon(last_id)).is_true()
	assert_int(_weapon_controller(player).weapon_count()).is_equal(1)


func test_generated_offers_never_include_stat_upgrades() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	manager.configure(player, _create_ui(), _create_gold_system())

	var offers := manager.generate_offers()

	assert_int(offers.size()).is_less_equal(5)
	for offer in offers:
		assert_bool(offer is WeaponShopOffer).is_true()
		assert_bool(ShopManager.is_stat_upgrade(offer)).is_false()


func test_shop_does_not_offer_owned_weapons_for_add() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	manager.configure(player, _create_ui(), _create_gold_system())

	for offer in manager.generate_offers():
		var shop_offer := offer as WeaponShopOffer
		if shop_offer.offer_type != WeaponShopOffer.OfferType.ADD_WEAPON:
			continue
		assert_bool(_weapon_controller(player).has_weapon(shop_offer.weapon.id)).is_false()


func test_purchase_add_weapon_spends_gold_and_equips_weapon() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	gold_system.add_gold(30)
	manager.configure(player, ui, gold_system, func() -> void: pass)

	var offer := _create_add_weapon_offer(KNIFE_DEF, 9)
	manager._current_offers = [offer]
	manager._shop_open = true

	ui.shop_purchase_requested.emit(offer)

	assert_int(gold_system.gold).is_equal(21)
	assert_bool(_weapon_controller(player).has_weapon("kitchen_knife")).is_true()


func test_purchase_weapon_damage_upgrade_targets_one_weapon() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	gold_system.add_gold(20)
	manager.configure(player, ui, gold_system, func() -> void: pass)
	_weapon_controller(player).add_weapon(KNIFE_DEF)

	var weapon: BaseWeapon = _weapon_controller(player).get_child(1) as BaseWeapon
	var before := weapon.get_damage()

	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.WEAPON_DAMAGE
	offer.weapon_id = "kitchen_knife"
	offer.amount = 0.1
	offer.gold_cost = 8
	manager._current_offers = [offer]
	manager._shop_open = true

	ui.shop_purchase_requested.emit(offer)

	assert_int(gold_system.gold).is_equal(12)
	assert_int(weapon.get_damage()).is_greater(before)


func test_level_start_shop_costs_use_base_prices() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	manager.configure(player, _create_ui(), _create_gold_system())
	manager._elapsed_level_seconds = 0.0

	var offers := manager.generate_offers()
	assert_int(offers.size()).is_greater(0)
	for offer in offers:
		var shop_offer := offer as WeaponShopOffer
		if shop_offer.offer_type == WeaponShopOffer.OfferType.ADD_WEAPON:
			assert_int(shop_offer.gold_cost).is_equal(12)
			return
	assert_bool(false).is_true()


func test_late_level_shop_costs_scale_up() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	manager.configure(player, _create_ui(), _create_gold_system())
	manager._elapsed_level_seconds = 180.0
	# Include every candidate so the (shuffled) weapon-damage offer is always present.
	manager.offer_count = 20

	var offers := manager.generate_offers()
	assert_int(offers.size()).is_greater(0)
	for offer in offers:
		var shop_offer := offer as WeaponShopOffer
		if shop_offer.offer_type == WeaponShopOffer.OfferType.WEAPON_DAMAGE:
			assert_int(shop_offer.gold_cost).is_equal(12)
			return
	assert_bool(false).is_true()


func test_generate_offers_skips_duplicate_offer_keys() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	manager.configure(player, _create_ui(), _create_gold_system())

	var offers := manager.generate_offers()
	var keys: Dictionary = {}
	for offer in offers:
		var key := (offer as WeaponShopOffer).get_offer_key()
		assert_bool(keys.has(key)).is_false()
		keys[key] = true


func test_purchase_marks_slot_sold_without_removing_offer() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	gold_system.add_gold(30)
	manager.configure(player, ui, gold_system, func() -> void: pass)

	var offer := _create_add_weapon_offer(KNIFE_DEF, 9)
	manager._current_offers = [offer]
	manager._reset_sold_slots()
	manager._shop_open = true

	ui.shop_purchase_requested.emit(offer)

	assert_int(ui.offers.size()).is_equal(1)
	assert_bool(ui.last_sold_slots[0]).is_true()
	assert_object(ui.offers[0]).is_same(offer)


func test_reroll_spends_grease_and_regenerates_offers() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	gold_system.add_gold(30)
	manager.configure(player, ui, gold_system, func() -> void: pass)
	manager._shop_open = true
	manager._current_offers = manager.generate_offers()
	manager._reset_sold_slots()

	ui.shop_reroll_requested.emit()

	assert_int(gold_system.gold).is_equal(24)
	assert_int(ui.last_reroll_cost).is_equal(10)
	assert_int(ui.offers.size()).is_equal(5)


func test_reroll_cost_increases_each_time() -> void:
	var manager := _create_manager()
	manager._reroll_count = 0
	assert_int(manager._current_reroll_cost()).is_equal(6)
	manager._reroll_count = 2
	assert_int(manager._current_reroll_cost()).is_equal(14)


func test_continue_hides_shop_and_calls_callback() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	var continued: Array[bool] = [false]
	manager.configure(player, ui, gold_system, func() -> void: continued[0] = true)

	manager.open_shop()
	ui.shop_continue_requested.emit()

	assert_bool(ui.hidden).is_true()
	assert_bool(continued[0]).is_true()


func _create_manager() -> ShopManager:
	var manager: ShopManager = auto_free(ShopManager.new()) as ShopManager
	add_child(manager)
	return manager


func _create_player() -> CharacterBody2D:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	if not player.is_node_ready():
		await player.ready
	player.configure(CHEF_DEF)
	var projectile_container := Node2D.new()
	add_child(projectile_container)
	player.setup(Rect2(-100.0, -100.0, 200.0, 200.0), projectile_container)
	return player


func _create_ui() -> MockShopUi:
	var ui: MockShopUi = auto_free(MockShopUi.new()) as MockShopUi
	add_child(ui)
	return ui


func _create_gold_system() -> GoldSystem:
	var gold_system: GoldSystem = auto_free(GoldSystem.new()) as GoldSystem
	add_child(gold_system)
	return gold_system


func _create_add_weapon_offer(weapon: WeaponDefinition, cost: int) -> WeaponShopOffer:
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	offer.weapon = weapon
	offer.title = "Add %s" % weapon.display_name
	offer.description = weapon.description
	offer.gold_cost = cost
	return offer


func _create_sell_offer(weapon_id: String, refund: int) -> WeaponShopOffer:
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.SELL_WEAPON
	offer.weapon_id = weapon_id
	offer.title = "Sell %s" % weapon_id
	offer.gold_cost = refund
	return offer


func _weapon_controller(player: CharacterBody2D) -> WeaponController:
	return player.get_node("WeaponController") as WeaponController
