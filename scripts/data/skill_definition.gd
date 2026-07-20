class_name SkillDefinition
extends Resource
## An autonomous skill — a player-independent effect that fires on its own cadence.
## Levels are counted as applied upgrades (0 = freshly acquired base, up to max_level).
## Per-level scaling is authored here; the runner applies the player's global damage
## and area multipliers on top (docs/stats.md: Damage/Area apply to skills too).

enum Kind {
	FALLING,  ## Drops on a random enemy, damaging an area around the impact (Heavy Fridge).
	LIGHTNING,  ## Strikes several enemies, each in a small area (Wraith of Cooking God).
	AURA,  ## Ticks around the player, damaging everything in range (Garlic Stench).
}

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var kind: Kind = Kind.FALLING
## Seconds between activations at base level.
@export var cadence: float = 3.0
@export var damage: int = 60
## Effect radius in design area units (docs/stats.md).
@export var area: float = 60.0
## Number of separate targets struck (LIGHTNING); 1 for single-impact skills.
@export var base_hits: int = 1
## Maximum applied upgrades (the documented "max upgrades").
@export var max_level: int = 6
@export var damage_per_level: float = 0.1
@export var area_per_level: float = 0.0
## Fraction the tick rate speeds up per level (0.1 = +10% faster ticks per level).
@export var cadence_per_level: float = 0.0
@export var hits_per_level: int = 0


func scaled_damage(level: int) -> int:
	return maxi(roundi(float(damage) * (1.0 + damage_per_level * float(level))), 0)


func scaled_area_units(level: int) -> float:
	return maxf(area * (1.0 + area_per_level * float(level)), 0.0)


func scaled_cadence(level: int) -> float:
	return maxf(cadence / (1.0 + cadence_per_level * float(level)), 0.01)


func scaled_hits(level: int) -> int:
	return maxi(base_hits + hits_per_level * level, 1)


func is_max_level(level: int) -> bool:
	return level >= max_level
