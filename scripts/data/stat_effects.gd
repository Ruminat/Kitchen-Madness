class_name StatEffects
extends RefCounted
## Single dispatcher that routes a named stat effect + amount onto the player.
## Shared by UpgradeDefinition (level-ups) and PerkDefinition (shop) so every
## content type applies stats through one code path — data-driven, no duplication.


## Apply one player-facing stat effect. Unknown/non-player effects are ignored here
## (callers handle world effects like enemy count themselves). Returns true if the
## effect targets the player and a matching mutator existed.
static func apply_to_player(player: Node, effect: StringName, amount: float) -> bool:
	if player == null:
		return false

	match effect:
		&"max_health_flat":
			return _call(player, "increase_max_health", roundi(amount))
		&"max_health_percent":
			return _call(player, "increase_max_health_percent", amount)
		&"armor_flat":
			return _call(player, "increase_armor", roundi(amount))
		&"damage_percent":
			return _call(player, "increase_weapon_damage_percent", amount)
		&"attack_speed_percent":
			return _call(player, "increase_attack_speed_percent", amount)
		&"area_percent":
			return _call(player, "increase_area_percent", amount)
		&"move_speed_percent":
			return _call(player, "increase_move_speed_percent", amount)
		&"evasion_percent":
			return _call(player, "increase_evasion", amount)
		&"luck_percent":
			return _call(player, "increase_luck", amount)
		&"luck_flat":
			return _call(player, "increase_luck", roundi(amount))
		&"pickup_range_flat":
			return _call(player, "increase_pickup_range", amount)
		&"xp_gain_percent":
			return _call(player, "increase_xp_gain_percent", amount)
		&"crit_chance_flat":
			return _call(player, "increase_crit_chance", amount)
		&"crit_damage_percent":
			return _call(player, "increase_crit_damage", amount)
		_:
			return false


static func _call(player: Node, method: String, value: Variant) -> bool:
	if not player.has_method(method):
		return false
	player.call(method, value)
	return true
