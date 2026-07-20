class_name EntityDefinition
extends Resource
## An autonomous ally — a pet, structure, or trap. Unlike weapons it is not attached
## to the player; it lives in the world as its own scene. Data-driven; the manager
## and each entity scene read stats from here. Distances are design units (StatUnits).

enum Kind {
	PET,  ## Moves and fights on its own (Nasty Cat); immune to damage.
	STRUCTURE,  ## Fixed emplacement that shoots the nearest enemy (Bean Shooter).
	TRAP,  ## Periodically spawns hazards near the player (Banana Mine).
}

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var kind: Kind = Kind.PET
## The world node spawned for this entity (pet/structure) or each hazard (trap).
@export var scene: PackedScene
## Attack cadence in seconds (pet/structure) or spawn cadence (trap).
@export var rate: float = 1.0
@export var damage: int = 40
## Effect radius in design area units; 0 = single-target.
@export var area: float = 20.0
## Targeting range in design area units.
@export var attack_range: float = 10.0
## Move speed in design area units (pets).
@export var move_speed: float = 0.0
## Trap spawn distance band from the player, in design area units.
@export var spawn_min: float = 0.0
@export var spawn_max: float = 0.0
## Maximum applied upgrades (traps upgrade; pets/structures are typically 0).
@export var max_level: int = 0
@export var damage_per_level: float = 0.0
@export var area_per_level: float = 0.0
## Fraction the spawn rate speeds up per level (0.2 = +20% faster spawns per level).
@export var rate_per_level: float = 0.0


func scaled_damage(level: int) -> int:
	return maxi(roundi(float(damage) * (1.0 + damage_per_level * float(level))), 0)


func scaled_area_units(level: int) -> float:
	return maxf(area * (1.0 + area_per_level * float(level)), 0.0)


func scaled_rate(level: int) -> float:
	return maxf(rate / (1.0 + rate_per_level * float(level)), 0.01)


func is_max_level(level: int) -> bool:
	return level >= max_level
