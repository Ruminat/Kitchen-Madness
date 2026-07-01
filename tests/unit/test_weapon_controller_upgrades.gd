# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const CHEF_DEF := preload("res://resources/characters/chef.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")


class MockEnemy:
	extends Node2D

	var health_component := HealthComponent.new()
	var _alive := true

	func _init(alive: bool = true) -> void:
		_alive = alive
		add_child(health_component)
		health_component.name = "HealthComponent"
		health_component.max_health = 10

	func _ready() -> void:
		# HealthComponent._ready() resets current_health to max_health, so apply the
		# desired (possibly dead) state after it has entered the tree.
		health_component.current_health = 10 if _alive else 0


func test_get_owned_weapon_ids_returns_starting_weapon() -> void:
	var controller := await _create_controller()
	assert_int(controller.get_owned_weapon_ids().size()).is_equal(1)
	assert_str(controller.get_owned_weapon_ids()[0]).is_equal("pepper_grinder_gun")


func test_add_weapon_respects_max_weapons() -> void:
	var controller := await _create_controller()

	for index in WeaponController.MAX_WEAPONS - 1:
		controller.add_weapon(KNIFE_DEF)

	assert_bool(controller.can_add_weapon()).is_false()
	assert_int(controller.get_owned_weapon_ids().size()).is_equal(WeaponController.MAX_WEAPONS)


func test_upgrade_weapon_damage_only_affects_target_weapon() -> void:
	var controller := await _create_controller()
	controller.add_weapon(KNIFE_DEF)

	var starter: BaseWeapon = controller.get_child(0) as BaseWeapon
	var knife: BaseWeapon = controller.get_child(1) as BaseWeapon
	var starter_before := starter.get_damage()
	var knife_before := knife.get_damage()

	controller.upgrade_weapon_damage("kitchen_knife", 0.5)

	assert_int(starter.get_damage()).is_equal(starter_before)
	assert_int(knife.get_damage()).is_greater(knife_before)


func test_weapons_create_visible_orbit_sprite() -> void:
	var controller := await _create_controller()
	var weapon := controller.get_child(0) as BaseWeapon

	assert_object(weapon.get_node_or_null("WeaponSprite")).is_not_null()


func test_controller_offsets_orbiting_weapons() -> void:
	var controller := await _create_controller()
	var weapon := controller.get_child(0) as BaseWeapon

	controller._process(0.1)

	assert_vector(weapon.position).is_not_equal(Vector2.ZERO)


func test_find_nearest_enemy_ignores_dead_enemies() -> void:
	var controller := await _create_controller()
	var weapon := controller.get_child(0) as BaseWeapon
	var dead_near := MockEnemy.new(false)
	var alive_far := MockEnemy.new(true)
	dead_near.add_to_group("enemies")
	alive_far.add_to_group("enemies")
	dead_near.global_position = weapon.global_position + Vector2.RIGHT * 5.0
	alive_far.global_position = weapon.global_position + Vector2.RIGHT * 30.0
	add_child(dead_near)
	add_child(alive_far)

	assert_object(weapon.find_nearest_enemy()).is_same(alive_far)


func _create_controller() -> WeaponController:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	var projectile_container := Node2D.new()
	add_child(player)
	add_child(projectile_container)
	if not player.is_node_ready():
		await player.ready
	player.configure(CHEF_DEF)
	player.setup(Rect2(-100.0, -100.0, 200.0, 200.0), projectile_container)
	return player.get_node("WeaponController") as WeaponController
