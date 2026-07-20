# GdUnit generated TestSuite
extends GdUnitTestSuite
## Modifier stacking: character penalties + upgrades + inheritance by new weapons.


func test_character_modifiers_apply_to_starting_weapon() -> void:
	var controller := _make_controller()
	controller.set_character_modifiers(-0.12, 0.18)
	var weapon := controller.add_weapon(_make_weapon("a", 100, 1.0))

	assert_int(weapon.get_damage()).is_equal(88)
	assert_float(weapon.get_fire_rate_multiplier()).is_equal_approx(1.18, 0.0001)


func test_global_upgrades_stack_on_character_modifiers() -> void:
	var controller := _make_controller()
	controller.set_character_modifiers(-0.12, 0.0)
	var weapon := controller.add_weapon(_make_weapon("a", 100, 1.0))

	controller.increase_damage_percent(0.10)

	# 0.88 (character) * 1.10 (upgrade) = 0.968.
	assert_int(weapon.get_damage()).is_equal(97)


func test_new_weapon_inherits_accumulated_global_modifiers() -> void:
	var controller := _make_controller()
	controller.set_character_modifiers(-0.12, 0.0)
	controller.add_weapon(_make_weapon("a", 100, 1.0))
	controller.increase_damage_percent(0.10)

	var later := controller.add_weapon(_make_weapon("b", 100, 1.0))

	assert_int(later.get_damage()).is_equal(97)


func test_area_multiplier_propagates_to_all_weapons() -> void:
	var controller := _make_controller()
	var first := controller.add_weapon(_make_weapon("a", 10, 1.0))
	controller.set_area_multiplier(1.5)
	var second := controller.add_weapon(_make_weapon("b", 10, 1.0))

	assert_float(first.get_area_multiplier()).is_equal_approx(1.5, 0.0001)
	assert_float(second.get_area_multiplier()).is_equal_approx(1.5, 0.0001)


func _make_controller() -> WeaponController:
	var controller: WeaponController = auto_free(WeaponController.new()) as WeaponController
	add_child(controller)
	return controller


func _make_weapon(id: String, damage: int, fire_rate: float) -> WeaponDefinition:
	var definition := WeaponDefinition.new()
	definition.id = id
	definition.damage = damage
	definition.fire_rate = fire_rate
	definition.weapon_type = WeaponDefinition.WeaponType.MELEE
	return definition
