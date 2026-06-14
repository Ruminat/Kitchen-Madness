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

	var target := _find_nearest_enemy()
	if target == null:
		return

	_fire_at(target)
	_cooldown = definition.fire_rate if definition else 0.45


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
	if definition == null or definition.projectile_scene == null:
		return

	var container := get_projectile_container()
	if container == null:
		return

	var damage := definition.damage if definition else 15
	var direction := (target.global_position - global_position).normalized()
	var projectile := definition.projectile_scene.instantiate()
	if projectile.has_method("setup"):
		projectile.setup(direction, arena_bounds, damage)
	container.add_child(projectile)
	projectile.global_position = global_position
