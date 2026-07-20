# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")


func test_luck_increases_gold_and_xp_multipliers() -> void:
	var player := await _create_player()
	player.increase_luck(0.1)

	assert_float(player.get_gold_multiplier()).is_equal_approx(1.1, 0.0001)
	assert_float(player.get_xp_multiplier()).is_equal_approx(1.1, 0.0001)


func test_xp_gain_upgrade_stacks_with_luck() -> void:
	var player := await _create_player()
	player.increase_xp_gain_percent(0.1)
	player.increase_luck(0.05)

	assert_float(abs(player.get_xp_multiplier() - 1.155)).is_less_equal(0.0001)


func test_pickup_range_bonus_accumulates() -> void:
	var player := await _create_player()
	player.increase_pickup_range(12.0)
	player.increase_pickup_range(8.0)

	assert_float(player.get_pickup_range_bonus()).is_equal(20.0)


func test_health_drop_chance_bonus_scales_with_luck() -> void:
	var player := await _create_player()
	player.increase_luck(0.2)

	assert_float(player.get_health_drop_chance_bonus()).is_equal_approx(0.03, 0.0001)


func test_armor_upgrade_applies_through_player() -> void:
	var player := await _create_player()
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = &"armor_flat"
	upgrade.amount = 3.0

	upgrade.apply(player)

	assert_int(player.health_component.armor).is_equal(3)


func test_evasion_upgrade_applies_through_player() -> void:
	var player := await _create_player()
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = &"evasion_percent"
	upgrade.amount = 0.04

	upgrade.apply(player)

	assert_float(player.get_evasion()).is_equal_approx(0.04, 0.0001)


func test_area_upgrade_stacks_multiplicatively() -> void:
	var player := await _create_player()
	player.increase_area_percent(0.05)
	player.increase_area_percent(0.05)

	assert_float(player.get_area_multiplier()).is_equal_approx(1.1025, 0.0001)


func test_max_health_percent_scales_current_max() -> void:
	var player := await _create_player()
	var start_max: int = player.get_max_health()
	player.increase_max_health_percent(0.05)

	assert_int(player.get_max_health()).is_equal(start_max + roundi(float(start_max) * 0.05))


func test_move_speed_percent_supports_negative() -> void:
	var player := await _create_player()
	var start_speed: float = player.move_speed
	player.increase_move_speed_percent(-0.03)

	assert_float(player.move_speed).is_equal_approx(start_speed * 0.97, 0.0001)


func _create_player() -> CharacterBody2D:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	if not player.is_node_ready():
		await player.ready
	return player
