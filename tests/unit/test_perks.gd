# GdUnit generated TestSuite
extends GdUnitTestSuite

const BRING_MORE := preload("res://resources/perks/bring_me_more.tres")
const CRAZY_ONE := preload("res://resources/perks/the_crazy_one.tres")
const GETTING_FATTY := preload("res://resources/perks/getting_fatty.tres")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const NEWBIE_DEF := preload("res://resources/characters/the_newbie.tres")


class MockShopUi:
	extends Node
	signal shop_purchase_requested(offer: Resource)
	signal shop_reroll_requested
	signal shop_continue_requested
	signal shop_open_requested

	func refresh_shop(_o: Array[Resource], _g: int, _s: Array[bool] = [], _r: int = 0) -> void:
		pass

	func update_weapon_loadout(_weapons: Array) -> void:
		pass


class MockPerkPlayer:
	extends Node

	var armor := 0
	var attack_speed_percent := 0.0
	var move_speed_percent := 0.0

	func increase_armor(amount: int) -> void:
		armor += amount

	func increase_attack_speed_percent(percent: float) -> void:
		attack_speed_percent += percent

	func increase_move_speed_percent(percent: float) -> void:
		move_speed_percent += percent


func before() -> void:
	get_tree().paused = false


func test_perk_roster_loads_three_perks() -> void:
	assert_int(PerkRoster.load_roster().size()).is_equal(3)


func test_perk_resources_deserialize_their_effects() -> void:
	assert_int(CRAZY_ONE.effects.size()).is_equal(2)
	assert_int(BRING_MORE.effects.size()).is_equal(1)
	assert_str(String(BRING_MORE.effects[0].effect)).is_equal("enemy_count_percent")


func test_the_crazy_one_applies_armor_and_attack_speed() -> void:
	var player: MockPerkPlayer = auto_free(MockPerkPlayer.new()) as MockPerkPlayer
	add_child(player)

	assert_bool(CRAZY_ONE.apply(player)).is_true()

	assert_int(player.armor).is_equal(-2)
	assert_float(player.attack_speed_percent).is_equal_approx(0.1, 0.0001)


func test_getting_fatty_applies_move_penalty_and_armor() -> void:
	var player: MockPerkPlayer = auto_free(MockPerkPlayer.new()) as MockPerkPlayer
	add_child(player)

	GETTING_FATTY.apply(player)

	assert_int(player.armor).is_equal(1)
	assert_float(player.move_speed_percent).is_equal_approx(-0.03, 0.0001)


func test_bring_me_more_broadcasts_enemy_count_percent() -> void:
	var received: Array[float] = []
	var handler := func(percent: float) -> void: received.append(percent)
	EventBus.enemy_count_percent_added.connect(handler)

	BRING_MORE.apply(null)

	EventBus.enemy_count_percent_added.disconnect(handler)
	assert_int(received.size()).is_equal(1)
	assert_float(received[0]).is_equal_approx(0.05, 0.0001)


func test_perk_offer_key_is_stable_and_unique() -> void:
	var offer := PerkShopOffer.new()
	offer.perk = BRING_MORE
	assert_str(offer.get_offer_key()).is_equal("perk:bring_me_more")


func test_spawner_grows_alive_cap_with_count_multiplier() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	add_child(spawner)
	if not spawner.is_node_ready():
		await spawner.ready

	var level := LevelDefinition.new()
	level.max_enemies_start = 100
	level.max_enemies_end = 100
	spawner.level_definition = level

	var before := spawner._max_alive_enemies()
	EventBus.enemy_count_percent_added.emit(0.05)

	assert_float(spawner.count_multiplier).is_equal_approx(1.05, 0.0001)
	assert_int(spawner._max_alive_enemies()).is_greater(before)


func test_shop_offers_can_include_perks() -> void:
	var bits := await _shop_with_gold(50)
	var manager: ShopManager = bits[0]
	manager.offer_count = 30

	var has_perk := false
	for offer in manager.generate_offers():
		if offer is PerkShopOffer:
			has_perk = true
	assert_bool(has_perk).is_true()


func test_buying_a_perk_spends_grease_applies_and_marks_sold() -> void:
	var bits := await _shop_with_gold(50)
	var manager: ShopManager = bits[0]
	var ui: MockShopUi = bits[1]
	var gold: GoldSystem = bits[2]
	var player: CharacterBody2D = bits[3]

	var offer := PerkShopOffer.new()
	offer.perk = GETTING_FATTY
	offer.gold_cost = 14
	manager._current_offers = [offer]
	manager._shop_open = true
	manager._reset_sold_slots()

	ui.shop_purchase_requested.emit(offer)

	assert_int(gold.gold).is_equal(36)
	assert_bool(manager._is_slot_sold(0)).is_true()
	# Getting Fatty grants +1 armor on the real player.
	assert_int(player.health_component.armor).is_equal(1)


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
	return [manager, ui, gold, player]
