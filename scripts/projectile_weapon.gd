extends Node2D

const FIRE_COOLDOWN := 0.45

@export var projectile_scene: PackedScene

var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)
var _cooldown := 0.0


func _process(delta: float) -> void:
	var player := get_parent()
	if player != null and "health" in player and player.health <= 0:
		return

	_cooldown -= delta
	if _cooldown > 0.0:
		return

	var target := _find_nearest_enemy()
	if target == null:
		return

	_fire_at(target)
	_cooldown = FIRE_COOLDOWN


func set_arena_bounds(bounds: Rect2) -> void:
	arena_bounds = bounds


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
	var projectile := projectile_scene.instantiate()
	var direction := (target.global_position - global_position).normalized()
	projectile.setup(direction, arena_bounds)
	get_tree().current_scene.get_node("ProjectileContainer").add_child(projectile)
	projectile.global_position = global_position
