extends BaseWeapon

var _cooldown := 0.0


func _process(delta: float) -> void:
	if not _player_is_alive():
		return

	_cooldown -= delta
	if _cooldown > 0.0:
		return

	_fire_burst()
	var fire_rate := definition.fire_rate if definition else 0.45
	_cooldown = fire_rate / get_fire_rate_multiplier()


func _player_is_alive() -> bool:
	var player := get_parent().get_parent() as CharacterBody2D
	if player == null:
		return false

	var health_component := player.get_node_or_null("HealthComponent") as HealthComponent
	return health_component == null or health_component.is_alive()


func _fire_burst() -> void:
	if definition == null or definition.projectile_scene == null:
		return

	var container := get_projectile_container()
	if container == null:
		return

	var damage := get_damage()
	var pellet_count := maxi(definition.pellet_count, 1)

	for pellet_index in pellet_count:
		var angle := TAU * float(pellet_index) / float(pellet_count)
		var direction := Vector2(cos(angle), sin(angle))
		_spawn_projectile(container, direction, damage)


func _spawn_projectile(container: Node2D, direction: Vector2, damage: int) -> void:
	var projectile := definition.projectile_scene.instantiate()
	if projectile.has_method("setup"):
		projectile.setup(
			direction,
			arena_bounds,
			damage,
			definition.projectile_speed,
			definition.projectile_lifetime,
			definition.projectile_texture,
			definition.vfx_accent
		)
	container.add_child(projectile)
	projectile.global_position = global_position
