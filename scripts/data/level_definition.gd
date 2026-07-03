class_name LevelDefinition
extends Resource

const HEALTH_GROWTH_PER_MINUTE := 0.25
const DAMAGE_GROWTH_PER_MINUTE := 0.15

@export var duration: float = 600.0
@export var spawn_interval: float = 2.6
@export var max_enemies_start: int = 24
@export var max_enemies_end: int = 140
@export var spawn_multiplier_start: float = 1.0
@export var spawn_multiplier_end: float = 6.0
@export var spawn_multiplier_curve: float = 1.2
@export var enemy_weights: Array[EnemySpawnEntry] = []
@export var fallback_enemy_scene: PackedScene
@export var swarm_size_min: int = 1
@export var swarm_size_max: int = 1
@export var swarm_cluster_radius: float = 40.0
## Number of separate small groups spawned per spawn tick, each at its own
## scattered location around the arena edges (avoids one giant pile).
@export var groups_per_wave_min: int = 1
@export var groups_per_wave_max: int = 1


func roll_swarm_size() -> int:
	var min_size := maxi(swarm_size_min, 1)
	var max_size := maxi(swarm_size_max, min_size)
	return randi_range(min_size, max_size)


func average_swarm_size() -> float:
	var min_size := maxi(swarm_size_min, 1)
	var max_size := maxi(swarm_size_max, min_size)
	return float(min_size + max_size) * 0.5


func roll_group_count() -> int:
	var min_groups := maxi(groups_per_wave_min, 1)
	var max_groups := maxi(groups_per_wave_max, min_groups)
	return randi_range(min_groups, max_groups)


func average_group_count() -> float:
	var min_groups := maxi(groups_per_wave_min, 1)
	var max_groups := maxi(groups_per_wave_max, min_groups)
	return float(min_groups + max_groups) * 0.5


func get_spawn_multiplier(progress: float) -> float:
	var clamped_progress := clampf(progress, 0.0, 1.0)
	var curved_progress := pow(clamped_progress, maxf(spawn_multiplier_curve, 0.01))
	return lerpf(spawn_multiplier_start, spawn_multiplier_end, curved_progress)


func get_max_enemies(progress: float) -> int:
	var clamped_progress := clampf(progress, 0.0, 1.0)
	return roundi(lerpf(float(max_enemies_start), float(max_enemies_end), clamped_progress))


func get_progress(elapsed_seconds: float) -> float:
	return clampf(elapsed_seconds / maxf(duration, 0.01), 0.0, 1.0)


static func resolve_enemy_health(base_health: int, elapsed_seconds: float) -> int:
	return maxi(
		roundi(float(base_health) * _time_growth(HEALTH_GROWTH_PER_MINUTE, elapsed_seconds)), 1
	)


static func resolve_contact_damage(base_damage: int, elapsed_seconds: float) -> int:
	return maxi(
		roundi(float(base_damage) * _time_growth(DAMAGE_GROWTH_PER_MINUTE, elapsed_seconds)), 1
	)


static func _time_growth(rate_per_minute: float, elapsed_seconds: float) -> float:
	var elapsed_minutes := maxf(elapsed_seconds, 0.0) / 60.0
	return 1.0 + rate_per_minute * elapsed_minutes
