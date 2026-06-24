class_name DropRates
extends RefCounted

## Per-kill orb/currency drop chances (1.0 = always).
const XP_DROP_CHANCE := 0.40
const GREASE_DROP_CHANCE := 0.50
const HEALTH_DROP_CHANCE := 0.05 / 10.0
const MAX_HEALTH_DROP_CHANCE := 0.22 / 10.0


static func roll_enemy_drop(base_chance: float, enemy: EnemyDefinition) -> bool:
	if base_chance <= 0.0:
		return false
	if enemy == null:
		return randf() < base_chance
	return randf() < minf(base_chance * enemy.get_drop_chance_multiplier(), 1.0)


static func scaled_drop_chance(base_chance: float, enemy: EnemyDefinition) -> float:
	if enemy == null:
		return base_chance
	return minf(base_chance * enemy.get_drop_chance_multiplier(), 1.0)
