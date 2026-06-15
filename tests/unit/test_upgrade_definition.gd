# GdUnit generated TestSuite
extends GdUnitTestSuite


class MockPlayer:
	extends Node

	var damage_percent := 0.0
	var attack_speed_percent := 0.0
	var move_speed_percent := 0.0
	var max_health := 0
	var armor := 0
	var luck := 0
	var pickup_range := 0.0
	var xp_gain_percent := 0.0

	func increase_weapon_damage_percent(percent: float) -> void:
		damage_percent += percent

	func increase_attack_speed_percent(percent: float) -> void:
		attack_speed_percent += percent

	func increase_move_speed_percent(percent: float) -> void:
		move_speed_percent += percent

	func increase_max_health(amount: int, _heal: int = 0) -> void:
		max_health += amount

	func increase_armor(amount: int) -> void:
		armor += amount

	func increase_luck(amount: int) -> void:
		luck += amount

	func increase_pickup_range(amount: float) -> void:
		pickup_range += amount

	func increase_xp_gain_percent(percent: float) -> void:
		xp_gain_percent += percent


func test_damage_upgrade_applies_percent_to_player() -> void:
	var player := _create_player()
	var upgrade := _create_upgrade(&"damage_percent", 0.08)

	upgrade.apply(player)

	assert_float(player.damage_percent).is_equal(0.08)


func test_attack_speed_upgrade_applies_percent_to_player() -> void:
	var player := _create_player()
	var upgrade := _create_upgrade(&"attack_speed_percent", 0.08)

	upgrade.apply(player)

	assert_float(player.attack_speed_percent).is_equal(0.08)


func test_armor_and_luck_upgrades_apply_flat_values() -> void:
	var player := _create_player()
	var armor_upgrade := _create_upgrade(&"armor_flat", 2.0)
	var luck_upgrade := _create_upgrade(&"luck_flat", 2.0)

	armor_upgrade.apply(player)
	luck_upgrade.apply(player)

	assert_int(player.armor).is_equal(2)
	assert_int(player.luck).is_equal(2)


func test_pickup_range_and_xp_upgrades_apply() -> void:
	var player := _create_player()
	var range_upgrade := _create_upgrade(&"pickup_range_flat", 12.0)
	var xp_upgrade := _create_upgrade(&"xp_gain_percent", 0.1)

	range_upgrade.apply(player)
	xp_upgrade.apply(player)

	assert_float(player.pickup_range).is_equal(12.0)
	assert_float(player.xp_gain_percent).is_equal(0.1)


func _create_player() -> MockPlayer:
	var player: MockPlayer = auto_free(MockPlayer.new()) as MockPlayer
	add_child(player)
	return player


func _create_upgrade(effect: StringName, amount: float) -> UpgradeDefinition:
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = effect
	upgrade.amount = amount
	return upgrade
