# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const NEWBIE_DEF := preload("res://resources/characters/the_newbie.tres")
const BARRET_DEF := preload("res://resources/characters/mr_barret.tres")
const NATSUMI_DEF := preload("res://resources/characters/natsumi.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")
const PAN_DEF := preload("res://resources/weapons/frying_pan.tres")
const TOMATO_DEF := preload("res://resources/weapons/rotten_tomato.tres")


func test_character_roster_loads_three_characters() -> void:
	var roster := CharacterRoster.load_roster()
	assert_int(roster.size()).is_equal(3)


func test_default_character_is_the_newbie() -> void:
	assert_object(CharacterRoster.get_default()).is_same(NEWBIE_DEF)


func test_configure_applies_sprite_stats_and_starting_weapon() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	await _wait_ready(player)

	player.configure(BARRET_DEF)

	var sprite: Sprite2D = player.get_node("Visual/Sprite") as Sprite2D
	assert_object(sprite.texture).is_same(BARRET_DEF.sprite)
	assert_float(player.move_speed).is_equal_approx(
		StatUnits.speed_to_pixels(BARRET_DEF.move_speed), 0.001
	)
	assert_float(player.get_luck()).is_equal_approx(BARRET_DEF.luck, 0.0001)
	assert_int(player.get_max_health()).is_equal(BARRET_DEF.max_health)
	assert_int(player.get_health()).is_equal(BARRET_DEF.max_health)

	var weapon_controller: WeaponController = (
		player.get_node("WeaponController") as WeaponController
	)
	assert_object(weapon_controller.starting_weapon).is_same(PAN_DEF)
	assert_int(weapon_controller.extra_weapons.size()).is_equal(0)


func test_setup_adds_only_starting_weapon() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	var projectile_container := Node2D.new()
	add_child(player)
	add_child(projectile_container)
	await _wait_ready(player)

	player.configure(NEWBIE_DEF)
	player.setup(Rect2(-100.0, -100.0, 200.0, 200.0), projectile_container)

	var weapon_controller: WeaponController = (
		player.get_node("WeaponController") as WeaponController
	)
	assert_int(weapon_controller.get_child_count()).is_equal(1)
	var weapon: BaseWeapon = weapon_controller.get_child(0) as BaseWeapon
	assert_str(weapon.definition.id).is_equal(KNIFE_DEF.id)


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
		"the_newbie": KNIFE_DEF,
		"mr_barret": PAN_DEF,
		"natsumi": TOMATO_DEF,
	}

	for character in CharacterRoster.load_roster():
		assert_bool(expected_weapons.has(character.id)).is_true()
		assert_object(character.starting_weapon).is_same(expected_weapons[character.id])


func test_character_definition_apply_to_player() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	await _wait_ready(player)

	NATSUMI_DEF.apply_to_player(player)

	assert_object(player.get_character()).is_same(NATSUMI_DEF)
	assert_int(player.get_max_health()).is_equal(NATSUMI_DEF.max_health)


func test_character_stat_modifiers_reach_the_player() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	await _wait_ready(player)

	# The Newbie: -12% damage, +18% attack speed, +24% crit, +12% luck.
	player.configure(NEWBIE_DEF)

	assert_float(player.get_crit_chance()).is_equal_approx(0.05 + 0.24, 0.0001)
	assert_float(player.get_luck()).is_equal_approx(0.12, 0.0001)


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
