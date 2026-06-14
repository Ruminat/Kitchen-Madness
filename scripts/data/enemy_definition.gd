class_name EnemyDefinition
extends Resource

@export var id: String = ""
@export var scene: PackedScene
@export var max_health: int = 30
@export var move_speed: float = 90.0
@export var contact_damage: int = 10
@export var xp_drop: DropDefinition
@export var color: Color = Color.RED
@export var radius: float = 12.0
