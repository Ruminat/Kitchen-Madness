class_name UpgradeDefinition
extends Resource

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var effect: StringName = &""
@export var amount: float = 0.0


func apply(player: Node) -> void:
	if player == null:
		return

	match effect:
		&"damage_percent":
			if player.has_method("increase_weapon_damage_percent"):
				player.increase_weapon_damage_percent(amount)
		&"move_speed_percent":
			if player.has_method("increase_move_speed_percent"):
				player.increase_move_speed_percent(amount)
		&"max_health_flat":
			if player.has_method("increase_max_health"):
				player.increase_max_health(roundi(amount))
		&"orbit_blade_flat":
			if player.has_method("increase_orbit_blades"):
				player.increase_orbit_blades(roundi(amount))
