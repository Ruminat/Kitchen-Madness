# GdUnit generated TestSuite
extends GdUnitTestSuite


class MockPlayer:
	extends Node

	var damage_percent := 0.0
	var attack_speed_percent := 0.0
	var area_percent := 0.0
	var move_speed_percent := 0.0
	var max_health := 0
	var max_health_percent := 0.0
	var armor := 0
	var evasion := 0.0
	var luck := 0.0
	var pickup_range := 0.0
	var xp_gain_percent := 0.0

	func increase_weapon_damage_percent(percent: float) -> void:
		damage_percent += percent

	func increase_attack_speed_percent(percent: float) -> void:
		attack_speed_percent += percent

	func increase_area_percent(percent: float) -> void:
		area_percent += percent

	func increase_move_speed_percent(percent: float) -> void:
		move_speed_percent += percent

	func increase_max_health(amount: int, _heal: int = 0) -> void:
		max_health += amount

	func increase_max_health_percent(percent: float) -> void:
		max_health_percent += percent

	func increase_armor(amount: int) -> void:
		armor += amount

	func increase_evasion(amount: float) -> void:
		evasion += amount

	func increase_luck(amount: float) -> void:
		luck += amount

	func increase_pickup_range(amount: float) -> void:
		pickup_range += amount

	func increase_xp_gain_percent(percent: float) -> void:
		xp_gain_percent += percent


func test_damage_upgrade_applies_percent_to_player() -> void:
	var player := _create_player()
	_create_upgrade(&"damage_percent", 0.08).apply(player)
	assert_float(player.damage_percent).is_equal(0.08)


func test_attack_speed_upgrade_applies_percent_to_player() -> void:
	var player := _create_player()
	_create_upgrade(&"attack_speed_percent", 0.08).apply(player)
	assert_float(player.attack_speed_percent).is_equal(0.08)


func test_area_upgrade_applies_percent_to_player() -> void:
	var player := _create_player()
	_create_upgrade(&"area_percent", 0.05).apply(player)
	assert_float(player.area_percent).is_equal(0.05)


func test_move_speed_upgrade_applies_percent_to_player() -> void:
	var player := _create_player()
	_create_upgrade(&"move_speed_percent", 0.05).apply(player)
	assert_float(player.move_speed_percent).is_equal(0.05)


func test_armor_upgrade_applies_flat_value() -> void:
	var player := _create_player()
	_create_upgrade(&"armor_flat", 1.0).apply(player)
	assert_int(player.armor).is_equal(1)


func test_max_health_percent_upgrade_applies() -> void:
	var player := _create_player()
	_create_upgrade(&"max_health_percent", 0.05).apply(player)
	assert_float(player.max_health_percent).is_equal(0.05)


func test_luck_percent_upgrade_applies() -> void:
	var player := _create_player()
	_create_upgrade(&"luck_percent", 0.05).apply(player)
	assert_float(player.luck).is_equal(0.05)


func test_evasion_upgrade_applies() -> void:
	var player := _create_player()
	_create_upgrade(&"evasion_percent", 0.04).apply(player)
	assert_float(player.evasion).is_equal(0.04)


func _create_player() -> MockPlayer:
	var player: MockPlayer = auto_free(MockPlayer.new()) as MockPlayer
	add_child(player)
	return player


func _create_upgrade(effect: StringName, amount: float) -> UpgradeDefinition:
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = effect
	upgrade.amount = amount
	return upgrade
