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
	signal upgrades_open_requested

	var shown := false
	var hidden := false
	var show_count := 0
	var choices: Array[Resource] = []

	func show_level_up_options(upgrades: Array[Resource]) -> void:
		shown = true
		show_count += 1
		choices = upgrades

	func hide_level_up_options() -> void:
		hidden = true


func before_test() -> void:
	get_tree().paused = false


func after_test() -> void:
	get_tree().paused = false


func test_level_up_banks_choice_without_pausing_or_showing() -> void:
	var manager := _create_manager([_create_damage_upgrade(0.1)])
	var ui := _create_ui()
	manager.configure(_create_player(), ui, func() -> bool: return true)

	EventBus.level_up.emit(2)
	EventBus.level_up.emit(3)

	assert_bool(get_tree().paused).is_false()
	assert_bool(ui.shown).is_false()
	assert_int(manager.pending_count()).is_equal(2)
	assert_bool(manager.has_pending()).is_true()


func test_level_up_emits_pending_count() -> void:
	var manager := _create_manager([_create_damage_upgrade(0.1)])
	manager.configure(_create_player(), _create_ui(), func() -> bool: return true)

	var counts: Array[int] = []
	var handler := func(count: int) -> void: counts.append(count)
	EventBus.upgrades_pending_changed.connect(handler)
	EventBus.level_up.emit(2)
	EventBus.level_up.emit(3)
	EventBus.upgrades_pending_changed.disconnect(handler)

	assert_array(counts).is_equal([1, 2])


func test_open_upgrades_pauses_and_shows_three_choices() -> void:
	var upgrades: Array[Resource] = [
		_create_damage_upgrade(0.1),
		_create_damage_upgrade(0.2),
		_create_damage_upgrade(0.3),
		_create_damage_upgrade(0.4),
	]
	var manager := _create_manager(upgrades)
	var ui := _create_ui()
	manager.configure(_create_player(), ui, func() -> bool: return true)

	EventBus.level_up.emit(2)
	manager.open_upgrades()

	assert_bool(get_tree().paused).is_true()
	assert_bool(ui.shown).is_true()
	assert_int(ui.choices.size()).is_equal(3)


func test_open_upgrades_responds_to_ui_signal() -> void:
	var manager := _create_manager([_create_damage_upgrade(0.1)])
	var ui := _create_ui()
	manager.configure(_create_player(), ui, func() -> bool: return true)

	EventBus.level_up.emit(2)
	ui.upgrades_open_requested.emit()

	assert_bool(ui.shown).is_true()
	assert_bool(get_tree().paused).is_true()


func test_open_upgrades_does_nothing_without_pending() -> void:
	var manager := _create_manager([_create_damage_upgrade(0.1)])
	var ui := _create_ui()
	manager.configure(_create_player(), ui, func() -> bool: return true)

	manager.open_upgrades()

	assert_bool(ui.shown).is_false()
	assert_bool(get_tree().paused).is_false()


func test_selecting_last_pending_upgrade_applies_hides_and_resumes() -> void:
	var upgrade := _create_damage_upgrade(0.1)
	var manager := _create_manager([upgrade])
	var player := _create_player()
	var ui := _create_ui()
	manager.configure(player, ui, func() -> bool: return true)

	EventBus.level_up.emit(2)
	manager.open_upgrades()
	ui.upgrade_selected.emit(upgrade)

	assert_float(player.damage_percent).is_equal(0.1)
	assert_bool(ui.hidden).is_true()
	assert_bool(get_tree().paused).is_false()
	assert_int(manager.pending_count()).is_equal(0)


func test_selecting_with_remaining_pending_keeps_menu_open() -> void:
	var upgrade := _create_damage_upgrade(0.1)
	var manager := _create_manager([upgrade])
	var ui := _create_ui()
	manager.configure(_create_player(), ui, func() -> bool: return true)

	EventBus.level_up.emit(2)
	EventBus.level_up.emit(3)
	manager.open_upgrades()
	ui.upgrade_selected.emit(upgrade)

	assert_bool(ui.hidden).is_false()
	assert_bool(get_tree().paused).is_true()
	assert_int(manager.pending_count()).is_equal(1)
	assert_int(ui.show_count).is_equal(2)


func test_open_upgrades_does_not_show_when_run_is_inactive() -> void:
	var manager := _create_manager([_create_damage_upgrade(0.1)])
	var ui := _create_ui()
	manager.configure(_create_player(), ui, func() -> bool: return false)

	EventBus.level_up.emit(2)
	manager.open_upgrades()

	assert_bool(ui.shown).is_false()
	assert_bool(get_tree().paused).is_false()


func test_level_up_pool_includes_skill_offers_when_runner_present() -> void:
	# Unified acquisition: skills join the level-up pool. With one stat upgrade and
	# three skill learn offers, three choices always include at least one skill.
	var runner: SkillRunner = auto_free(SkillRunner.new()) as SkillRunner
	add_child(runner)
	var manager := _create_manager([_create_damage_upgrade(0.1)])
	var ui := _create_ui()
	manager.configure(_create_player(), ui, func() -> bool: return true, runner)

	EventBus.level_up.emit(2)
	manager.open_upgrades()

	assert_int(ui.choices.size()).is_equal(3)
	var has_skill_offer := false
	for choice in ui.choices:
		if choice is SkillShopOffer:
			has_skill_offer = true
	assert_bool(has_skill_offer).is_true()


func _create_manager(upgrades: Array[Resource]) -> LevelUpManager:
	var manager: LevelUpManager = auto_free(LevelUpManager.new()) as LevelUpManager
	manager.upgrades = upgrades
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
