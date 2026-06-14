class_name EnemySpawner
extends Node

const EDGE_MARGIN := 20.0

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
	_elapsed_time = 0.0

	_spawn_timer = Timer.new()
	_spawn_timer.one_shot = true
	_spawn_timer.wait_time = _current_spawn_interval()
	_spawn_timer.timeout.connect(_spawn_enemy)
	add_child(_spawn_timer)
	_spawn_timer.start()

	_spawn_enemy()


func stop() -> void:
	is_active = false
	if _spawn_timer:
		_spawn_timer.stop()


func _spawn_enemy() -> void:
	if not is_active or enemy_container == null:
		return

	var max_enemies := wave_definition.max_enemies if wave_definition else 40
	if enemy_container.get_child_count() >= max_enemies:
		_schedule_next_spawn()
		return

	var definition: EnemyDefinition = SpawnTable.pick_weighted(wave_definition.enemy_weights)
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
