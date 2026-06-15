class_name UpgradeDefinition
extends Resource

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var effect: StringName = &""
@export var amount: float = 0.0
@export var gold_cost: int = 0


func apply(player: Node) -> void:
	if player == null:
		return

	match effect:
		&"max_health_flat":
			if player.has_method("increase_max_health"):
				player.increase_max_health(roundi(amount))
		&"armor_flat":
			if player.has_method("increase_armor"):
				player.increase_armor(roundi(amount))
		&"damage_percent":
			if player.has_method("increase_weapon_damage_percent"):
				player.increase_weapon_damage_percent(amount)
		&"attack_speed_percent":
			if player.has_method("increase_attack_speed_percent"):
				player.increase_attack_speed_percent(amount)
		&"move_speed_percent":
			if player.has_method("increase_move_speed_percent"):
				player.increase_move_speed_percent(amount)
		&"luck_flat":
			if player.has_method("increase_luck"):
				player.increase_luck(roundi(amount))
		&"pickup_range_flat":
			if player.has_method("increase_pickup_range"):
				player.increase_pickup_range(amount)
		&"xp_gain_percent":
			if player.has_method("increase_xp_gain_percent"):
				player.increase_xp_gain_percent(amount)
