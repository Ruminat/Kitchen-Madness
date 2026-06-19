class_name VfxManager
extends Node

const POOL_SIZE := 12

var _container: Node2D
var _death_pool: Array[GPUParticles2D] = []
var _impact_pool: Array[GPUParticles2D] = []


func configure(container: Node2D) -> void:
	if _container != null:
		return

	_container = container
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

	_spawn_death_burst(spawn_pos, accent)


func _on_projectile_hit(world_pos: Vector2, direction: Vector2, accent: Color) -> void:
	if _container == null:
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
