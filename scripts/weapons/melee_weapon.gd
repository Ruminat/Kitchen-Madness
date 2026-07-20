extends BaseWeapon
## Melee hit model: pick the nearest enemy within `attack_range` of the player, then
## damage every enemy inside a circle centered on that target. The weapon's design
## `area` is the *diameter* of that circle (so the radius is area / 2). No cone.

const SWING_VISUAL_TIME := 0.2

var _cooldown := 0.0
var _swing_timer := 0.0
var _hit_center := Vector2.ZERO


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
	var fire_rate := definition.fire_rate if definition else 0.8
	_cooldown = fire_rate / get_fire_rate_multiplier()


## Max distance from the player at which an enemy can be picked as the swing target
## (the design "attack range", in pixels).
func _acquire_pixels() -> float:
	if definition == null:
		return 48.0
	return StatUnits.area_to_pixels(definition.attack_range)


## Radius of the circular hit centered on the target. The weapon's design `area` is
## the diameter of that circle, scaled by the player's area multiplier.
func _hit_radius_pixels() -> float:
	if definition == null:
		return 24.0
	return StatUnits.area_to_pixels(definition.area) * 0.5 * get_area_multiplier()


func _perform_swing(attack_origin: Vector2, target: Node2D) -> void:
	_hit_center = target.global_position
	_swing_timer = SWING_VISUAL_TIME
	play_fire_feedback()
	AudioManager.play_shoot_sound("default")

	var radius := _hit_radius_pixels()
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

		var reach := radius + enemy_radius
		if _hit_center.distance_squared_to(enemy_node.global_position) > reach * reach:
			continue

		var final_damage := _roll_damage(get_damage())
		if enemy.has_method("take_damage"):
			enemy.take_damage(final_damage.amount)
		if knockback > 0.0 and enemy.has_method("apply_knockback"):
			var knock_dir := (enemy_node.global_position - attack_origin).normalized()
			enemy.apply_knockback(knock_dir, knockback)

		var hit_dir := (enemy_node.global_position - attack_origin).normalized()
		EventBus.projectile_hit.emit(enemy_node.global_position, hit_dir, accent)
		EventBus.damage_dealt.emit(
			enemy_node.global_position, final_damage.amount, final_damage.is_crit
		)
		EventBus.metrics_damage_dealt.emit(final_damage.amount, weapon_id)


func _find_melee_target(attack_origin: Vector2) -> Node2D:
	var range_px := _acquire_pixels()
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
		var max_reach := range_px + enemy_radius
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

	var alpha := _swing_timer / SWING_VISUAL_TIME
	var swing_color := definition.vfx_accent
	swing_color.a = 0.22 * alpha
	draw_circle(to_local(_hit_center), _hit_radius_pixels(), swing_color)
