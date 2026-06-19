# GdUnit generated TestSuite
extends GdUnitTestSuite

const CHASER_DEFINITION := preload("res://resources/enemies/chaser.tres")


func before() -> void:
	get_tree().paused = false


func test_enemy_killed_spawns_death_burst() -> void:
	var manager := _create_manager()
	await _wait_ready(manager)
	var container: Node2D = manager.get_parent() as Node2D

	var enemy := CHASER_DEFINITION.scene.instantiate()
	container.add_child(enemy)
	if enemy.has_method("configure"):
		enemy.configure(CHASER_DEFINITION)
	var before := container.get_child_count()

	EventBus.enemy_killed.emit(enemy, null)

	assert_int(container.get_child_count()).is_equal(before + 1)
	var particles := container.get_child(before) as GPUParticles2D
	assert_object(particles).is_not_null()
	assert_bool(particles.one_shot).is_true()


func test_projectile_hit_spawns_impact_spark() -> void:
	var manager := _create_manager()
	await _wait_ready(manager)
	var container: Node2D = manager.get_parent() as Node2D
	var before := container.get_child_count()

	EventBus.projectile_hit.emit(Vector2(12.0, -8.0), Vector2.RIGHT, Color.CYAN)

	assert_int(container.get_child_count()).is_equal(before + 1)
	var particles := container.get_child(before) as GPUParticles2D
	assert_object(particles).is_not_null()
	assert_bool(particles.one_shot).is_true()


func test_death_burst_reuses_pool_after_finished() -> void:
	var manager := _create_manager()
	await _wait_ready(manager)
	var container: Node2D = manager.get_parent() as Node2D
	var enemy := Node2D.new()
	container.add_child(enemy)

	EventBus.enemy_killed.emit(enemy, null)
	var particles := container.get_child(container.get_child_count() - 1) as GPUParticles2D
	particles.emitting = false
	particles.finished.emit()
	await get_tree().process_frame

	EventBus.enemy_killed.emit(enemy, null)
	var reused := container.get_child(container.get_child_count() - 1) as GPUParticles2D
	assert_object(reused).is_same(particles)


func _create_manager() -> VfxManager:
	var container: Node2D = auto_free(Node2D.new()) as Node2D
	add_child(container)

	var manager: VfxManager = auto_free(VfxManager.new()) as VfxManager
	container.add_child(manager)
	manager.configure(container)
	return manager


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
