class_name BalanceMetrics
extends Node

## Tracks runtime combat and economy metrics for balancing analysis.

signal metrics_report_ready(report: Dictionary)


class WaveMetrics:
	var wave_number: int = 0
	var duration_seconds: float = 0.0
	var kills_by_type: Dictionary = {}
	var total_kills: int = 0
	var damage_dealt: int = 0
	var damage_taken: int = 0
	var damage_by_weapon: Dictionary = {}
	var xp_collected: int = 0
	var gold_earned: int = 0
	var player_level_start: int = 0
	var player_level_end: int = 0
	var health_pickups_collected: int = 0

	func to_dictionary() -> Dictionary:
		return {
			"wave_number": wave_number,
			"duration_seconds": duration_seconds,
			"kills_by_type": kills_by_type.duplicate(),
			"total_kills": total_kills,
			"damage_dealt": damage_dealt,
			"damage_taken": damage_taken,
			"damage_by_weapon": damage_by_weapon.duplicate(),
			"xp_collected": xp_collected,
			"gold_earned": gold_earned,
			"player_level_start": player_level_start,
			"player_level_end": player_level_end,
			"health_pickups_collected": health_pickups_collected,
			"effective_dps": _calculate_effective_dps(),
			"kills_per_minute": _calculate_kills_per_minute(),
			"gold_per_minute": _calculate_gold_per_minute(),
		}

	func _calculate_effective_dps() -> float:
		if duration_seconds <= 0.0:
			return 0.0
		return float(damage_dealt) / duration_seconds

	func _calculate_kills_per_minute() -> float:
		if duration_seconds <= 0.0:
			return 0.0
		return float(total_kills) / duration_seconds * 60.0

	func _calculate_gold_per_minute() -> float:
		if duration_seconds <= 0.0:
			return 0.0
		return float(gold_earned) / duration_seconds * 60.0


class RunMetrics:
	var waves: Array[WaveMetrics] = []
	var total_run_time: float = 0.0
	var character_id: String = ""
	var run_completed: bool = false

	func add_wave(wave: WaveMetrics) -> void:
		waves.append(wave)
		total_run_time += wave.duration_seconds

	func get_aggregates() -> Dictionary:
		var totals := {
			"total_kills": 0,
			"total_damage_dealt": 0,
			"total_damage_taken": 0,
			"total_gold_earned": 0,
		}
		for wave in waves:
			totals["total_kills"] += wave.total_kills
			totals["total_damage_dealt"] += wave.damage_dealt
			totals["total_damage_taken"] += wave.damage_taken
			totals["total_gold_earned"] += wave.gold_earned
		return totals

	func to_dictionary() -> Dictionary:
		var wave_summaries: Array[Dictionary] = []
		for wave in waves:
			wave_summaries.append(wave.to_dictionary())

		return {
			"character_id": character_id,
			"total_run_time": total_run_time,
			"waves_completed": waves.size(),
			"run_completed": run_completed,
			"aggregates": get_aggregates(),
			"waves": wave_summaries,
		}


var _current_wave: WaveMetrics = null
var _current_run: RunMetrics = null
var _is_tracking: bool = false
var _wave_start_ticks: int = 0


func start_run(character_id: String) -> void:
	_current_run = RunMetrics.new()
	_current_run.character_id = character_id
	_is_tracking = true


func end_run(completed: bool = false) -> void:
	if _current_run == null:
		return
	_current_run.run_completed = completed
	_is_tracking = false


func get_run_summary() -> Dictionary:
	if _current_run == null:
		return {}
	return _current_run.to_dictionary()


func start_wave(wave_number: int, player_level: int) -> void:
	if not _is_tracking:
		return

	_current_wave = WaveMetrics.new()
	_current_wave.wave_number = wave_number
	_current_wave.player_level_start = player_level
	_wave_start_ticks = Time.get_ticks_msec()


func end_wave(player_level: int) -> Dictionary:
	if not _is_tracking or _current_wave == null:
		return {}

	_current_wave.player_level_end = player_level
	_current_wave.duration_seconds = _calculate_wave_duration()

	var summary := _current_wave.to_dictionary()
	if _current_run != null:
		_current_run.add_wave(_current_wave)

	metrics_report_ready.emit(summary)
	return summary


func record_kill(enemy_type: StringName) -> void:
	if _current_wave == null:
		return

	var type_key := String(enemy_type)
	if not _current_wave.kills_by_type.has(type_key):
		_current_wave.kills_by_type[type_key] = 0
	_current_wave.kills_by_type[type_key] += 1
	_current_wave.total_kills += 1


func record_damage_dealt(amount: int, weapon_id: String = "") -> void:
	if _current_wave == null:
		return

	_current_wave.damage_dealt += amount
	if not weapon_id.is_empty():
		if not _current_wave.damage_by_weapon.has(weapon_id):
			_current_wave.damage_by_weapon[weapon_id] = 0
		_current_wave.damage_by_weapon[weapon_id] += amount


func record_damage_taken(amount: int) -> void:
	if _current_wave == null:
		return

	_current_wave.damage_taken += amount


func record_xp_collected(amount: int) -> void:
	if _current_wave == null:
		return

	_current_wave.xp_collected += amount


func record_gold_earned(amount: int) -> void:
	if _current_wave == null:
		return

	_current_wave.gold_earned += amount


func record_health_pickup() -> void:
	if _current_wave == null:
		return

	_current_wave.health_pickups_collected += 1


func get_current_wave_summary() -> Dictionary:
	if _current_wave == null:
		return {}
	return _wave_summary_with_live_duration(_current_wave)


func _wave_summary_with_live_duration(wave_metrics: WaveMetrics) -> Dictionary:
	var summary := wave_metrics.to_dictionary()
	if wave_metrics.duration_seconds > 0.0:
		return summary

	var live_duration := _calculate_wave_duration()
	if live_duration <= 0.0:
		return summary

	summary["duration_seconds"] = live_duration
	summary["effective_dps"] = float(wave_metrics.damage_dealt) / live_duration
	summary["kills_per_minute"] = float(wave_metrics.total_kills) / live_duration * 60.0
	summary["gold_per_minute"] = float(wave_metrics.gold_earned) / live_duration * 60.0
	return summary


func is_tracking() -> bool:
	return _is_tracking


func _calculate_wave_duration() -> float:
	return maxf(float(Time.get_ticks_msec() - _wave_start_ticks) / 1000.0, 0.0)
