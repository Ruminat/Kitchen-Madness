class_name CharacterDefinition
extends Resource

@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var sprite: Texture2D
@export var max_health: int = 100
@export var move_speed: float = 220.0
@export var luck: int = 0
@export var starting_weapon: WeaponDefinition
@export_range(0.0, 1.0) var crit_chance: float = 0.05
@export_range(1.0, 5.0) var crit_damage: float = 1.5


func apply_to_player(player: Node) -> void:
	if player == null:
		return

	if player.has_method("configure"):
		player.configure(self)
