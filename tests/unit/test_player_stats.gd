# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")


func test_luck_increases_gold_and_xp_multipliers() -> void:
	var player := _create_player()
	player.increase_luck(10)

	assert_float(player.get_gold_multiplier()).is_equal(1.1)
	assert_float(player.get_xp_multiplier()).is_equal(1.1)


func test_xp_gain_upgrade_stacks_with_luck() -> void:
	var player := _create_player()
	player.increase_xp_gain_percent(0.1)
	player.increase_luck(5)

	assert_float(player.get_xp_multiplier()).is_equal(1.15)


func test_pickup_range_bonus_accumulates() -> void:
	var player := _create_player()
	player.increase_pickup_range(12.0)
	player.increase_pickup_range(8.0)

	assert_float(player.get_pickup_range_bonus()).is_equal(20.0)


func test_health_drop_chance_bonus_scales_with_luck() -> void:
	var player := _create_player()
	player.increase_luck(20)

	assert_float(player.get_health_drop_chance_bonus()).is_equal(0.03)


func test_armor_upgrade_applies_through_player() -> void:
	var player := _create_player()
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = &"armor_flat"
	upgrade.amount = 3.0

	upgrade.apply(player)

	assert_int(player.health_component.armor).is_equal(3)


func _create_player() -> CharacterBody2D:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	if not player.is_node_ready():
		await player.ready
	return player
