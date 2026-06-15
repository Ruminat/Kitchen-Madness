class_name WaveManager
extends Node

signal wave_completed

var wave_definition: WaveDefinition
var time_remaining: float = 0.0
var is_complete := false
var is_paused := false


func configure(definition: WaveDefinition) -> void:
	wave_definition = definition
	time_remaining = definition.duration if definition else 30.0
	EventBus.wave_time_changed.emit(time_remaining)


func _process(delta: float) -> void:
	if is_complete or is_paused:
		return

	time_remaining -= delta
	EventBus.wave_time_changed.emit(time_remaining)

	if time_remaining <= 0.0:
		_complete_wave()


func pause() -> void:
	is_paused = true


func reset() -> void:
	is_complete = false
	is_paused = false
	time_remaining = wave_definition.duration if wave_definition else 30.0
	EventBus.wave_time_changed.emit(time_remaining)


func _complete_wave() -> void:
	is_complete = true
	EventBus.wave_completed.emit()
	wave_completed.emit()
