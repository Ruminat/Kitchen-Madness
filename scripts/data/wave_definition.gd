class_name WaveDefinition
extends Resource

const DURATION_GROWTH_PER_WAVE := 5.0
const DENSITY_GROWTH_PER_WAVE := 0.1
const HEALTH_GROWTH_PER_WAVE := 0.12
const DAMAGE_GROWTH_PER_WAVE := 0.08

@export var duration: float = 30.0
@export var spawn_interval: float = 1.4
@export var max_enemies: int = 40
@export var spawn_multiplier_start: float = 1.0
@export var spawn_multiplier_end: float = 1.0
@export var spawn_multiplier_curve: float = 1.0
@export var enemy_weights: Array[EnemySpawnEntry] = []
@export var fallback_enemy_scene: PackedScene
@export var swarm_size_min: int = 1
@export var swarm_size_max: int = 1
@export var swarm_cluster_radius: float = 40.0


func roll_swarm_size() -> int:
	var min_size := maxi(swarm_size_min, 1)
	var max_size := maxi(swarm_size_max, min_size)
	return randi_range(min_size, max_size)


func average_swarm_size() -> float:
	var min_size := maxi(swarm_size_min, 1)
	var max_size := maxi(swarm_size_max, min_size)
	return float(min_size + max_size) * 0.5


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


static func resolve_density_multiplier(wave_number: int) -> float:
	return pow(1.0 + DENSITY_GROWTH_PER_WAVE, float(maxi(wave_number, 1) - 1))


static func resolve_enemy_health(base_health: int, wave_number: int) -> int:
	return maxi(
		roundi(
			float(base_health) * (1.0 + HEALTH_GROWTH_PER_WAVE * float(maxi(wave_number, 1) - 1))
		),
		1
	)


static func resolve_contact_damage(base_damage: int, wave_number: int) -> int:
	return maxi(
		roundi(
			float(base_damage) * (1.0 + DAMAGE_GROWTH_PER_WAVE * float(maxi(wave_number, 1) - 1))
		),
		1
	)
