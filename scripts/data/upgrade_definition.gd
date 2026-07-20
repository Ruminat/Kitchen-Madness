class_name UpgradeDefinition
extends Resource

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var effect: StringName = &""
@export var amount: float = 0.0
@export var gold_cost: int = 0


func apply(player: Node) -> void:
	StatEffects.apply_to_player(player, effect, amount)
