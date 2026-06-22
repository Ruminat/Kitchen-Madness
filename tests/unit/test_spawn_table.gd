# GdUnit generated TestSuite
extends GdUnitTestSuite

const ENEMY_SCENE := preload("res://scenes/enemy/enemy.tscn")
const CHASER_DEF := preload("res://resources/enemies/chaser.tres")
const TANK_DEF := preload("res://resources/enemies/tank.tres")


func test_empty_entries_returns_null() -> void:
	assert_object(SpawnTable.pick_weighted([], 0)).is_null()


func test_pick_weighted_respects_roll() -> void:
	var chaser := EnemyDefinition.new()
	chaser.id = "chaser"
	var tank := EnemyDefinition.new()
	tank.id = "tank"

	var chaser_entry := EnemySpawnEntry.new()
	chaser_entry.definition = chaser
	chaser_entry.weight = 1
	var tank_entry := EnemySpawnEntry.new()
	tank_entry.definition = tank
	tank_entry.weight = 9

	var entries: Array = [chaser_entry, tank_entry]
	assert_str(SpawnTable.pick_weighted(entries, 0).id).is_equal("chaser")
	assert_str(SpawnTable.pick_weighted(entries, 1).id).is_equal("tank")
	assert_str(SpawnTable.pick_weighted(entries, 9).id).is_equal("tank")


func test_spawner_respects_max_enemy_cap() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new())
	add_child(spawner)
	var container: Node2D = auto_free(Node2D.new())
	add_child(container)

	var wave := WaveDefinition.new()
	wave.max_enemies = 2
	wave.spawn_interval = 999.0
	wave.fallback_enemy_scene = ENEMY_SCENE

	spawner.configure(wave, container, Rect2(-440.0, -240.0, 880.0, 480.0))
	spawner._spawn_enemy()
	spawner._spawn_enemy()
	assert_int(container.get_child_count()).is_equal(2)


func test_spawner_scales_interval_with_wave_multiplier() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	var wave := WaveDefinition.new()
	wave.duration = 60.0
	wave.spawn_interval = 1.4
	wave.spawn_multiplier_start = 2.0
	wave.spawn_multiplier_end = 8.0
	wave.spawn_multiplier_curve = 2.0
	spawner.wave_definition = wave

	assert_float(spawner._current_spawn_interval()).is_equal(0.7)

	spawner._elapsed_time = 60.0
	assert_float(spawner._current_spawn_interval()).is_equal(0.175)


func test_spawner_reconfigure_reuses_spawn_timer() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	add_child(spawner)
	var container: Node2D = auto_free(Node2D.new()) as Node2D
	add_child(container)

	var wave_one := WaveDefinition.new()
	wave_one.spawn_interval = 2.0
	wave_one.fallback_enemy_scene = ENEMY_SCENE
	var wave_two := WaveDefinition.new()
	wave_two.spawn_interval = 1.0
	wave_two.fallback_enemy_scene = ENEMY_SCENE

	spawner.configure(wave_one, container, Rect2(-440.0, -240.0, 880.0, 480.0))
	var timer := spawner._spawn_timer
	spawner.configure(wave_two, container, Rect2(-440.0, -240.0, 880.0, 480.0))

	assert_object(spawner._spawn_timer).is_same(timer)
	assert_float(spawner._spawn_timer.wait_time).is_equal(1.0)


func test_spawner_picks_positions_outside_camera_view() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	var target: Node2D = auto_free(Node2D.new()) as Node2D
	add_child(spawner)
	add_child(target)
	target.global_position = Vector2.ZERO

	var container: Node2D = auto_free(Node2D.new()) as Node2D
	add_child(container)
	var bounds := Rect2(-1320.0, -720.0, 2640.0, 1440.0)
	var view_size := Vector2(880.0, 480.0)
	spawner.set_camera_spawn_target(target, view_size)
	spawner.set_camera_focus(target.global_position)
	spawner.configure(WaveDefinition.new(), container, bounds)
	var camera_rect := Rect2(spawner.camera_focus - view_size * 0.5, view_size)
	var inner_bounds := bounds.grow(-EnemySpawner.EDGE_MARGIN)
	var margin := EnemySpawner.SPAWN_OFFSCREEN_MARGIN

	for _attempt in 20:
		var spawn_position: Vector2 = spawner._random_offscreen_position()
		assert_bool(inner_bounds.has_point(spawn_position)).is_true()
		assert_bool(camera_rect.has_point(spawn_position)).is_false()
		(
			assert_bool(_distance_outside_camera_rect(spawn_position, camera_rect) >= margin - 0.01)
			. is_true()
		)


func test_spawner_builds_four_spawn_bands_at_map_center() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	var bounds := Rect2(-1320.0, -720.0, 2640.0, 1440.0)
	var view_size := Vector2(880.0, 480.0)
	var camera_rect := Rect2(-view_size * 0.5, view_size)
	var inner_bounds := bounds.grow(-EnemySpawner.EDGE_MARGIN)

	var bands: Array[Dictionary] = spawner._build_spawn_bands(camera_rect, inner_bounds)
	assert_int(bands.size()).is_equal(4)


func _distance_outside_camera_rect(position: Vector2, camera_rect: Rect2) -> float:
	if camera_rect.has_point(position):
		return 0.0

	var dx := 0.0
	if position.x < camera_rect.position.x:
		dx = camera_rect.position.x - position.x
	elif position.x > camera_rect.end.x:
		dx = position.x - camera_rect.end.x

	var dy := 0.0
	if position.y < camera_rect.position.y:
		dy = camera_rect.position.y - position.y
	elif position.y > camera_rect.end.y:
		dy = position.y - camera_rect.end.y

	return maxf(dx, dy)


