# GdUnit generated TestSuite
extends GdUnitTestSuite

const WAVE_01 := preload("res://resources/waves/wave_01.tres")
const WAVE_02 := preload("res://resources/waves/wave_02.tres")
const WAVE_03 := preload("res://resources/waves/wave_03.tres")


func test_authored_wave_durations_ramp_by_five_seconds() -> void:
	assert_float(WAVE_01.duration).is_equal(12.0)
	assert_float(WAVE_02.duration).is_equal(17.0)
	assert_float(WAVE_03.duration).is_equal(22.0)


func test_resolve_duration_uses_authored_values_for_first_three_waves() -> void:
	assert_float(WaveDefinition.resolve_duration(WAVE_01, 1, 3)).is_equal(12.0)
	assert_float(WaveDefinition.resolve_duration(WAVE_02, 2, 3)).is_equal(17.0)
	assert_float(WaveDefinition.resolve_duration(WAVE_03, 3, 3)).is_equal(22.0)


func test_resolve_duration_grows_after_roster_ends() -> void:
	assert_float(WaveDefinition.resolve_duration(WAVE_03, 4, 3)).is_equal(27.0)
	assert_float(WaveDefinition.resolve_duration(WAVE_03, 8, 3)).is_equal(47.0)


func test_resolve_density_multiplier_grows_ten_percent_per_wave() -> void:
	assert_float(WaveDefinition.resolve_density_multiplier(1)).is_equal(1.0)
	assert_float(WaveDefinition.resolve_density_multiplier(2)).is_equal_approx(1.1, 0.001)
	assert_float(WaveDefinition.resolve_density_multiplier(3)).is_equal_approx(1.21, 0.001)
	assert_float(WaveDefinition.resolve_density_multiplier(4)).is_equal_approx(1.331, 0.001)


func test_resolve_enemy_health_scales_with_wave_number() -> void:
	assert_int(WaveDefinition.resolve_enemy_health(18, 1)).is_equal(18)
	assert_int(WaveDefinition.resolve_enemy_health(18, 3)).is_equal(22)
	assert_int(WaveDefinition.resolve_enemy_health(50, 4)).is_equal(68)


func test_resolve_contact_damage_scales_with_wave_number() -> void:
	assert_int(WaveDefinition.resolve_contact_damage(6, 1)).is_equal(6)
	assert_int(WaveDefinition.resolve_contact_damage(6, 3)).is_equal(7)


func test_spawner_scales_density_with_wave_number() -> void:
	var spawner: EnemySpawner = auto_free(EnemySpawner.new()) as EnemySpawner
	var wave := WaveDefinition.new()
	wave.spawn_interval = 2.0
	wave.spawn_multiplier_start = 1.0
	wave.spawn_multiplier_end = 1.0
	spawner.wave_definition = wave
	spawner._wave_number = 1
	assert_float(spawner._current_spawn_interval()).is_equal(2.0)

	spawner._wave_number = 2
	assert_float(spawner._current_spawn_interval()).is_equal_approx(1.818182, 0.001)


func test_wave_manager_uses_duration_override() -> void:
	var manager: WaveManager = auto_free(WaveManager.new())
	add_child(manager)
	manager.configure(WAVE_01, 27.0)
	assert_float(manager.time_remaining).is_equal(27.0)

	manager._process(5.0)
	manager.reset()
	assert_float(manager.time_remaining).is_equal(27.0)


func test_wave_one_starts_with_chasers_only() -> void:
	assert_int(WAVE_01.enemy_weights.size()).is_equal(1)
	var entry := WAVE_01.enemy_weights[0] as EnemySpawnEntry
	assert_str(entry.definition.id).is_equal("chaser")
	assert_int(WAVE_01.max_enemies).is_greater_equal(24)
	assert_float(WAVE_01.spawn_multiplier_start).is_equal(1.0)


func test_each_wave_gently_increases_density_and_variety() -> void:
	assert_int(WAVE_01.enemy_weights.size()).is_less(WAVE_02.enemy_weights.size())
	assert_int(WAVE_02.enemy_weights.size()).is_less(WAVE_03.enemy_weights.size())
	assert_int(WAVE_01.max_enemies).is_less(WAVE_02.max_enemies)
	assert_int(WAVE_02.max_enemies).is_less(WAVE_03.max_enemies)
	assert_float(WAVE_01.spawn_interval).is_greater(WAVE_02.spawn_interval)
	assert_float(WAVE_02.spawn_interval).is_greater(WAVE_03.spawn_interval)


func test_each_wave_increases_swarm_size() -> void:
	assert_int(WAVE_01.swarm_size_max).is_less(WAVE_02.swarm_size_max)
	assert_int(WAVE_02.swarm_size_max).is_less(WAVE_03.swarm_size_max)


func test_wave_two_includes_ants() -> void:
	assert_bool(_wave_contains_enemy(WAVE_02, "ant")).is_true()


func test_wave_three_includes_moths() -> void:
	assert_bool(_wave_contains_enemy(WAVE_03, "moth")).is_true()


func _wave_contains_enemy(wave: WaveDefinition, enemy_id: String) -> bool:
	for entry in wave.enemy_weights:
		if entry is EnemySpawnEntry and entry.definition and entry.definition.id == enemy_id:
			return true
	return false
