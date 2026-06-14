class_name WeaponController
extends Node2D

@export var starting_weapon: WeaponDefinition
@export var extra_weapons: Array[WeaponDefinition] = []

var _weapons: Array[BaseWeapon] = []
var _projectile_container: Node2D
var _arena_bounds := Rect2()


func setup(projectile_container: Node2D, bounds: Rect2) -> void:
	_projectile_container = projectile_container
	_arena_bounds = bounds

	for weapon in _weapons:
		weapon.set_projectile_container(projectile_container)
		weapon.set_arena_bounds(bounds)

	if starting_weapon and _weapons.is_empty():
		add_weapon(starting_weapon)

	for weapon_definition in extra_weapons:
		add_weapon(weapon_definition)


func add_weapon(definition: WeaponDefinition) -> BaseWeapon:
	var weapon: BaseWeapon
	if definition.weapon_script:
		weapon = definition.weapon_script.new() as BaseWeapon
	else:
		weapon = BaseWeapon.new()
	add_child(weapon)
	weapon.setup(definition, _arena_bounds, _projectile_container)
	_weapons.append(weapon)
	return weapon


func set_arena_bounds(bounds: Rect2) -> void:
	_arena_bounds = bounds
	for weapon in _weapons:
		weapon.set_arena_bounds(bounds)


func increase_damage_percent(percent: float) -> void:
	for weapon in _weapons:
		weapon.increase_damage_percent(percent)


func increase_orbit_blades(amount: int) -> void:
	for weapon in _weapons:
		if weapon.definition and weapon.definition.id == "orbit_blade":
			weapon.increase_pellet_count(amount)
