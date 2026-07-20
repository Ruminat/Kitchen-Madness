class_name EntityCombat
extends RefCounted
## Shared enemy-targeting and area-damage helpers for autonomous allies (pets,
## structures, traps). Mirrors the distance-based combat used by weapons/skills so
## behavior stays consistent and DRY.


static func is_available_enemy(enemy: Node) -> bool:
	if not is_instance_valid(enemy) or not enemy is Node2D:
		return false
	if not enemy.has_method("take_damage"):
		return false
	if enemy.has_node("HealthComponent"):
		var health := enemy.get_node("HealthComponent") as HealthComponent
		if health and not health.is_alive():
			return false
	return true


## Nearest live enemy to `origin` within `max_range_px` (INF range if <= 0).
static func nearest_enemy(tree: SceneTree, origin: Vector2, max_range_px: float) -> Node2D:
	if tree == null:
		return null
	var nearest: Node2D = null
	var best := INF
	var range_sq := max_range_px * max_range_px if max_range_px > 0.0 else INF
	for enemy in tree.get_nodes_in_group("enemies"):
		if not is_available_enemy(enemy):
			continue
		var dist := origin.distance_squared_to((enemy as Node2D).global_position)
		if dist <= range_sq and dist < best:
			best = dist
			nearest = enemy
	return nearest


## Damage every live enemy within `radius_px` of `center`. Returns the number hit.
static func damage_in_radius(
	tree: SceneTree, center: Vector2, radius_px: float, damage: int, source_id: String
) -> int:
	if tree == null:
		return 0
	var radius_sq := radius_px * radius_px
	var hits := 0
	for enemy in tree.get_nodes_in_group("enemies"):
		if not is_available_enemy(enemy):
			continue
		var enemy_node := enemy as Node2D
		if center.distance_squared_to(enemy_node.global_position) > radius_sq:
			continue
		enemy.take_damage(damage)
		EventBus.metrics_damage_dealt.emit(damage, source_id)
		EventBus.damage_dealt.emit(enemy_node.global_position, damage, false)
		hits += 1
	return hits


## Single-target damage on one enemy, reported for metrics + floating text.
static func damage_target(target: Node2D, damage: int, source_id: String) -> void:
	if target == null or not target.has_method("take_damage"):
		return
	target.take_damage(damage)
	EventBus.metrics_damage_dealt.emit(damage, source_id)
	EventBus.damage_dealt.emit(target.global_position, damage, false)
