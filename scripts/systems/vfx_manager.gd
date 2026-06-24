class_name VfxManager
extends Node

const POOL_SIZE := 12
const MAX_DEATH_BURSTS_PER_FRAME := 8
const MAX_IMPACT_SPARKS_PER_FRAME := 14
const VFX_SCREEN_MARGIN := 96.0

var _container: Node2D
var _camera: Camera2D
var _get_view_size: Callable
var _death_pool: Array[GPUParticles2D] = []
var _impact_pool: Array[GPUParticles2D] = []
var _budget_frame := -1
var _death_bursts_this_frame := 0
var _impact_sparks_this_frame := 0


func configure(
	container: Node2D, camera: Camera2D = null, get_view_size: Callable = Callable()
) -> void:
	if _container != null:
		return

	_container = container
	_camera = camera
	_get_view_size = get_view_size
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.projectile_hit.connect(_on_projectile_hit)


func _on_enemy_killed(enemy: Node, _killer: Node) -> void:
	if _container == null or not is_instance_valid(enemy):
		return

	var spawn_pos := (enemy as Node2D).global_position
	var accent := Color(0.9, 0.35, 0.2, 1.0)
	if "definition" in enemy:
		var enemy_definition := enemy.definition as EnemyDefinition
		if enemy_definition:
			accent = enemy_definition.color

	if not _is_in_vfx_range(spawn_pos) or not _try_use_budget(true):
		return

	_spawn_death_burst(spawn_pos, accent)


func _on_projectile_hit(world_pos: Vector2, direction: Vector2, accent: Color) -> void:
	if _container == null:
		return

	if not _is_in_vfx_range(world_pos) or not _try_use_budget(false):
		return

	_spawn_impact_spark(world_pos, direction, accent)


func _spawn_death_burst(world_pos: Vector2, accent: Color) -> void:
	var particles := _acquire(_death_pool)
	VfxLibrary.configure_death_burst(particles, accent)
	_play_one_shot(particles, world_pos, _death_pool)


func _spawn_impact_spark(world_pos: Vector2, direction: Vector2, accent: Color) -> void:
	var particles := _acquire(_impact_pool)
	VfxLibrary.configure_impact_spark(particles, accent, direction)
	_play_one_shot(particles, world_pos, _impact_pool)


func _play_one_shot(
	particles: GPUParticles2D, world_pos: Vector2, pool: Array[GPUParticles2D]
) -> void:
	if particles.get_parent() != _container:
		if particles.get_parent():
			particles.get_parent().remove_child(particles)
		_container.add_child(particles)

	particles.global_position = world_pos
	particles.finished.connect(_release.bind(particles, pool), CONNECT_ONE_SHOT)
	particles.restart()


func _acquire(pool: Array[GPUParticles2D]) -> GPUParticles2D:
	while not pool.is_empty():
		var particles: GPUParticles2D = pool.pop_back()
		if is_instance_valid(particles):
			return particles

	return GPUParticles2D.new()


func _release(particles: GPUParticles2D, pool: Array[GPUParticles2D]) -> void:
	if not is_instance_valid(particles):
		return

	particles.emitting = false
	if pool.size() < POOL_SIZE:
		if particles.get_parent():
			particles.get_parent().remove_child(particles)
		pool.append(particles)
	else:
		particles.queue_free()


func _try_use_budget(is_death_burst: bool) -> bool:
	var frame := Engine.get_process_frames()
	if frame != _budget_frame:
		_budget_frame = frame
		_death_bursts_this_frame = 0
		_impact_sparks_this_frame = 0

	if is_death_burst:
		if _death_bursts_this_frame >= MAX_DEATH_BURSTS_PER_FRAME:
			return false
		_death_bursts_this_frame += 1
		return true

	if _impact_sparks_this_frame >= MAX_IMPACT_SPARKS_PER_FRAME:
		return false
	_impact_sparks_this_frame += 1
	return true


func _is_in_vfx_range(world_pos: Vector2) -> bool:
	if _camera == null or not is_instance_valid(_camera):
		return true

	var view_size := _resolve_view_size()
	var camera_rect := Rect2(_camera.global_position - view_size * 0.5, view_size)
	return camera_rect.grow(VFX_SCREEN_MARGIN).has_point(world_pos)


func _resolve_view_size() -> Vector2:
	if _get_view_size.is_valid():
		var value: Variant = _get_view_size.call()
		if value is Vector2:
			return value

	var viewport := _camera.get_viewport()
	if viewport == null:
		return Arena.DEFAULT_VIEW_SIZE

	var viewport_size := viewport.get_visible_rect().size
	return Vector2(
		viewport_size.x / maxf(_camera.zoom.x, 0.01), viewport_size.y / maxf(_camera.zoom.y, 0.01)
	)
