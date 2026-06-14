class_name BaseWeapon
extends Node2D

var definition: WeaponDefinition
var arena_bounds := Rect2()
var _projectile_container: Node2D
var _damage_multiplier := 1.0


func setup(
	def: WeaponDefinition,
	bounds: Rect2,
	projectile_container: Node2D
) -> void:
	definition = (def.duplicate() as WeaponDefinition) if def else null
	arena_bounds = bounds
	_projectile_container = projectile_container


func set_arena_bounds(bounds: Rect2) -> void:
	arena_bounds = bounds


func set_projectile_container(container: Node2D) -> void:
	_projectile_container = container


func get_projectile_container() -> Node2D:
	return _projectile_container


func increase_damage_percent(percent: float) -> void:
	if percent <= 0.0:
		return

	_damage_multiplier *= 1.0 + percent


func get_damage() -> int:
	if definition == null:
		return 0

	return maxi(roundi(float(definition.damage) * _damage_multiplier), 1)


func increase_pellet_count(amount: int) -> void:
	if definition == null or amount <= 0:
		return

	definition.pellet_count += amount
