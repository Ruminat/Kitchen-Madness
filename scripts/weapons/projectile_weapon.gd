extends BaseWeapon

var _cooldown := 0.0


func _process(delta: float) -> void:
	var player := get_parent().get_parent() as CharacterBody2D
	if player == null:
		return

	var health_component := player.get_node_or_null("HealthComponent") as HealthComponent
	if health_component and not health_component.is_alive():
		return

	_cooldown -= delta
	if _cooldown > 0.0:
		return

	var target := _find_target_in_range()
	if target == null:
		return

	_fire_at(target)
	var fire_rate := definition.fire_rate if definition else 0.45
	_cooldown = fire_rate / get_fire_rate_multiplier()


## Nearest live enemy within the weapon's design attack range (0 = unlimited).
func _find_target_in_range() -> Node2D:
	var nearest := find_nearest_enemy()
	if nearest == null or definition == null or definition.attack_range <= 0.0:
		return nearest

	var range_px := StatUnits.area_to_pixels(definition.attack_range)
	if global_position.distance_squared_to(nearest.global_position) > range_px * range_px:
		return null
	return nearest


## Splash radius in engine pixels from the weapon's design area, scaled by area.
func _splash_pixels() -> float:
	if definition == null:
		return 0.0
	return StatUnits.area_to_pixels(definition.area) * get_area_multiplier()


func _fire_at(target: Node2D) -> void:
	if definition == null or definition.projectile_scene == null:
		return

	var container := get_projectile_container()
	if container == null:
		return

	play_fire_feedback()
	var damage := get_damage()
	var base_direction := (target.global_position - global_position).normalized()
	var pellet_count := definition.pellet_count if definition else 1
	var spread := deg_to_rad(definition.spread_degrees if definition else 0.0)

	for pellet_index in pellet_count:
		var angle_offset := 0.0
		if pellet_count > 1:
			var t := float(pellet_index) / float(pellet_count - 1)
			angle_offset = lerpf(-spread * 0.5, spread * 0.5, t)
		var direction := base_direction.rotated(angle_offset)
		_spawn_projectile(container, direction, damage)


func _spawn_projectile(container: Node2D, direction: Vector2, damage: int) -> void:
	AudioManager.play_shoot_sound("default")
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
	if projectile.has_method("set_crit_stats"):
		projectile.set_crit_stats(_crit_chance, _crit_damage)
	if projectile.has_method("set_splash_radius"):
		projectile.set_splash_radius(_splash_pixels())
	if projectile.has_method("set_visual_size"):
		# Render the projectile at the same on-screen size as the weapon icon.
		var visual_size := _player_render_diameter() * WEAPON_DIAMETER_FRACTION
		if visual_size > 0.0:
			projectile.set_visual_size(visual_size)
	container.add_child(projectile)
	projectile.global_position = global_position
