# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const CHEF_DEF := preload("res://resources/characters/chef.tres")
const GOBLIN_DEF := preload("res://resources/characters/goblin.tres")
const ONION_DEF := preload("res://resources/characters/onion.tres")
const PEPPER_DEF := preload("res://resources/weapons/pepper_grinder_gun.tres")
const SOUP_DEF := preload("res://resources/weapons/boiling_soup_splash.tres")
const ONION_RING_DEF := preload("res://resources/weapons/onion_ring_blade.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")
const PAN_DEF := preload("res://resources/weapons/frying_pan.tres")
const GARLIC_DEF := preload("res://resources/weapons/garlic_bomb.tres")
const LADLE_DEF := preload("res://resources/weapons/ladle_boomerang.tres")
const TOASTER_DEF := preload("res://resources/weapons/toaster_turret.tres")


func test_character_roster_loads_nine_characters() -> void:
	var roster := CharacterRoster.load_roster()
	assert_int(roster.size()).is_equal(9)


func test_default_character_is_chef() -> void:
	var default_character := CharacterRoster.get_default()
	assert_object(default_character).is_same(CHEF_DEF)


func test_configure_applies_sprite_stats_and_starting_weapon() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	await _wait_ready(player)

	player.configure(GOBLIN_DEF)

	var sprite: Sprite2D = player.get_node("Visual/Sprite") as Sprite2D
	assert_object(sprite.texture).is_same(GOBLIN_DEF.sprite)
	assert_float(player.move_speed).is_equal(GOBLIN_DEF.move_speed)
	assert_int(player.get_luck()).is_equal(GOBLIN_DEF.luck)
	assert_int(player.get_max_health()).is_equal(GOBLIN_DEF.max_health)
	assert_int(player.get_health()).is_equal(GOBLIN_DEF.max_health)

	var weapon_controller: WeaponController = (
		player.get_node("WeaponController") as WeaponController
	)
	assert_object(weapon_controller.starting_weapon).is_same(SOUP_DEF)
	assert_int(weapon_controller.extra_weapons.size()).is_equal(0)


func test_setup_adds_only_starting_weapon() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	var projectile_container := Node2D.new()
	add_child(player)
	add_child(projectile_container)
	await _wait_ready(player)

	player.configure(CHEF_DEF)
	player.setup(Rect2(-100.0, -100.0, 200.0, 200.0), projectile_container)

	var weapon_controller: WeaponController = (
		player.get_node("WeaponController") as WeaponController
	)
	assert_int(weapon_controller.get_child_count()).is_equal(1)
	var weapon: BaseWeapon = weapon_controller.get_child(0) as BaseWeapon
	assert_str(weapon.definition.id).is_equal(PEPPER_DEF.id)


func test_each_character_resource_has_required_fields() -> void:
	for character in CharacterRoster.load_roster():
		assert_str(character.id).is_not_empty()
		assert_str(character.display_name).is_not_empty()
		assert_str(character.description).is_not_empty()
		assert_object(character.sprite).is_not_null()
		assert_int(character.max_health).is_greater(0)
		assert_float(character.move_speed).is_greater(0.0)
		assert_object(character.starting_weapon).is_not_null()


func test_character_starting_weapon_assignments() -> void:
	var expected_weapons := {
		"chef": PEPPER_DEF,
		"cookie": KNIFE_DEF,
		"witch": GARLIC_DEF,
		"goblin": SOUP_DEF,
		"mushroom": PAN_DEF,
		"vampire": ONION_RING_DEF,
		"onion": ONION_RING_DEF,
		"dumpling": LADLE_DEF,
		"snowman": TOASTER_DEF,
	}

	for character in CharacterRoster.load_roster():
		assert_bool(expected_weapons.has(character.id)).is_true()
		assert_object(character.starting_weapon).is_same(expected_weapons[character.id])


func test_character_definition_apply_to_player() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	await _wait_ready(player)

	ONION_DEF.apply_to_player(player)

	assert_object(player.get_character()).is_same(ONION_DEF)
	assert_int(player.get_max_health()).is_equal(ONION_DEF.max_health)


func test_weapon_controller_configure_weapons_replaces_loadout() -> void:
	var controller: WeaponController = auto_free(WeaponController.new()) as WeaponController
	var projectile_container := Node2D.new()
	add_child(controller)
	add_child(projectile_container)

	controller.configure_weapons(PEPPER_DEF)
	controller.setup(projectile_container, Rect2(-100.0, -100.0, 200.0, 200.0))
	assert_int(controller.get_child_count()).is_equal(1)
	assert_str((controller.get_child(0) as BaseWeapon).definition.id).is_equal("pepper_grinder_gun")

	controller.configure_weapons(SOUP_DEF)
	controller.setup(projectile_container, Rect2(-100.0, -100.0, 200.0, 200.0))
	assert_int(controller.get_child_count()).is_equal(1)
	assert_str((controller.get_child(0) as BaseWeapon).definition.id).is_equal(
		"boiling_soup_splash"
	)


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
