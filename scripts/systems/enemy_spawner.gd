class_name EnemySpawner
extends Node

const EDGE_MARGIN := 20.0
const MAX_ELITE_ALIVE := 2
const SPAWN_OFFSCREEN_MARGIN := 100.0

var level_definition: LevelDefinition
var enemy_container: Node2D
var arena_bounds := Rect2()
var camera_target: Node2D
var camera_focus := Vector2.ZERO
var camera_view_size := Arena.DEFAULT_VIEW_SIZE
var is_active := true
## Multiplier on the alive-enemy cap, grown by the "Bring me more" perk.
var count_multiplier := 1.0

var _has_camera_focus := false
var _spawn_timer: Timer
var _elapsed_time := 0.0


func _ready() -> void:
	EventBus.enemy_count_percent_added.connect(_on_enemy_count_percent_added)


func _on_enemy_count_percent_added(percent: float) -> void:
	count_multiplier = maxf(count_multiplier * (1.0 + percent), 0.1)


func configure(definition: LevelDefinition, container: Node2D, bounds: Rect2) -> void:
	level_definition = definition
	enemy_container = container
	arena_bounds = bounds
	is_active = true
	_elapsed_time = 0.0

	if _spawn_timer == null:
		_spawn_timer = Timer.new()
		_spawn_timer.one_shot = true
		_spawn_timer.timeout.connect(_spawn_enemy)
		add_child(_spawn_timer)
	else:
		_spawn_timer.stop()

	_spawn_timer.wait_time = _current_spawn_interval()
	_spawn_timer.start()

	_spawn_enemy()


func stop() -> void:
	is_active = false
	if _spawn_timer:
		_spawn_timer.stop()


func reset() -> void:
	is_active = true
	_elapsed_time = 0.0
	if _spawn_timer:
		_spawn_timer.wait_time = _current_spawn_interval()
		_spawn_timer.start()


func set_camera_view_size(view_size: Vector2) -> void:
	camera_view_size = view_size


func set_camera_spawn_target(focus_target: Node2D, view_size: Vector2) -> void:
	camera_target = focus_target
	camera_view_size = view_size
	_has_camera_focus = false
	if focus_target:
		camera_focus = focus_target.global_position


func set_camera_focus(world_position: Vector2) -> void:
	camera_focus = world_position
	_has_camera_focus = true


func _spawn_enemy() -> void:
	if not is_active or enemy_container == null:
		return

	var max_alive := _max_alive_enemies()
	if enemy_container.get_child_count() >= max_alive:
		_schedule_next_spawn()
		return

	var cluster_radius := level_definition.swarm_cluster_radius if level_definition else 0.0

	# Split the tick's spawns into several small groups, each dropped at its own
	# scattered anchor so enemies trickle in from different edges rather than
	# piling up in a single spot.
	for _group_index in _resolve_group_count():
		if enemy_container.get_child_count() >= max_alive:
			break

		var definition := _pick_spawn_definition()
		var scene := _scene_for_definition(definition)
		if scene == null:
			continue

		_spawn_group(definition, scene, cluster_radius, max_alive)

	_schedule_next_spawn()


func _spawn_group(
	definition: EnemyDefinition, scene: PackedScene, cluster_radius: float, max_alive: int
) -> void:
	var swarm_size := _resolve_swarm_size(definition)
	var anchor := _random_spawn_position()

	for _index in swarm_size:
		if enemy_container.get_child_count() >= max_alive:
			return

		var enemy := scene.instantiate() as CharacterBody2D
		enemy_container.add_child(enemy)
		enemy.global_position = _clamp_spawn_position(
			_cluster_spawn_position(anchor, cluster_radius)
		)
		if enemy.has_method("set_arena_bounds"):
			enemy.set_arena_bounds(arena_bounds)
		if enemy.has_method("set_target") and camera_target:
			enemy.set_target(camera_target)
		if enemy.has_method("configure") and definition:
			if enemy.has_method("configure_for_time"):
				enemy.configure_for_time(definition, _elapsed_time)
			else:
				enemy.configure(definition)


func _resolve_group_count() -> int:
	if level_definition == null:
		return 1
	return level_definition.roll_group_count()


func _max_alive_enemies() -> int:
	var base := 120
	if level_definition:
		base = level_definition.get_max_enemies(_level_progress())
	return maxi(roundi(float(base) * count_multiplier), 1)


func _resolve_swarm_size(definition: EnemyDefinition) -> int:
	if definition and definition.is_elite:
		return 1
	if level_definition == null:
		return 1

	return level_definition.roll_swarm_size()


func _cluster_spawn_position(anchor: Vector2, radius: float) -> Vector2:
	if radius <= 0.0:
		return anchor

	var offset := Vector2.from_angle(randf() * TAU) * randf_range(0.0, radius)
	return anchor + offset


func _clamp_spawn_position(position: Vector2) -> Vector2:
	return ArenaClamp.clamp_position(position, arena_bounds, EDGE_MARGIN)


func _spawn_camera_center() -> Vector2:
	if _has_camera_focus:
		return camera_focus
	if camera_target:
		return camera_target.global_position
	return Vector2.ZERO


func _pick_spawn_definition() -> EnemyDefinition:
	var definition: EnemyDefinition = SpawnTable.pick_weighted(level_definition.enemy_weights)
	if definition == null:
		return null

	if definition.is_elite and _count_alive_elites() >= MAX_ELITE_ALIVE:
		definition = _pick_non_elite_definition()

	return definition


