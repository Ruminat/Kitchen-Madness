# GdUnit generated TestSuite
extends GdUnitTestSuite

const RunStatsPersistence = preload("res://scripts/systems/run_stats_persistence.gd")
const TEST_STATS_DIR := "user://test_run_stats"


func before_test() -> void:
	_clear_test_dir()


func after_test() -> void:
	_clear_test_dir()


func test_build_run_record_maps_summary_fields() -> void:
	var persistence := RunStatsPersistence.new()
	var summary := {
		"character_id": "chef",
		"final_wave": 3,
		"level_reached": 7,
		"total_run_time": 52.5,
		"run_completed": false,
		"end_reason": "death",
		"aggregates":
		{
			"total_kills": 40,
			"total_damage_dealt": 900,
			"total_damage_taken": 55,
			"total_gold_earned": 18,
		},
		"waves": [{"wave_number": 1, "duration_seconds": 12.0}],
	}
	var upgrades: Array[String] = ["damage_boost", "crit_chance"]

	var record := persistence.build_run_record(summary, upgrades)

	assert_str(record.get("character", "")).is_equal("chef")
	assert_array(record.get("weapons", [])).is_equal([])
	assert_array(record.get("upgrades", [])).is_equal(upgrades)
	assert_int(record.get("final_wave", 0)).is_equal(3)
	assert_int(record.get("level_reached", 0)).is_equal(7)
	assert_int(record.get("total_kills", 0)).is_equal(40)
	assert_int(record.get("total_damage_dealt", 0)).is_equal(900)
	assert_int(record.get("total_damage_taken", 0)).is_equal(55)
	assert_int(record.get("total_gold_earned", 0)).is_equal(18)
	assert_float(record.get("total_run_time", 0.0)).is_equal(52.5)
	assert_str(record.get("end_reason", "")).is_equal("death")


func test_save_run_creates_session_file_and_appends_runs() -> void:
	var persistence: RunStatsPersistence = _create_test_persistence()
	var summary_a := _sample_summary("chef", 1)
	var summary_b := _sample_summary("goblin", 2)

	assert_int(persistence.save_run(summary_a, ["max_health"])).is_equal(OK)
	assert_int(persistence.save_run(summary_b, [])).is_equal(OK)

	var session_path: String = persistence.get_session_file_path()
	assert_str(session_path).is_not_empty()
	assert_bool(FileAccess.file_exists(session_path)).is_true()

	var session_data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(session_path))
	assert_int(int(session_data.get("run_count", 0))).is_equal(2)

	var runs: Array = session_data.get("runs", [])
	assert_int(runs.size()).is_equal(2)
	assert_str(runs[0].get("character", "")).is_equal("chef")
	assert_str(runs[1].get("character", "")).is_equal("goblin")


func test_save_run_disabled_skips_write() -> void:
	var persistence: RunStatsPersistence = _create_test_persistence()
	persistence.enabled = false

	assert_int(persistence.save_run(_sample_summary("chef", 1), [])).is_equal(OK)
	assert_str(persistence.get_session_file_path()).is_empty()


func test_balance_metrics_aggregates_totals_across_waves() -> void:
	var metrics := auto_free(BalanceMetrics.new()) as BalanceMetrics
	metrics.start_run("chef")

	metrics.start_wave(1, 1)
	metrics.record_kill(&"chaser")
	metrics.record_damage_dealt(50, "kitchen_knife")
	metrics.record_damage_taken(10)
	metrics.record_gold_earned(3)
	metrics.end_wave(2)

	metrics.start_wave(2, 2)
	metrics.record_kill(&"sprinter")
	metrics.record_kill(&"sprinter")
	metrics.record_damage_dealt(30, "kitchen_knife")
	metrics.record_damage_taken(5)
	metrics.record_gold_earned(2)
	metrics.end_wave(3)

	var aggregates: Dictionary = metrics.get_run_summary().get("aggregates", {})
	assert_int(aggregates.get("total_kills", 0)).is_equal(3)
	assert_int(aggregates.get("total_damage_dealt", 0)).is_equal(80)
	assert_int(aggregates.get("total_damage_taken", 0)).is_equal(15)
	assert_int(aggregates.get("total_gold_earned", 0)).is_equal(5)


func _create_test_persistence() -> RunStatsPersistence:
	var persistence: RunStatsPersistence = RunStatsPersistence.new()
	persistence.stats_dir = ProjectSettings.globalize_path(TEST_STATS_DIR)
	persistence.reset_session()
	return persistence


func _sample_summary(character_id: String, final_wave: int) -> Dictionary:
	return {
		"character_id": character_id,
		"final_wave": final_wave,
		"level_reached": 2,
		"total_run_time": 10.0,
		"run_completed": false,
		"end_reason": "death",
		"weapons": ["kitchen_knife"],
		"aggregates":
		{
			"total_kills": 5,
			"total_damage_dealt": 100,
			"total_damage_taken": 12,
			"total_gold_earned": 4,
		},
		"waves": [{"wave_number": final_wave, "duration_seconds": 10.0}],
	}


func _clear_test_dir() -> void:
	var dir_path := ProjectSettings.globalize_path(TEST_STATS_DIR)
	if DirAccess.dir_exists_absolute(dir_path):
		_remove_dir_recursive(dir_path)


func _remove_dir_recursive(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	dir.list_dir_begin()
	var entry_name := dir.get_next()
	while entry_name != "":
		var entry_path := path.path_join(entry_name)
		if dir.current_is_dir():
			_remove_dir_recursive(entry_path)
		else:
			DirAccess.remove_absolute(entry_path)
		entry_name = dir.get_next()
	dir.list_dir_end()
	DirAccess.remove_absolute(path)
