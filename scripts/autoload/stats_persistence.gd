extends Node
## Persists run statistics to disk for balance analysis.

const RunStatsPersistenceClass = preload("res://scripts/systems/run_stats_persistence.gd")

var _persistence = RunStatsPersistenceClass.new()
var _run_upgrades: Array[String] = []


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		_persistence.enabled = false

	EventBus.metrics_run_started.connect(_on_run_started)
	EventBus.metrics_run_ended.connect(_on_run_ended)
	EventBus.upgrade_applied.connect(_on_upgrade_applied)


func configure_stats_dir(path: String) -> void:
	_persistence.stats_dir = path
	_persistence.reset_session()


func set_enabled(is_enabled: bool) -> void:
	_persistence.enabled = is_enabled


func get_persistence():
	return _persistence


func _on_run_started(_character_id: String) -> void:
	_run_upgrades.clear()


func _on_upgrade_applied(upgrade_id: String) -> void:
	if upgrade_id.is_empty():
		return
	_run_upgrades.append(upgrade_id)


func _on_run_ended(run_summary: Dictionary) -> void:
	if run_summary.is_empty():
		return
	_persistence.save_run(run_summary, _run_upgrades)
	_run_upgrades.clear()
