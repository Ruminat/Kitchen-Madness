# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const CHEF_DEF := preload("res://resources/characters/chef.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")


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
