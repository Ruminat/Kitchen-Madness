extends Node2D

var _definition: WeaponDefinition
var _arena_bounds := Rect2()
var _projectile_container: Node2D
var _damage := 10
var _fire_rate_multiplier := 1.0
var _lifetime := 5.0
var _fire_cooldown := 0.0


func setup(
	definition: WeaponDefinition,
	bounds: Rect2,
	projectile_container: Node2D,
	damage: int,
	fire_rate_multiplier: float
) -> void:
	_definition = definition
	_arena_bounds = bounds
	_projectile_container = projectile_container
	_damage = damage
	_fire_rate_multiplier = fire_rate_multiplier
	_lifetime = definition.turret_duration if definition else 5.0
	_fire_cooldown = 0.0
	get_tree().create_timer(_lifetime).timeout.connect(queue_free)


func _process(delta: float) -> void:
	_fire_cooldown -= delta
	if _fire_cooldown > 0.0:
		return

	var target := _find_nearest_enemy()
	if target == null:
		return

	_fire_at(target)
	var fire_rate := _definition.turret_fire_rate if _definition else 0.5
	_fire_cooldown = fire_rate / maxf(_fire_rate_multiplier, 0.1)


func _find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist_sq := INF

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy):
			continue
		var dist_sq := global_position.distance_squared_to(enemy.global_position)
		if dist_sq < nearest_dist_sq:
			nearest_dist_sq = dist_sq
			nearest = enemy

	return nearest


func _fire_at(target: Node2D) -> void:
	if _definition == null or _definition.projectile_scene == null or _projectile_container == null:
		return

	var direction := (target.global_position - global_position).normalized()
	var projectile := _definition.projectile_scene.instantiate()
	if projectile.has_method("setup"):
		projectile.setup(
			direction,
			_arena_bounds,
			_damage,
			_definition.projectile_speed,
			_definition.projectile_lifetime,
			_definition.projectile_texture,
			_definition.vfx_accent
		)
	_projectile_container.add_child(projectile)
	projectile.global_position = global_position
