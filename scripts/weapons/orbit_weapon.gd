extends BaseWeapon

const BLADE_RADIUS := 8.0
const HIT_COOLDOWN := 0.25

var _angle := 0.0
var _hit_cooldowns: Dictionary = {}


func _process(delta: float) -> void:
	var player := get_parent().get_parent() as CharacterBody2D
	if player == null:
		return

	var health_component := player.get_node_or_null("HealthComponent") as HealthComponent
	if health_component and not health_component.is_alive():
		return

	var orbit_speed := (definition.orbit_speed if definition else 4.0) * get_fire_rate_multiplier()
	_angle += orbit_speed * delta
	_prune_hit_cooldowns()
	_damage_enemies_at_blades(player)
	queue_redraw()


func _damage_enemies_at_blades(player: Node2D) -> void:
	var blade_count := definition.pellet_count if definition else 2
	var orbit_radius := definition.orbit_radius if definition else 60.0
	var damage := get_damage()
	var center := player.global_position

	for blade_index in blade_count:
		var blade_angle := _angle + TAU * float(blade_index) / float(blade_count)
		var blade_pos := center + Vector2(cos(blade_angle), sin(blade_angle)) * orbit_radius
		_check_blade_hits(blade_pos, damage)


func _check_blade_hits(blade_pos: Vector2, damage: int) -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue

		var enemy_radius := 12.0
		if enemy.has_method("get_collision_radius"):
			enemy_radius = enemy.get_collision_radius()

		var touch_distance := BLADE_RADIUS + enemy_radius
		if blade_pos.distance_squared_to(enemy.global_position) > touch_distance * touch_distance:
			continue

		var enemy_id: int = enemy.get_instance_id()
		if _hit_cooldowns.has(enemy_id):
			continue

		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)
		_hit_cooldowns[enemy_id] = HIT_COOLDOWN


func _prune_hit_cooldowns() -> void:
	var expired: Array[int] = []
	for enemy_id in _hit_cooldowns:
		_hit_cooldowns[enemy_id] -= get_process_delta_time()
		if _hit_cooldowns[enemy_id] <= 0.0:
			expired.append(enemy_id)

	for enemy_id in expired:
		_hit_cooldowns.erase(enemy_id)


func _draw() -> void:
	if definition == null:
		return

	var blade_count := definition.pellet_count
	var orbit_radius := definition.orbit_radius
	var blade_color := Color(0.75, 0.85, 1.0, 0.9)

	for blade_index in blade_count:
		var blade_angle := _angle + TAU * float(blade_index) / float(blade_count)
		var offset := Vector2(cos(blade_angle), sin(blade_angle)) * orbit_radius
		draw_circle(offset, BLADE_RADIUS, blade_color)
