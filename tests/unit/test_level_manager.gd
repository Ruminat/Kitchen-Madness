# GdUnit generated TestSuite
extends GdUnitTestSuite


func before() -> void:
	get_tree().paused = false


func after() -> void:
	get_tree().paused = false


func test_configure_sets_duration_and_resets_elapsed() -> void:
	var manager: LevelManager = auto_free(LevelManager.new())
	add_child(manager)
	var level := LevelDefinition.new()
	level.duration = 600.0
	manager.configure(level)
	assert_float(manager.elapsed_time).is_equal(0.0)
	assert_float(manager.get_duration()).is_equal(600.0)
	assert_float(manager.get_time_remaining()).is_equal(600.0)


func test_level_completes_when_timer_runs_out() -> void:
	var manager: LevelManager = auto_free(LevelManager.new())
	add_child(manager)
	var level := LevelDefinition.new()
	level.duration = 2.0
	manager.configure(level)
	manager._process(2.1)
	assert_bool(manager.is_complete).is_true()
	assert_float(manager.get_time_remaining()).is_equal(0.0)


func test_level_completed_emits_event_bus_signal() -> void:
	var manager: LevelManager = auto_free(LevelManager.new())
	add_child(manager)
	var level := LevelDefinition.new()
	level.duration = 1.0
	manager.configure(level)

	var completed: Array[bool] = [false]
	var handler := func() -> void: completed[0] = true
	EventBus.level_completed.connect(handler)
	manager._process(1.5)
	EventBus.level_completed.disconnect(handler)

	assert_bool(completed[0]).is_true()


func test_level_time_changed_reports_elapsed_and_remaining() -> void:
	var manager: LevelManager = auto_free(LevelManager.new())
	add_child(manager)
	var level := LevelDefinition.new()
	level.duration = 10.0
	manager.configure(level)

	var captured: Array[float] = [-1.0, -1.0]
	var handler := func(elapsed: float, remaining: float) -> void:
		captured[0] = elapsed
		captured[1] = remaining
	EventBus.level_time_changed.connect(handler)
	manager._process(4.0)
	EventBus.level_time_changed.disconnect(handler)

	assert_float(captured[0]).is_equal(4.0)
	assert_float(captured[1]).is_equal(6.0)


func test_pause_stops_timer() -> void:
	var manager: LevelManager = auto_free(LevelManager.new())
	add_child(manager)
	var level := LevelDefinition.new()
	level.duration = 10.0
	manager.configure(level)
	manager.pause()
	manager._process(5.0)
	assert_float(manager.elapsed_time).is_equal(0.0)
	assert_bool(manager.is_complete).is_false()


func test_resume_continues_timer() -> void:
	var manager: LevelManager = auto_free(LevelManager.new())
	add_child(manager)
	var level := LevelDefinition.new()
	level.duration = 10.0
	manager.configure(level)
	manager.pause()
	manager.resume()
	manager._process(3.0)
	assert_float(manager.elapsed_time).is_equal(3.0)


func test_reset_restores_timer_and_unpauses() -> void:
	var manager: LevelManager = auto_free(LevelManager.new()) as LevelManager
	add_child(manager)
	var level := LevelDefinition.new()
	level.duration = 30.0
	manager.configure(level)
	manager._process(12.0)
	manager.pause()
	manager.is_complete = true

	manager.reset()

	assert_bool(manager.is_complete).is_false()
	assert_bool(manager.is_paused).is_false()
	assert_float(manager.elapsed_time).is_equal(0.0)


func test_progress_reflects_elapsed_fraction() -> void:
	var manager: LevelManager = auto_free(LevelManager.new())
	add_child(manager)
	var level := LevelDefinition.new()
	level.duration = 100.0
	manager.configure(level)
	manager._process(25.0)
	assert_float(manager.get_progress()).is_equal_approx(0.25, 0.001)


func test_level_spawn_multiplier_ramps_with_curve() -> void:
	var level := LevelDefinition.new()
	level.spawn_multiplier_start = 2.0
	level.spawn_multiplier_end = 8.0
	level.spawn_multiplier_curve = 2.0

	assert_float(level.get_spawn_multiplier(0.0)).is_equal(2.0)
	assert_float(level.get_spawn_multiplier(0.5)).is_equal(3.5)
	assert_float(level.get_spawn_multiplier(1.0)).is_equal(8.0)
