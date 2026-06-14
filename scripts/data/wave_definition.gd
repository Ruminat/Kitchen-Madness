class_name WaveDefinition
extends Resource

@export var duration: float = 30.0
@export var spawn_interval: float = 1.4
@export var max_enemies: int = 40
@export var spawn_multiplier_start: float = 1.0
@export var spawn_multiplier_end: float = 1.0
@export var spawn_multiplier_curve: float = 1.0
@export var enemy_weights: Array[EnemySpawnEntry] = []
@export var fallback_enemy_scene: PackedScene


func get_spawn_multiplier(progress: float) -> float:
	var clamped_progress := clampf(progress, 0.0, 1.0)
	var curved_progress := pow(clamped_progress, maxf(spawn_multiplier_curve, 0.01))
	return lerpf(spawn_multiplier_start, spawn_multiplier_end, curved_progress)
