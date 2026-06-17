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


func apply_to_player(player: Node) -> void:
	if player == null:
		return

	if player.has_method("configure"):
		player.configure(self)
