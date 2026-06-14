class_name BaseWeapon
extends Node2D

var definition: WeaponDefinition
var arena_bounds := Rect2()
var _projectile_container: Node2D


func setup(
	def: WeaponDefinition,
	bounds: Rect2,
	projectile_container: Node2D
) -> void:
	definition = def
	arena_bounds = bounds
	_projectile_container = projectile_container


func set_arena_bounds(bounds: Rect2) -> void:
	arena_bounds = bounds


func set_projectile_container(container: Node2D) -> void:
	_projectile_container = container


func get_projectile_container() -> Node2D:
	return _projectile_container
