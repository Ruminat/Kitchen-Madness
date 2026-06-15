# GdUnit generated TestSuite
extends GdUnitTestSuite


class MockPlayer:
	extends Node

	var damage_percent := 0.0
	var luck := 0

	func increase_weapon_damage_percent(percent: float) -> void:
		damage_percent += percent

	func get_luck() -> int:
		return luck


class MockUpgradeUi:
	extends Node

	signal upgrade_selected(upgrade: Resource)

	var shown := false
	var hidden := false
	var choices: Array[Resource] = []

	func show_level_up_options(upgrades: Array[Resource]) -> void:
		shown = true
		choices = upgrades

	func hide_level_up_options() -> void:
		hidden = true


func before() -> void:
	get_tree().paused = false


func after() -> void:
	get_tree().paused = false


func test_level_up_pauses_and_shows_three_upgrade_choices() -> void:
	var upgrade_a := _create_damage_upgrade(0.1)
	var upgrade_b := _create_damage_upgrade(0.2)
	var upgrade_c := _create_damage_upgrade(0.3)
	var upgrade_d := _create_damage_upgrade(0.4)
	var manager := _create_manager([upgrade_a, upgrade_b, upgrade_c, upgrade_d])
	var player := _create_player()
	var ui := _create_ui()
	manager.configure(player, ui, func() -> bool: return true)

	EventBus.level_up.emit(2)

	assert_bool(get_tree().paused).is_true()
	assert_bool(ui.shown).is_true()
	assert_int(ui.choices.size()).is_equal(3)


func test_selecting_upgrade_applies_effect_hides_ui_and_resumes() -> void:
	var upgrade := _create_damage_upgrade(0.1)
	var manager := _create_manager([upgrade])
	var player := _create_player()
	var ui := _create_ui()
	manager.configure(player, ui, func() -> bool: return true)

	EventBus.level_up.emit(2)
	ui.upgrade_selected.emit(upgrade)

	assert_float(player.damage_percent).is_equal(0.1)
	assert_bool(ui.hidden).is_true()
	assert_bool(get_tree().paused).is_false()


func test_level_up_does_not_show_choices_when_run_is_inactive() -> void:
	var upgrade := _create_damage_upgrade(0.1)
	var manager := _create_manager([upgrade])
	var player := _create_player()
	var ui := _create_ui()
	manager.configure(player, ui, func() -> bool: return false)

	EventBus.level_up.emit(2)

	assert_bool(ui.shown).is_false()
	assert_bool(get_tree().paused).is_false()


func test_lucky_player_expands_upgrade_candidate_pool() -> void:
	var upgrades: Array[Resource] = []
	for index in 6:
		upgrades.append(_create_damage_upgrade(0.1 * float(index + 1)))
	var manager := _create_manager(upgrades)
	var player := _create_player()
	player.luck = 20
	var ui := _create_ui()
	manager.configure(player, ui, func() -> bool: return true)

	EventBus.level_up.emit(2)

	assert_int(ui.choices.size()).is_equal(3)
	var amounts: Array[float] = []
	for choice in ui.choices:
		amounts.append(choice.amount)
	assert_float(amounts.max()).is_equal(0.6)


func _create_manager(upgrades: Array[Resource]) -> LevelUpManager:
	var manager: LevelUpManager = auto_free(LevelUpManager.new()) as LevelUpManager
	manager.upgrades = upgrades
	manager.delay_seconds = 0.0
	add_child(manager)
	return manager


func _create_player() -> MockPlayer:
	var player: MockPlayer = auto_free(MockPlayer.new()) as MockPlayer
	add_child(player)
	return player


func _create_ui() -> MockUpgradeUi:
	var ui: MockUpgradeUi = auto_free(MockUpgradeUi.new()) as MockUpgradeUi
	add_child(ui)
	return ui


func _create_damage_upgrade(amount: float) -> UpgradeDefinition:
	var upgrade := UpgradeDefinition.new()
	upgrade.effect = &"damage_percent"
	upgrade.amount = amount
	return upgrade
