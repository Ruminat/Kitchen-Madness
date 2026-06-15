# GdUnit generated TestSuite
extends GdUnitTestSuite


class MockPlayer:
	extends Node

	var damage_percent := 0.0

	func increase_weapon_damage_percent(percent: float) -> void:
		damage_percent += percent


class MockShopUi:
	extends Node

	signal shop_purchase_requested(upgrade: Resource)
	signal shop_continue_requested

	var shown := false
	var hidden := false
	var last_gold := 0
	var upgrades: Array[Resource] = []

	func show_shop(shop_upgrades: Array[Resource], gold: int) -> void:
		shown = true
		upgrades = shop_upgrades
		last_gold = gold

	func update_shop_gold(gold: int) -> void:
		last_gold = gold

	func hide_shop() -> void:
		hidden = true


func before() -> void:
	get_tree().paused = false


func after() -> void:
	get_tree().paused = false


func test_wave_complete_opens_shop_with_upgrades() -> void:
	var upgrade := _create_damage_upgrade(15)
	var manager := _create_manager([upgrade])
	var player := _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	gold_system.add_gold(20)
	manager.configure(player, ui, gold_system, func() -> void: pass)

	EventBus.wave_completed.emit()

	assert_bool(get_tree().paused).is_true()
	assert_bool(ui.shown).is_true()
	assert_int(ui.upgrades.size()).is_equal(1)
	assert_int(ui.last_gold).is_equal(20)


func test_purchase_spends_gold_applies_upgrade_and_updates_ui() -> void:
	var upgrade := _create_damage_upgrade(15)
	var manager := _create_manager([upgrade])
	var player := _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	gold_system.add_gold(20)
	manager.configure(player, ui, gold_system, func() -> void: pass)

	EventBus.wave_completed.emit()
	ui.shop_purchase_requested.emit(upgrade)

	assert_int(gold_system.gold).is_equal(5)
	assert_float(player.damage_percent).is_equal(0.1)
	assert_int(ui.last_gold).is_equal(5)


func test_continue_hides_shop_and_calls_callback() -> void:
	var upgrade := _create_damage_upgrade(15)
	var manager := _create_manager([upgrade])
	var player := _create_player()
	var ui := _create_ui()
	var gold_system := _create_gold_system()
	var continued: Array[bool] = [false]
	manager.configure(player, ui, gold_system, func() -> void: continued[0] = true)

	EventBus.wave_completed.emit()
	ui.shop_continue_requested.emit()

	assert_bool(ui.hidden).is_true()
	assert_bool(continued[0]).is_true()


func _create_manager(upgrades: Array[Resource]) -> ShopManager:
	var manager: ShopManager = auto_free(ShopManager.new()) as ShopManager
	manager.upgrades = upgrades
	add_child(manager)
	return manager


func _create_player() -> MockPlayer:
	var player: MockPlayer = auto_free(MockPlayer.new()) as MockPlayer
	add_child(player)
	return player


func _create_ui() -> MockShopUi:
	var ui: MockShopUi = auto_free(MockShopUi.new()) as MockShopUi
	add_child(ui)
	return ui


func _create_gold_system() -> GoldSystem:
	var gold_system: GoldSystem = auto_free(GoldSystem.new()) as GoldSystem
	add_child(gold_system)
	return gold_system


func _create_damage_upgrade(cost: int) -> UpgradeDefinition:
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = &"damage_percent"
	upgrade.amount = 0.1
	upgrade.gold_cost = cost
	return upgrade
