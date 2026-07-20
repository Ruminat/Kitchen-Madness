class_name WeaponController
extends Node2D

const MAX_WEAPONS := 6

@export var starting_weapon: WeaponDefinition
@export var extra_weapons: Array[WeaponDefinition] = []

var _weapons: Array[BaseWeapon] = []
var _projectile_container: Node2D
var _arena_bounds := Rect2()
## Global outgoing modifiers from the character + level/shop upgrades. New weapons
## inherit these so a bought weapon respects the character's damage/attack penalties.
var _global_damage_mult := 1.0
var _global_fire_rate_mult := 1.0
## Global area/size modifier applied to weapon reach and effect radii.
var _area_multiplier := 1.0


func configure_weapons(starting: WeaponDefinition) -> void:
	clear_weapons()
	starting_weapon = starting
	extra_weapons.clear()


## Seed the global outgoing modifiers from the selected character (percentages,
## e.g. -0.12 = -12%). Applied to any weapon added afterwards.
func set_character_modifiers(damage_mult: float, attack_speed_mult: float) -> void:
	_global_damage_mult = 1.0 + damage_mult
	_global_fire_rate_mult = 1.0 + attack_speed_mult


## Update the global area multiplier and push it to every owned weapon.
func set_area_multiplier(value: float) -> void:
	_area_multiplier = value
	for weapon in _weapons:
		if is_instance_valid(weapon):
			weapon.set_area_multiplier(value)


func clear_weapons() -> void:
	for weapon in _weapons:
		if is_instance_valid(weapon):
			remove_child(weapon)
			weapon.queue_free()
	_weapons.clear()


func setup(projectile_container: Node2D, bounds: Rect2) -> void:
	_projectile_container = projectile_container
	_arena_bounds = bounds

	for weapon in _weapons:
		weapon.set_projectile_container(projectile_container)
		weapon.set_arena_bounds(bounds)

	if starting_weapon and _weapons.is_empty():
		add_weapon(starting_weapon)


func _process(delta: float) -> void:
	var visible_index := 0
	var visible_count := _get_orbiting_weapon_count()
	for weapon in _weapons:
		if not is_instance_valid(weapon):
			continue
		if weapon.uses_orbit_slot():
			weapon.set_orbit_slot(visible_index, visible_count)
			visible_index += 1
		weapon.update_weapon_visual(delta)


func add_weapon(definition: WeaponDefinition) -> BaseWeapon:
	var weapon: BaseWeapon
	if definition.weapon_script:
		weapon = definition.weapon_script.new() as BaseWeapon
	else:
		weapon = BaseWeapon.new()
	add_child(weapon)
	weapon.setup(definition, _arena_bounds, _projectile_container)
	weapon.apply_damage_multiplier(_global_damage_mult)
	weapon.apply_fire_rate_multiplier(_global_fire_rate_mult)
	weapon.set_area_multiplier(_area_multiplier)
	_weapons.append(weapon)
	_sync_crit_stats(weapon)
	return weapon


func _sync_crit_stats(weapon: BaseWeapon) -> void:
	var player := get_parent() as Node
	if player == null:
		return
	if not (player.has_method("get_crit_chance") and player.has_method("get_crit_damage")):
		return
	weapon.set_crit_stats(player.get_crit_chance(), player.get_crit_damage())


func sync_all_crit_stats() -> void:
	var player := get_parent() as Node
	if player == null:
		return
	if not (player.has_method("get_crit_chance") and player.has_method("get_crit_damage")):
		return
	var crit_chance: float = player.get_crit_chance()
	var crit_damage: float = player.get_crit_damage()
	for weapon in _weapons:
		if is_instance_valid(weapon):
			weapon.set_crit_stats(crit_chance, crit_damage)


func _get_orbiting_weapon_count() -> int:
	var count := 0
	for weapon in _weapons:
		if is_instance_valid(weapon) and weapon.uses_orbit_slot():
			count += 1
	return count


func set_arena_bounds(bounds: Rect2) -> void:
	_arena_bounds = bounds
	for weapon in _weapons:
		weapon.set_arena_bounds(bounds)


func increase_damage_percent(percent: float) -> void:
	_global_damage_mult *= 1.0 + percent
	for weapon in _weapons:
		weapon.increase_damage_percent(percent)


func increase_fire_rate_percent(percent: float) -> void:
	_global_fire_rate_mult *= 1.0 + percent
	for weapon in _weapons:
		weapon.increase_fire_rate_percent(percent)


## Global outgoing-damage multiplier (character + upgrades). Shared with skills/pets.
func get_global_damage_multiplier() -> float:
	return _global_damage_mult


func get_owned_weapon_ids() -> Array[String]:
	var ids: Array[String] = []
	for weapon in _weapons:
		if weapon.definition:
			ids.append(weapon.definition.id)
	return ids


func has_weapon(weapon_id: String) -> bool:
	return weapon_id in get_owned_weapon_ids()


func weapon_count() -> int:
	return _weapons.size()


func remove_weapon(weapon_id: String) -> bool:
	for index in _weapons.size():
		var weapon := _weapons[index]
		if weapon.definition and weapon.definition.id == weapon_id:
			if is_instance_valid(weapon):
				remove_child(weapon)
				weapon.queue_free()
			_weapons.remove_at(index)
			return true
	return false


func can_add_weapon() -> bool:
	return _weapons.size() < MAX_WEAPONS


func get_weapon_display_name(weapon_id: String) -> String:
	for weapon in _weapons:
		if weapon.definition and weapon.definition.id == weapon_id:
			if not weapon.definition.display_name.is_empty():
				return weapon.definition.display_name
			return weapon.definition.id
	return weapon_id


func upgrade_weapon_damage(weapon_id: String, percent: float) -> void:
	for weapon in _weapons:
		if weapon.definition and weapon.definition.id == weapon_id:
			weapon.increase_damage_percent(percent)
			return


func upgrade_weapon_fire_rate(weapon_id: String, percent: float) -> void:
	for weapon in _weapons:
		if weapon.definition and weapon.definition.id == weapon_id:
			weapon.increase_fire_rate_percent(percent)
			return


func upgrade_weapon_pellets(weapon_id: String, amount: int) -> void:
	for weapon in _weapons:
		if weapon.definition and weapon.definition.id == weapon_id:
			weapon.increase_pellet_count(amount)
			return


func get_weapon_definition(weapon_id: String) -> WeaponDefinition:
	for weapon in _weapons:
		if weapon.definition and weapon.definition.id == weapon_id:
			return weapon.definition
	return null