func _count_alive_elites() -> int:
	if enemy_container == null:
		return 0

	var count := 0
	for child in enemy_container.get_children():
		if not is_instance_valid(child):
			continue

		var enemy_definition := _definition_for_enemy(child)
		if enemy_definition and enemy_definition.is_elite:
			count += 1

	return count


func _definition_for_enemy(enemy: Node) -> EnemyDefinition:
	if "definition" in enemy:
		return enemy.definition as EnemyDefinition
	if enemy.has_meta("definition"):
		return enemy.get_meta("definition") as EnemyDefinition
	return null


func _pick_non_elite_definition() -> EnemyDefinition:
	if level_definition == null:
		return null

	var non_elite_entries: Array = []
	for entry in level_definition.enemy_weights:
		if entry is EnemySpawnEntry and entry.definition and not entry.definition.is_elite:
			non_elite_entries.append(entry)

	if non_elite_entries.is_empty():
		return null

	return SpawnTable.pick_weighted(non_elite_entries)


func _scene_for_definition(definition: EnemyDefinition) -> PackedScene:
	if definition and definition.scene:
		return definition.scene
	if level_definition and level_definition.fallback_enemy_scene:
		return level_definition.fallback_enemy_scene
	return null


func _schedule_next_spawn() -> void:
	if _spawn_timer == null:
		return

	_elapsed_time += _spawn_timer.wait_time
	_spawn_timer.wait_time = _current_spawn_interval()
	_spawn_timer.start()


func _current_spawn_interval() -> float:
	var base_interval := level_definition.spawn_interval if level_definition else 1.4
	var multiplier := 1.0
	if level_definition:
		multiplier = level_definition.get_spawn_multiplier(_level_progress())
	return base_interval / maxf(multiplier, 0.01)


func _level_progress() -> float:
	if level_definition == null:
		return 0.0
	return level_definition.get_progress(_elapsed_time)


func _random_spawn_position() -> Vector2:
	var offscreen_position := _random_offscreen_position()
	if offscreen_position != Vector2.INF:
		return _clamp_spawn_position(offscreen_position)
	return _clamp_spawn_position(_random_arena_edge_position())


func _random_offscreen_position() -> Vector2:
	if camera_target == null and not _has_camera_focus:
		return Vector2.INF

	var inner_bounds := arena_bounds.grow(-EDGE_MARGIN)
	var camera_rect := Rect2(_spawn_camera_center() - camera_view_size * 0.5, camera_view_size)
	var spawn_bands := _build_spawn_bands(camera_rect, inner_bounds)
	if spawn_bands.is_empty():
		return Vector2.INF

	var band: Dictionary = spawn_bands[randi() % spawn_bands.size()]
	var position := Vector2.ZERO
	if band.axis == &"horizontal":
		position = Vector2(randf_range(band.min, band.max), band.fixed)
	else:
		position = Vector2(band.fixed, randf_range(band.min, band.max))
	return _clamp_spawn_position(position)


func _build_spawn_bands(camera_rect: Rect2, inner_bounds: Rect2) -> Array[Dictionary]:
	var bands: Array[Dictionary] = []
	var min_x := maxf(camera_rect.position.x, inner_bounds.position.x)
	var max_x := minf(camera_rect.end.x, inner_bounds.end.x)
	var min_y := maxf(camera_rect.position.y, inner_bounds.position.y)
	var max_y := minf(camera_rect.end.y, inner_bounds.end.y)

	var top_y := camera_rect.position.y - SPAWN_OFFSCREEN_MARGIN
	if top_y >= inner_bounds.position.y and min_x <= max_x:
		bands.append({"axis": &"horizontal", "fixed": top_y, "min": min_x, "max": max_x})

	var bottom_y := camera_rect.end.y + SPAWN_OFFSCREEN_MARGIN
	if bottom_y <= inner_bounds.end.y and min_x <= max_x:
		bands.append({"axis": &"horizontal", "fixed": bottom_y, "min": min_x, "max": max_x})

	var left_x := camera_rect.position.x - SPAWN_OFFSCREEN_MARGIN
	if left_x >= inner_bounds.position.x and min_y <= max_y:
		bands.append({"axis": &"vertical", "fixed": left_x, "min": min_y, "max": max_y})

	var right_x := camera_rect.end.x + SPAWN_OFFSCREEN_MARGIN
	if right_x <= inner_bounds.end.x and min_y <= max_y:
		bands.append({"axis": &"vertical", "fixed": right_x, "min": min_y, "max": max_y})

	return bands


func _random_arena_edge_position() -> Vector2:
	var side := randi() % 4
	var bounds := arena_bounds

	match side:
		0:
			return Vector2(
				randf_range(bounds.position.x + EDGE_MARGIN, bounds.end.x - EDGE_MARGIN),
				bounds.position.y + EDGE_MARGIN
			)
		1:
			return Vector2(
				randf_range(bounds.position.x + EDGE_MARGIN, bounds.end.x - EDGE_MARGIN),
				bounds.end.y - EDGE_MARGIN
			)
		2:
			return Vector2(
				bounds.position.x + EDGE_MARGIN,
				randf_range(bounds.position.y + EDGE_MARGIN, bounds.end.y - EDGE_MARGIN)
			)
		_:
			return Vector2(
				bounds.end.x - EDGE_MARGIN,
				randf_range(bounds.position.y + EDGE_MARGIN, bounds.end.y - EDGE_MARGIN)
			)
