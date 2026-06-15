# GdUnit generated TestSuite
extends GdUnitTestSuite


func before() -> void:
	get_tree().paused = false


func after() -> void:
	get_tree().paused = false


func test_configure_sets_duration() -> void:
	var manager: WaveManager = auto_free(WaveManager.new())
	add_child(manager)
	var wave := WaveDefinition.new()
	wave.duration = 12.0
	manager.configure(wave)
	assert_float(manager.time_remaining).is_equal(12.0)


func test_wave_completes_when_timer_reaches_zero() -> void:
	var manager: WaveManager = auto_free(WaveManager.new())
	add_child(manager)
	var wave := WaveDefinition.new()
	wave.duration = 2.0
	manager.configure(wave)
	manager._process(2.1)
	assert_bool(manager.is_complete).is_true()
	assert_float(manager.time_remaining).is_less_equal(0.0)


func test_pause_stops_timer() -> void:
	var manager: WaveManager = auto_free(WaveManager.new())
	add_child(manager)
	var wave := WaveDefinition.new()
	wave.duration = 10.0
	manager.configure(wave)
	manager.pause()
	manager._process(5.0)
	assert_float(manager.time_remaining).is_equal(10.0)
	assert_bool(manager.is_complete).is_false()


func test_reset_restores_timer_and_unpauses() -> void:
	var manager: WaveManager = auto_free(WaveManager.new()) as WaveManager
	add_child(manager)
	var wave := WaveDefinition.new()
	wave.duration = 30.0
	manager.configure(wave)
	manager._process(12.0)
	manager.pause()
	manager.is_complete = true

	manager.reset()

	assert_bool(manager.is_complete).is_false()
	assert_bool(manager.is_paused).is_false()
	assert_float(manager.time_remaining).is_equal(30.0)


func test_wave_spawn_multiplier_ramps_with_curve() -> void:
	var wave := WaveDefinition.new()
	wave.spawn_multiplier_start = 2.0
	wave.spawn_multiplier_end = 8.0
	wave.spawn_multiplier_curve = 2.0

	assert_float(wave.get_spawn_multiplier(0.0)).is_equal(2.0)
	assert_float(wave.get_spawn_multiplier(0.5)).is_equal(3.5)
	assert_float(wave.get_spawn_multiplier(1.0)).is_equal(8.0)
