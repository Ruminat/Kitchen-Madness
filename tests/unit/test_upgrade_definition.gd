# GdUnit generated TestSuite
extends GdUnitTestSuite


class MockPlayer:
	extends Node

	var damage_percent := 0.0
	var move_speed_percent := 0.0
	var max_health := 0
	var orbit_blades := 0

	func increase_weapon_damage_percent(percent: float) -> void:
		damage_percent += percent

	func increase_move_speed_percent(percent: float) -> void:
		move_speed_percent += percent

	func increase_max_health(amount: int) -> void:
		max_health += amount

	func increase_orbit_blades(amount: int) -> void:
		orbit_blades += amount


func test_damage_upgrade_applies_percent_to_player() -> void:
	var player := _create_player()
	var upgrade := _create_upgrade(&"damage_percent", 0.1)

	upgrade.apply(player)

	assert_float(player.damage_percent).is_equal(0.1)


func test_speed_upgrade_applies_percent_to_player() -> void:
	var player := _create_player()
	var upgrade := _create_upgrade(&"move_speed_percent", 0.15)

	upgrade.apply(player)

	assert_float(player.move_speed_percent).is_equal(0.15)


func test_flat_upgrades_round_amounts_to_ints() -> void:
	var player := _create_player()
	var health_upgrade := _create_upgrade(&"max_health_flat", 20.0)
	var blade_upgrade := _create_upgrade(&"orbit_blade_flat", 1.0)

	health_upgrade.apply(player)
	blade_upgrade.apply(player)

	assert_int(player.max_health).is_equal(20)
	assert_int(player.orbit_blades).is_equal(1)


func _create_player() -> MockPlayer:
	var player: MockPlayer = auto_free(MockPlayer.new()) as MockPlayer
	add_child(player)
	return player


func _create_upgrade(effect: StringName, amount: float) -> UpgradeDefinition:
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = effect
	upgrade.amount = amount
	return upgrade
