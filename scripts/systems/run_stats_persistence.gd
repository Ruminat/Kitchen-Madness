class_name RunStatsPersistence
extends RefCounted

const DEFAULT_STATS_SUBDIR := "ignored/stats"
const SESSION_FILENAME_PREFIX := "stats_"

var stats_dir: String = ""
var enabled := true

var _session_file_path: String = ""


func resolve_stats_dir() -> String:
	if not stats_dir.is_empty():
		return stats_dir
	return ProjectSettings.globalize_path("res://").path_join(DEFAULT_STATS_SUBDIR)


func build_run_record(summary: Dictionary, upgrades: Array[String]) -> Dictionary:
	var aggregates: Dictionary = summary.get("aggregates", {})
	var waves: Array = summary.get("waves", [])

	return {
		"timestamp": _format_timestamp(),
		"character": summary.get("character_id", "unknown"),
		"weapons": summary.get("weapons", []).duplicate(),
		"upgrades": upgrades.duplicate(),
		"final_wave": summary.get("final_wave", 0),
		"level_reached": summary.get("level_reached", 1),
		"total_kills": aggregates.get("total_kills", 0),
		"total_damage_dealt": aggregates.get("total_damage_dealt", 0),
		"total_damage_taken": aggregates.get("total_damage_taken", 0),
		"total_gold_earned": aggregates.get("total_gold_earned", 0),
		"total_run_time": summary.get("total_run_time", 0.0),
		"run_completed": summary.get("run_completed", false),
		"end_reason": summary.get("end_reason", "unknown"),
		"waves": waves.duplicate(true),
	}


func save_run(summary: Dictionary, upgrades: Array[String]) -> Error:
	if not enabled:
		return OK

	var record := build_run_record(summary, upgrades)
	var session_path := _ensure_session_file()
	if session_path.is_empty():
		return ERR_CANT_CREATE

	var session_data := _load_session_file(session_path)
	var runs: Array = session_data.get("runs", [])
	runs.append(record)
	session_data["runs"] = runs
	session_data["last_updated"] = record["timestamp"]
	session_data["run_count"] = runs.size()

	return _write_json_file(session_path, session_data)


func reset_session() -> void:
	_session_file_path = ""


func get_session_file_path() -> String:
	return _session_file_path


func _ensure_session_file() -> String:
	if not _session_file_path.is_empty():
		return _session_file_path

	var dir_path := resolve_stats_dir()
	var dir_err := DirAccess.make_dir_recursive_absolute(dir_path)
	if dir_err != OK and dir_err != ERR_ALREADY_EXISTS:
		push_warning("RunStatsPersistence: failed to create stats dir: %s" % dir_path)
		return ""

	var filename := "%s%s.json" % [SESSION_FILENAME_PREFIX, _format_filename_timestamp()]
	_session_file_path = dir_path.path_join(filename)

	if not FileAccess.file_exists(_session_file_path):
		var initial_data := {
			"session_started": _format_timestamp(),
			"run_count": 0,
			"runs": [],
		}
		if _write_json_file(_session_file_path, initial_data) != OK:
			_session_file_path = ""
			return ""

	return _session_file_path


func _load_session_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"runs": []}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("RunStatsPersistence: failed to read %s" % path)
		return {"runs": []}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {"runs": []}


func _write_json_file(path: String, data: Dictionary) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_warning("RunStatsPersistence: failed to write %s" % path)
		return ERR_CANT_CREATE

	file.store_string(JSON.stringify(data, "\t"))
	return OK


func _format_timestamp() -> String:
	var dt := Time.get_datetime_dict_from_system()
	return (
		"%04d-%02d-%02dT%02d:%02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
	)


func _format_filename_timestamp() -> String:
	var dt := Time.get_datetime_dict_from_system()
	return (
		"%04d-%02d-%02d_%02d%02d%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second]
	)
