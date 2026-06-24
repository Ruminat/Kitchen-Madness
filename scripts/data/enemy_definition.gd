class_name EnemyDefinition
extends Resource

const DROP_POWER_BASELINE := 18.0
const DROP_MULTIPLIER_MIN := 0.7
const DROP_MULTIPLIER_MAX := 1.4

@export var id: String = ""
@export var scene: PackedScene
@export var max_health: int = 30
@export var move_speed: float = 90.0
@export var contact_damage: int = 10
@export var xp_drop: DropDefinition
@export var gold_reward: int = 1
@export var is_elite: bool = false
@export var color: Color = Color.RED
@export var radius: float = 12.0


func get_drop_chance_multiplier() -> float:
	var power := float(max_health)
	if is_elite:
		power *= 1.2
	return clampf(power / DROP_POWER_BASELINE, DROP_MULTIPLIER_MIN, DROP_MULTIPLIER_MAX)
