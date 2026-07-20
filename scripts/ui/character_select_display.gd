class_name CharacterSelectDisplay
extends RefCounted
## Pure formatting for the character-select detail panel. Keeps game_ui thin and
## makes the readout testable without instantiating the whole HUD.


static func format_detail(character: CharacterDefinition) -> String:
	if character == null:
		return ""

	var lines: Array[String] = [
		"%s - %s" % [character.display_name, character.description],
		(
			"HP %d  |  Armor %d  |  Speed %.0f"
			% [character.max_health, character.armor, character.move_speed]
		),
		(
			"Damage %s  |  Attack Speed %s  |  Crit %s"
			% [
				format_percent(character.damage_mult),
				format_percent(character.attack_speed_mult),
				format_percent(character.crit_chance),
			]
		),
		(
			"Luck %s  |  Evasion %s  |  Starts with %s"
			% [
				format_percent(character.luck),
				format_percent(character.evasion),
				_starting_weapon_name(character),
			]
		),
	]
	return "\n".join(lines)


## Format a fractional modifier (0.18) as a signed percentage string ("+18%").
static func format_percent(value: float) -> String:
	var sign_prefix := "+" if value > 0.0 else ""
	return "%s%d%%" % [sign_prefix, roundi(value * 100.0)]


static func _starting_weapon_name(character: CharacterDefinition) -> String:
	var weapon := character.starting_weapon
	if weapon == null:
		return "none"
	if not weapon.display_name.is_empty():
		return weapon.display_name
	return weapon.id
