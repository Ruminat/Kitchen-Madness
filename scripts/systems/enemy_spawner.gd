class_name EnemySpawner
extends Node

const EDGE_MARGIN := 20.0
const MAX_ELITE_ALIVE := 2

var wave_definition: WaveDefinition
var enemy_container: Node2D
var arena_bounds := Rect2()

var is_active := true
var _spawn_timer: Timer
var _elapsed_time := 0.0


func configure(definition: WaveDefinition, container: Node2D, bounds: Rect2) -> void:
	wave_definition = definition
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


func _spawn_enemy() -> void:
	if not is_active or enemy_container == null:
		return

	var max_enemies := wave_definition.max_enemies if wave_definition else 40
	if enemy_container.get_child_count() >= max_enemies:
		_schedule_next_spawn()
		return

	var definition := _pick_spawn_definition()
	var scene := _scene_for_definition(definition)
	if scene == null:
		_schedule_next_spawn()
		return

	var enemy := scene.instantiate() as CharacterBody2D
	enemy_container.add_child(enemy)
	enemy.global_position = _random_edge_position()
	if enemy.has_method("set_arena_bounds"):
		enemy.set_arena_bounds(arena_bounds)
	if enemy.has_method("configure") and definition:
		enemy.configure(definition)

	_schedule_next_spawn()


func _pick_spawn_definition() -> EnemyDefinition:
	var definition: EnemyDefinition = SpawnTable.pick_weighted(wave_definition.enemy_weights)
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
	if wave_definition == null:
		return null

	var non_elite_entries: Array = []
	for entry in wave_definition.enemy_weights:
		if entry is EnemySpawnEntry and entry.definition and not entry.definition.is_elite:
			non_elite_entries.append(entry)

	if non_elite_entries.is_empty():
		return null

	return SpawnTable.pick_weighted(non_elite_entries)


func _scene_for_definition(definition: EnemyDefinition) -> PackedScene:
	if definition and definition.scene:
		return definition.scene
	if wave_definition and wave_definition.fallback_enemy_scene:
		return wave_definition.fallback_enemy_scene
	return null


func _schedule_next_spawn() -> void:
	if _spawn_timer == null:
		return

	_elapsed_time += _spawn_timer.wait_time
	_spawn_timer.wait_time = _current_spawn_interval()
	_spawn_timer.start()


func _current_spawn_interval() -> float:
	var base_interval := wave_definition.spawn_interval if wave_definition else 1.4
	var multiplier := 1.0
	if wave_definition:
		var progress := _elapsed_time / maxf(wave_definition.duration, 0.01)
		multiplier = wave_definition.get_spawn_multiplier(progress)
	return base_interval / maxf(multiplier, 0.01)


func _random_edge_position() -> Vector2:
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
