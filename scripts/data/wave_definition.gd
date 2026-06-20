class_name WaveDefinition
extends Resource

const DURATION_GROWTH_PER_WAVE := 5.0

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


static func resolve_duration(
	definition: WaveDefinition, wave_number: int, roster_size: int
) -> float:
	if definition == null:
		return 12.0

	var overflow := maxi(wave_number - roster_size, 0)
	return definition.duration + DURATION_GROWTH_PER_WAVE * float(overflow)
