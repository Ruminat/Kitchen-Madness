# GdUnit generated TestSuite
extends GdUnitTestSuite

const LEVEL_01 := preload("res://resources/levels/level_01.tres")


func test_level_one_is_ten_minute_survival() -> void:
	assert_float(LEVEL_01.duration).is_equal(600.0)


func test_level_one_ramps_spawn_pressure_over_time() -> void:
	assert_float(LEVEL_01.spawn_multiplier_end).is_greater(LEVEL_01.spawn_multiplier_start)
	assert_int(LEVEL_01.max_enemies_end).is_greater(LEVEL_01.max_enemies_start)


func test_level_one_includes_full_enemy_roster() -> void:
	for enemy_id in ["chaser", "sprinter", "ant", "moth", "tank"]:
		assert_bool(_level_contains_enemy(LEVEL_01, enemy_id)).is_true()


func test_resolve_enemy_health_scales_with_elapsed_time() -> void:
	assert_int(LevelDefinition.resolve_enemy_health(18, 0.0)).is_equal(18)
	assert_int(LevelDefinition.resolve_enemy_health(18, 60.0)).is_equal(23)
	assert_int(LevelDefinition.resolve_enemy_health(50, 120.0)).is_equal(75)


func test_resolve_contact_damage_scales_with_elapsed_time() -> void:
	assert_int(LevelDefinition.resolve_contact_damage(6, 0.0)).is_equal(6)
	assert_int(LevelDefinition.resolve_contact_damage(6, 60.0)).is_equal(7)
	assert_int(LevelDefinition.resolve_contact_damage(6, 120.0)).is_equal(8)


func test_spawner_interval_shrinks_as_level_progresses() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	var level := LevelDefinition.new()
	level.duration = 100.0
	level.spawn_interval = 2.0
	level.spawn_multiplier_start = 1.0
	level.spawn_multiplier_end = 2.0
	level.spawn_multiplier_curve = 1.0
	spawner.level_definition = level

	spawner._elapsed_time = 0.0
	assert_float(spawner._current_spawn_interval()).is_equal(2.0)

	spawner._elapsed_time = 50.0
	assert_float(spawner._current_spawn_interval()).is_equal_approx(1.333333, 0.001)

	spawner._elapsed_time = 100.0
	assert_float(spawner._current_spawn_interval()).is_equal(1.0)


func test_spawner_enemy_cap_grows_as_level_progresses() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	var level := LevelDefinition.new()
	level.duration = 100.0
	level.max_enemies_start = 24
	level.max_enemies_end = 140
	spawner.level_definition = level

	spawner._elapsed_time = 0.0
	assert_int(spawner._max_alive_enemies()).is_equal(24)

	spawner._elapsed_time = 50.0
	assert_int(spawner._max_alive_enemies()).is_equal(82)

	spawner._elapsed_time = 100.0
	assert_int(spawner._max_alive_enemies()).is_equal(140)


func test_get_max_enemies_clamps_progress() -> void:
	var level := LevelDefinition.new()
	level.max_enemies_start = 10
	level.max_enemies_end = 20
	assert_int(level.get_max_enemies(-1.0)).is_equal(10)
	assert_int(level.get_max_enemies(2.0)).is_equal(20)


func _level_contains_enemy(level: LevelDefinition, enemy_id: String) -> bool:
	for entry in level.enemy_weights:
		if entry is EnemySpawnEntry and entry.definition and entry.definition.id == enemy_id:
			return true
	return false
