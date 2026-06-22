extends BaseWeapon

const SWING_VISUAL_TIME := 0.2

var _cooldown := 0.0
var _swing_timer := 0.0
var _swing_direction := Vector2.RIGHT


func _process(delta: float) -> void:
	var player := _get_player()
	if player == null:
		return

	var health_component := player.get_node_or_null("HealthComponent") as HealthComponent
	if health_component and not health_component.is_alive():
		return

	_swing_timer = maxf(_swing_timer - delta, 0.0)
	if _swing_timer > 0.0:
		queue_redraw()

	_cooldown -= delta
	if _cooldown > 0.0:
		return

	var attack_origin := player.global_position
	var target := _find_melee_target(attack_origin)
	if target == null:
		return

	_perform_swing(attack_origin, target)
	var fire_rate := definition.fire_rate if definition else 0.45
	_cooldown = fire_rate / get_fire_rate_multiplier()


static func is_target_in_arc(
	origin: Vector2,
	attack_direction: Vector2,
	target_position: Vector2,
	target_radius: float,
	melee_range: float,
	arc_degrees: float
) -> bool:
	if attack_direction.length_squared() <= 0.0001:
		return false

	var to_target := target_position - origin
	var reach := melee_range + target_radius
	if to_target.length_squared() > reach * reach:
		return false

	var angle_diff := absf(
		rad_to_deg(attack_direction.normalized().angle_to(to_target.normalized()))
	)
	return angle_diff <= arc_degrees * 0.5


func _perform_swing(attack_origin: Vector2, target: Node2D) -> void:
	var attack_direction := (target.global_position - attack_origin).normalized()
	_swing_direction = attack_direction
	_swing_timer = SWING_VISUAL_TIME
	play_fire_feedback()
	AudioManager.play_shoot_sound("default")

	var melee_range := definition.melee_range if definition else 48.0
	var arc_degrees := definition.melee_arc_degrees if definition else 60.0
	var knockback := definition.melee_knockback if definition else 0.0
	var weapon_id := definition.id if definition else ""
	var accent := definition.vfx_accent if definition else Color.WHITE

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not _is_available_enemy(enemy):
			continue

		var enemy_node := enemy as Node2D
		var enemy_radius := 12.0
		if enemy.has_method("get_collision_radius"):
			enemy_radius = enemy.get_collision_radius()

		if not is_target_in_arc(
			attack_origin,
			attack_direction,
			enemy_node.global_position,
			enemy_radius,
			melee_range,
			arc_degrees
		):
			continue

		var final_damage := _roll_damage(get_damage())
		if enemy.has_method("take_damage"):
			enemy.take_damage(final_damage.amount)
		if knockback > 0.0 and enemy.has_method("apply_knockback"):
			var knock_dir := (enemy_node.global_position - attack_origin).normalized()
			enemy.apply_knockback(knock_dir, knockback)

		EventBus.projectile_hit.emit(enemy_node.global_position, attack_direction, accent)
		EventBus.damage_dealt.emit(
			enemy_node.global_position, final_damage.amount, final_damage.is_crit
		)
		EventBus.metrics_damage_dealt.emit(final_damage.amount, weapon_id)


func _find_melee_target(attack_origin: Vector2) -> Node2D:
	var melee_range := definition.melee_range if definition else 48.0
	var nearest: Node2D = null
	var nearest_dist_sq := INF

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not _is_available_enemy(enemy):
			continue

		var enemy_node := enemy as Node2D
		var enemy_radius := 12.0
		if enemy.has_method("get_collision_radius"):
			enemy_radius = enemy.get_collision_radius()

		var dist_sq := attack_origin.distance_squared_to(enemy_node.global_position)
		var max_reach := melee_range + enemy_radius
		if dist_sq > max_reach * max_reach:
			continue

		if dist_sq < nearest_dist_sq:
			nearest_dist_sq = dist_sq
			nearest = enemy_node

	return nearest


func _roll_damage(base_damage: int) -> Dictionary:
	var is_crit := randf() < _crit_chance
	var amount := base_damage
	if is_crit:
		amount = maxi(roundi(float(base_damage) * _crit_damage), 1)
	return {"amount": amount, "is_crit": is_crit}


func _get_player() -> CharacterBody2D:
	var controller := get_parent() as Node2D
	if controller == null:
		return null
	return controller.get_parent() as CharacterBody2D


func _draw() -> void:
	if _swing_timer <= 0.0 or definition == null:
		return

	var player := _get_player()
	if player == null:
		return

	var local_origin := to_local(player.global_position)
	var melee_range := definition.melee_range
	var arc_degrees := definition.melee_arc_degrees
	var alpha := _swing_timer / SWING_VISUAL_TIME
	var swing_color := definition.vfx_accent
	swing_color.a = 0.22 * alpha

	var start_angle := _swing_direction.angle() - deg_to_rad(arc_degrees * 0.5)
	var end_angle := _swing_direction.angle() + deg_to_rad(arc_degrees * 0.5)
	var points := PackedVector2Array([local_origin])
	var segments := maxi(int(arc_degrees / 12.0), 4)
	for segment in segments + 1:
		var t := float(segment) / float(segments)
		var angle := lerpf(start_angle, end_angle, t)
		points.append(local_origin + Vector2(cos(angle), sin(angle)) * melee_range)

	draw_colored_polygon(points, swing_color)
