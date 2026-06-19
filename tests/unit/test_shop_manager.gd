# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const CHEF_DEF := preload("res://resources/characters/chef.tres")
const PEPPER_DEF := preload("res://resources/weapons/pepper_grinder_gun.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")


class MockShopUi:
	extends Node

	signal shop_purchase_requested(offer: Resource)
	signal shop_continue_requested

	var shown := false
	var hidden := false
	var last_gold := 0
	var offers: Array[Resource] = []

	func show_shop(shop_offers: Array[Resource], gold: int) -> void:
		shown = true
		offers = shop_offers
		last_gold = gold

	func refresh_shop(shop_offers: Array[Resource], gold: int) -> void:
		offers = shop_offers
		last_gold = gold

	func update_shop_gold(gold: int) -> void:
		last_gold = gold

	func hide_shop() -> void:
		hidden = true


func before() -> void:
	get_tree().paused = false


func after() -> void:
	get_tree().paused = false


func test_wave_complete_opens_shop_with_weapon_offers() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	gold_system.add_gold(30)
	manager.configure(player, ui, gold_system, func() -> void: pass)
	manager._current_wave = 1

	EventBus.wave_completed.emit()

	assert_bool(get_tree().paused).is_true()
	assert_bool(ui.shown).is_true()
	assert_int(ui.offers.size()).is_equal(4)
	assert_int(ui.last_gold).is_equal(30)
	for offer in ui.offers:
		assert_bool(offer is WeaponShopOffer).is_true()
		assert_bool(ShopManager.is_stat_upgrade(offer)).is_false()


func test_generated_offers_never_include_stat_upgrades() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	manager.configure(player, _create_ui(), _create_gold_system())

	var offers := manager.generate_offers()

	assert_int(offers.size()).is_equal(4)
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


func test_early_wave_offers_use_discounted_costs() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	manager.configure(player, _create_ui(), _create_gold_system())
	manager._current_wave = 1

	var offers := manager.generate_offers()
	assert_int(offers.size()).is_greater(0)
	for offer in offers:
		assert_int((offer as WeaponShopOffer).gold_cost).is_less_equal(12)


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


func test_continue_hides_shop_and_calls_callback() -> void:
	var manager := _create_manager()
	var player := await _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	var continued: Array[bool] = [false]
	manager.configure(player, ui, gold_system, func() -> void: continued[0] = true)

	EventBus.wave_completed.emit()
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


func _weapon_controller(player: CharacterBody2D) -> WeaponController:
	return player.get_node("WeaponController") as WeaponController