func test_spawner_falls_back_to_arena_edge_without_camera_target() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	spawner.arena_bounds = Rect2(-1320.0, -720.0, 2640.0, 1440.0)

	assert_vector(spawner._random_offscreen_position()).is_equal(Vector2.INF)
	assert_bool(spawner.arena_bounds.has_point(spawner._random_spawn_position())).is_true()


func test_spawner_swarm_spawns_multiple_enemies() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	add_child(spawner)
	var container: Node2D = auto_free(Node2D.new()) as Node2D
	add_child(container)

	var chaser_entry := EnemySpawnEntry.new()
	chaser_entry.definition = CHASER_DEF
	chaser_entry.weight = 1

	var wave := WaveDefinition.new()
	wave.enemy_weights = [chaser_entry]
	wave.fallback_enemy_scene = ENEMY_SCENE
	wave.swarm_size_min = 4
	wave.swarm_size_max = 4

	spawner.configure(wave, container, Rect2(-440.0, -240.0, 880.0, 480.0))
	spawner._spawn_enemy()
	assert_int(container.get_child_count()).is_equal(4)


func test_spawner_cluster_position_stays_within_radius() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	spawner.arena_bounds = Rect2(-440.0, -240.0, 880.0, 480.0)
	var anchor := Vector2(100.0, 50.0)
	var radius := 30.0

	for _attempt in 20:
		var position := spawner._cluster_spawn_position(anchor, radius)
		assert_float(position.distance_to(anchor)).is_less_equal(radius + 0.01)


func test_spawner_clamps_spawn_positions_to_arena_bounds() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	spawner.arena_bounds = Rect2(-1320.0, -720.0, 2640.0, 1440.0)
	var inner_bounds := spawner.arena_bounds.grow(-EnemySpawner.EDGE_MARGIN)

	for _attempt in 20:
		var position := spawner._clamp_spawn_position(Vector2(9999.0, -9999.0))
		assert_bool(inner_bounds.has_point(position)).is_true()


func test_spawner_swarm_respects_alive_cap() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	add_child(spawner)
	var container: Node2D = auto_free(Node2D.new()) as Node2D
	add_child(container)

	var chaser_entry := EnemySpawnEntry.new()
	chaser_entry.definition = CHASER_DEF
	chaser_entry.weight = 1

	var wave := WaveDefinition.new()
	wave.max_enemies = 1
	wave.enemy_weights = [chaser_entry]
	wave.fallback_enemy_scene = ENEMY_SCENE
	wave.swarm_size_min = 6
	wave.swarm_size_max = 6

	spawner.configure(wave, container, Rect2(-440.0, -240.0, 880.0, 480.0))
	spawner._spawn_enemy()
	assert_int(container.get_child_count()).is_equal(3)


func test_spawner_elite_swarm_spawns_one_enemy() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	add_child(spawner)
	var container: Node2D = auto_free(Node2D.new()) as Node2D
	add_child(container)

	var tank_entry := EnemySpawnEntry.new()
	tank_entry.definition = TANK_DEF
	tank_entry.weight = 1

	var wave := WaveDefinition.new()
	wave.enemy_weights = [tank_entry]
	wave.fallback_enemy_scene = ENEMY_SCENE
	wave.swarm_size_min = 5
	wave.swarm_size_max = 5

	spawner.configure(wave, container, Rect2(-440.0, -240.0, 880.0, 480.0))
	spawner._spawn_enemy()
	assert_int(container.get_child_count()).is_equal(1)


func test_wave_definition_roll_swarm_size_respects_bounds() -> void:
	var wave := WaveDefinition.new()
	wave.swarm_size_min = 3
	wave.swarm_size_max = 6

	for _attempt in 30:
		var size := wave.roll_swarm_size()
		assert_int(size).is_greater_equal(3)
		assert_int(size).is_less_equal(6)


func test_wave_definition_average_swarm_size() -> void:
	var wave := WaveDefinition.new()
	wave.swarm_size_min = 2
	wave.swarm_size_max = 4
	assert_float(wave.average_swarm_size()).is_equal(3.0)


func test_spawner_caps_elite_enemies_at_two() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	add_child(spawner)
	var container: Node2D = auto_free(Node2D.new()) as Node2D
	add_child(container)

	var chaser := EnemyDefinition.new()
	chaser.id = "chaser"
	var tank := EnemyDefinition.new()
	tank.id = "tank"
	tank.is_elite = true

	var chaser_entry := EnemySpawnEntry.new()
	chaser_entry.definition = chaser
	chaser_entry.weight = 1
	var tank_entry := EnemySpawnEntry.new()
	tank_entry.definition = tank
	tank_entry.weight = 99

	var wave := WaveDefinition.new()
	wave.enemy_weights = [chaser_entry, tank_entry]
	wave.fallback_enemy_scene = ENEMY_SCENE

	spawner.configure(wave, container, Rect2(-440.0, -240.0, 880.0, 480.0))
	_add_elite_stub(container, tank)
	_add_elite_stub(container, tank)

	for _attempt in 20:
		var picked := spawner._pick_spawn_definition()
		assert_object(picked).is_not_null()
		assert_bool(picked.is_elite).is_false()


func _add_elite_stub(container: Node2D, definition: EnemyDefinition) -> void:
	var stub := Node2D.new()
	stub.set_meta("definition", definition)
	stub.set("definition", definition)
	container.add_child(stub)
