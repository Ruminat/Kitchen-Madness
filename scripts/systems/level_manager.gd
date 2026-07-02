class_name LevelManager
extends Node

signal level_completed

var level_definition: LevelDefinition
var elapsed_time := 0.0
var is_complete := false
var is_paused := false
var _duration := 600.0


func configure(definition: LevelDefinition) -> void:
	level_definition = definition
	is_complete = false
	is_paused = false
	elapsed_time = 0.0
	_duration = definition.duration if definition else 600.0
	_emit_time()


func get_duration() -> float:
	return _duration


func get_time_remaining() -> float:
	return maxf(_duration - elapsed_time, 0.0)


func get_progress() -> float:
	return clampf(elapsed_time / maxf(_duration, 0.01), 0.0, 1.0)


func _process(delta: float) -> void:
	if is_complete or is_paused:
		return

	elapsed_time += delta
	_emit_time()

	if elapsed_time >= _duration:
		_complete_level()


func pause() -> void:
	is_paused = true


func resume() -> void:
	is_paused = false


func reset() -> void:
	is_complete = false
	is_paused = false
	elapsed_time = 0.0
	_emit_time()


func _emit_time() -> void:
	EventBus.level_time_changed.emit(elapsed_time, get_time_remaining())


func _complete_level() -> void:
	is_complete = true
	EventBus.level_completed.emit()
	level_completed.emit()
