# GdUnit generated TestSuite
extends GdUnitTestSuite

const HEAVY_FRIDGE := preload("res://resources/skills/heavy_fridge.tres")
const WRAITH := preload("res://resources/skills/wraith_of_cooking_god.tres")
const GARLIC := preload("res://resources/skills/garlic_stench.tres")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const NEWBIE_DEF := preload("res://resources/characters/the_newbie.tres")


class MockSkillEnemy:
	extends Node2D

	var last_damage := 0
	var hit_count := 0

	func _init() -> void:
		add_to_group("enemies")

	func take_damage(amount: int) -> void:
		last_damage = amount
		hit_count += 1


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


func test_skill_roster_loads_three_skills() -> void:
	assert_int(SkillRoster.load_roster().size()).is_equal(3)


func test_per_level_scaling_matches_design() -> void:
	# Heavy Fridge: 60 dmg / 60 area, +10% dmg +5% area per level, max 6.
	assert_int(HEAVY_FRIDGE.scaled_damage(0)).is_equal(60)
	assert_int(HEAVY_FRIDGE.scaled_damage(6)).is_equal(96)
	assert_float(HEAVY_FRIDGE.scaled_area_units(6)).is_equal_approx(78.0, 0.001)
	assert_bool(HEAVY_FRIDGE.is_max_level(6)).is_true()
	assert_bool(HEAVY_FRIDGE.is_max_level(5)).is_false()

	# Wraith: 300 dmg, +1 hit per level, max 5.
	assert_int(WRAITH.scaled_hits(0)).is_equal(3)
	assert_int(WRAITH.scaled_hits(5)).is_equal(8)
	assert_int(WRAITH.scaled_damage(5)).is_equal(450)

	# Garlic: 0.2s ticks, +10% faster per level, +15% area, max 6.
	assert_float(GARLIC.scaled_cadence(0)).is_equal_approx(0.2, 0.0001)
	assert_float(GARLIC.scaled_cadence(6)).is_equal_approx(0.125, 0.0001)
	assert_float(GARLIC.scaled_area_units(6)).is_equal_approx(57.0, 0.001)


func test_runner_add_upgrade_and_max() -> void:
	var runner := _runner()

	assert_bool(runner.add_skill(HEAVY_FRIDGE)).is_true()
	assert_bool(runner.has_skill("heavy_fridge")).is_true()
	assert_bool(runner.add_skill(HEAVY_FRIDGE)).is_false()
	assert_int(runner.get_skill_level("heavy_fridge")).is_equal(0)

	for _i in HEAVY_FRIDGE.max_level:
		assert_bool(runner.upgrade_skill("heavy_fridge")).is_true()
	assert_int(runner.get_skill_level("heavy_fridge")).is_equal(HEAVY_FRIDGE.max_level)
	assert_bool(runner.is_maxed("heavy_fridge")).is_true()
	assert_bool(runner.upgrade_skill("heavy_fridge")).is_false()


func test_falling_skill_damages_enemies_around_a_target() -> void:
	var runner := _runner()
	var enemy := _enemy(Vector2(500.0, 500.0))

	runner._execute(HEAVY_FRIDGE, 0)

	assert_int(enemy.last_damage).is_equal(60)


func test_aura_skill_only_damages_enemies_within_range_of_player() -> void:
	var runner := _runner()
	var player := Node2D.new()
	add_child(player)
	player.global_position = Vector2.ZERO
	runner.configure(player)

	var near := _enemy(Vector2(50.0, 0.0))
	var far := _enemy(Vector2(2000.0, 0.0))

	runner._execute(GARLIC, 0)

	assert_int(near.last_damage).is_equal(10)
	assert_int(far.last_damage).is_equal(0)


func test_lightning_strikes_up_to_its_hit_count() -> void:
	var runner := _runner()
	var enemies: Array = [
		_enemy(Vector2(0.0, 0.0)),
		_enemy(Vector2(600.0, 0.0)),
		_enemy(Vector2(0.0, 600.0)),
		_enemy(Vector2(600.0, 600.0)),
	]

	runner._execute(WRAITH, 0)  # base hits = 3

	var struck := 0
	for enemy in enemies:
		if (enemy as MockSkillEnemy).last_damage > 0:
			struck += 1
	assert_int(struck).is_equal(3)


func test_skill_offer_applies_and_upgrades_through_runner() -> void:
	var runner := _runner()

	var learn := SkillShopOffer.new()
	learn.skill = HEAVY_FRIDGE
	learn.runner = runner
	assert_bool(learn.apply(null)).is_true()
	assert_bool(runner.has_skill("heavy_fridge")).is_true()

	var upgrade := SkillShopOffer.new()
	upgrade.skill = HEAVY_FRIDGE
	upgrade.is_upgrade = true
	upgrade.runner = runner
	assert_bool(upgrade.apply(null)).is_true()
	assert_int(runner.get_skill_level("heavy_fridge")).is_equal(1)

	assert_str(learn.get_offer_key()).is_equal("skill_add:heavy_fridge")
	assert_str(upgrade.get_offer_key()).is_equal("skill_up:heavy_fridge")


func test_shop_offers_learn_then_upgrade_skills() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	if not player.is_node_ready():
		await player.ready
	player.configure(NEWBIE_DEF)
	var pc := Node2D.new()
	add_child(pc)
	player.setup(Rect2(-100.0, -100.0, 200.0, 200.0), pc)

	var runner := _runner()
	var manager: ShopManager = auto_free(ShopManager.new()) as ShopManager
	add_child(manager)
	var ui: MockShopUi = auto_free(MockShopUi.new()) as MockShopUi
	add_child(ui)
	var gold: GoldSystem = auto_free(GoldSystem.new()) as GoldSystem
	add_child(gold)
	manager.configure(player, ui, gold, func() -> void: pass, runner)
	manager.offer_count = 40

	assert_bool(_has_skill_offer(manager.generate_offers(), false)).is_true()

	runner.add_skill(HEAVY_FRIDGE)
	assert_bool(_has_skill_offer(manager.generate_offers(), true)).is_true()


func _has_skill_offer(offers: Array[Resource], want_upgrade: bool) -> bool:
	for offer in offers:
		if offer is SkillShopOffer and (offer as SkillShopOffer).is_upgrade == want_upgrade:
			return true
	return false


func _runner() -> SkillRunner:
	var runner: SkillRunner = auto_free(SkillRunner.new()) as SkillRunner
	add_child(runner)
	return runner


func _enemy(position: Vector2) -> MockSkillEnemy:
	var enemy: MockSkillEnemy = auto_free(MockSkillEnemy.new()) as MockSkillEnemy
	add_child(enemy)
	enemy.global_position = position
	return enemy
