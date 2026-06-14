# GdUnit generated TestSuite
extends GdUnitTestSuite


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
	wave.fallback_enemy_scene = preload("res://scenes/enemy/enemy.tscn")

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
