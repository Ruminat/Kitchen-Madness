extends BaseWeapon

var _cooldown := 0.0


func _process(delta: float) -> void:
	if not _player_is_alive():
		return

	_cooldown -= delta
	if _cooldown > 0.0:
		return

	var target := find_nearest_enemy()
	if target == null:
		return

	_throw_at(target)
	var fire_rate := definition.fire_rate if definition else 0.9
	_cooldown = fire_rate / get_fire_rate_multiplier()


func _player_is_alive() -> bool:
	var player := get_parent().get_parent() as CharacterBody2D
	if player == null:
		return false

	var health_component := player.get_node_or_null("HealthComponent") as HealthComponent
	return health_component == null or health_component.is_alive()


func _throw_at(target: Node2D) -> void:
	if definition == null or definition.projectile_scene == null:
		return

	var container := get_projectile_container()
	var player := get_parent().get_parent() as Node2D
	if container == null or player == null:
		return

	play_fire_feedback()
	var direction := (target.global_position - global_position).normalized()
	var projectile := definition.projectile_scene.instantiate()
	if projectile.has_method("setup"):
		projectile.setup(
			direction,
			arena_bounds,
			get_damage(),
			definition.projectile_speed,
			definition.projectile_lifetime,
			definition.projectile_texture,
			player,
			definition.vfx_accent
		)
	container.add_child(projectile)
	projectile.global_position = global_position
