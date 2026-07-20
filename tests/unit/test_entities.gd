# GdUnit generated TestSuite
extends GdUnitTestSuite

const NASTY_CAT := preload("res://resources/entities/nasty_cat.tres")
const BEAN_SHOOTER := preload("res://resources/entities/bean_shooter.tres")
const BANANA_MINE := preload("res://resources/entities/banana_mine.tres")
const NASTY_CAT_SCENE := preload("res://scenes/entities/nasty_cat.tscn")
const BEAN_SHOOTER_SCENE := preload("res://scenes/entities/bean_shooter.tscn")
const BANANA_MINE_SCENE := preload("res://scenes/entities/banana_mine.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const NEWBIE_DEF := preload("res://resources/characters/the_newbie.tres")


class MockEntityEnemy:
	extends Node2D

	var last_damage := 0

	func _init() -> void:
		add_to_group("enemies")

	func take_damage(amount: int) -> void:
		last_damage = amount


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


func before() -> void:
	get_tree().paused = false


func after_test() -> void:
	# Mock enemies are freed lazily by auto_free; drop them from the shared group now
	# so they never leak into other suites' enemy queries.
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(enemy):
			enemy.remove_from_group("enemies")


func test_entity_roster_loads_three_entities() -> void:
	assert_int(EntityRoster.load_roster().size()).is_equal(3)


func test_entities_squash_like_the_player_and_enemies() -> void:
	for scene in [NASTY_CAT_SCENE, BEAN_SHOOTER_SCENE, BANANA_MINE_SCENE]:
		var node: Node2D = auto_free(scene.instantiate()) as Node2D
		add_child(node)
		var visual := node.get_node_or_null("Visual") as Node2D
		assert_object(visual).is_not_null()
		assert_object(visual.get_node_or_null("IdleSquash")).is_not_null()


func test_entity_kinds_match_design() -> void:
	assert_int(NASTY_CAT.kind).is_equal(EntityDefinition.Kind.PET)
	assert_int(BEAN_SHOOTER.kind).is_equal(EntityDefinition.Kind.STRUCTURE)
	assert_int(BANANA_MINE.kind).is_equal(EntityDefinition.Kind.TRAP)


func test_banana_mine_per_level_scaling() -> void:
	assert_int(BANANA_MINE.scaled_damage(0)).is_equal(50)
	assert_int(BANANA_MINE.scaled_damage(6)).is_equal(80)  # +10%/level
	assert_float(BANANA_MINE.scaled_area_units(6)).is_equal_approx(64.0, 0.001)  # +10%/level
	assert_float(BANANA_MINE.scaled_rate(6)).is_equal_approx(2.0 / 2.2, 0.001)  # +20%/level
	assert_bool(BANANA_MINE.is_max_level(6)).is_true()


func test_manager_deploys_pet_node_and_blocks_upgrade() -> void:
	var container := _container()
	var manager := _manager(null, container)

	assert_bool(manager.add_entity(NASTY_CAT)).is_true()
	assert_bool(manager.has_entity("nasty_cat")).is_true()
	assert_int(container.get_child_count()).is_equal(1)
	# Pets have no upgrades (max_level 0).
	assert_bool(manager.upgrade_entity("nasty_cat")).is_false()


func test_manager_trap_upgrades_and_spawns_hazards() -> void:
	var player := Node2D.new()
	add_child(player)
	var container := _container()
	var manager := _manager(player, container)

	assert_bool(manager.add_entity(BANANA_MINE)).is_true()
	# Traps place no persistent node up front.
	assert_int(container.get_child_count()).is_equal(0)
	assert_bool(manager.upgrade_entity("banana_mine")).is_true()
	assert_int(manager.get_entity_level("banana_mine")).is_equal(1)

	manager._process(3.0)  # exceeds the 2s spawn cadence -> one hazard drops
	assert_int(container.get_child_count()).is_equal(1)


func test_nasty_cat_swipe_damages_enemies_in_area() -> void:
	var cat: Node2D = auto_free(NASTY_CAT_SCENE.instantiate()) as Node2D
	add_child(cat)
	cat.global_position = Vector2.ZERO
	cat.setup(NASTY_CAT, null)

	var enemy := _enemy(Vector2(50.0, 0.0))
	cat._try_attack()

	assert_int(enemy.last_damage).is_equal(40)


func test_bean_shooter_snipes_nearest_enemy() -> void:
	var shooter: Node2D = auto_free(BEAN_SHOOTER_SCENE.instantiate()) as Node2D
	add_child(shooter)
	shooter.global_position = Vector2.ZERO
	shooter.setup(BEAN_SHOOTER, null)

	var enemy := _enemy(Vector2(400.0, 0.0))
	shooter._process(1.0)  # cooldown 0.5 elapsed -> fires

	assert_int(enemy.last_damage).is_equal(50)


func test_banana_mine_detonates_on_nearby_enemy() -> void:
	var mine: Node2D = auto_free(BANANA_MINE_SCENE.instantiate()) as Node2D
	add_child(mine)
	mine.global_position = Vector2.ZERO
	mine.setup(50, StatUnits.area_to_pixels(40.0))

	var enemy := _enemy(Vector2(60.0, 0.0))
	mine._process(0.3)  # arms
	mine._process(0.1)  # detonates on the nearby enemy

	assert_int(enemy.last_damage).is_equal(50)


func test_entity_offer_applies_and_key_is_stable() -> void:
	var manager := _manager(null, _container())

	var deploy := EntityShopOffer.new()
	deploy.entity = BANANA_MINE
	deploy.manager = manager
	assert_bool(deploy.apply(null)).is_true()
	assert_bool(manager.has_entity("banana_mine")).is_true()
	assert_str(deploy.get_offer_key()).is_equal("entity_add:banana_mine")

	var upgrade := EntityShopOffer.new()
	upgrade.entity = BANANA_MINE
	upgrade.is_upgrade = true
	upgrade.manager = manager
	assert_bool(upgrade.apply(null)).is_true()
	assert_str(upgrade.get_offer_key()).is_equal("entity_up:banana_mine")


func test_shop_offers_include_entities() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	if not player.is_node_ready():
		await player.ready
	player.configure(NEWBIE_DEF)
	var pc := Node2D.new()
	add_child(pc)
	player.setup(Rect2(-100.0, -100.0, 200.0, 200.0), pc)

	var manager := _manager(player, _container())
	var shop: ShopManager = auto_free(ShopManager.new()) as ShopManager
	add_child(shop)
	var ui: MockShopUi = auto_free(MockShopUi.new()) as MockShopUi
	add_child(ui)
	var gold: GoldSystem = auto_free(GoldSystem.new()) as GoldSystem
	add_child(gold)
	shop.configure(player, ui, gold, func() -> void: pass, null, manager)
	shop.offer_count = 40

	var has_entity := false
	for offer in shop.generate_offers():
		if offer is EntityShopOffer:
			has_entity = true
	assert_bool(has_entity).is_true()


func _manager(player: Node2D, container: Node2D) -> EntityManager:
	var manager: EntityManager = auto_free(EntityManager.new()) as EntityManager
	add_child(manager)
	manager.configure(player, container)
	return manager


func _container() -> Node2D:
	var container: Node2D = auto_free(Node2D.new()) as Node2D
	add_child(container)
	return container


func _enemy(position: Vector2) -> MockEntityEnemy:
	var enemy: MockEntityEnemy = auto_free(MockEntityEnemy.new()) as MockEntityEnemy
	add_child(enemy)
	enemy.global_position = position
	return enemy
