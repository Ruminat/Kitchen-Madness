class_name PerkRoster
extends RefCounted

const PERK_PATHS: PackedStringArray = [
	"res://resources/perks/bring_me_more.tres",
	"res://resources/perks/the_crazy_one.tres",
	"res://resources/perks/getting_fatty.tres",
]


static func load_roster() -> Array[PerkDefinition]:
	var roster: Array[PerkDefinition] = []
	for path in PERK_PATHS:
		var perk := load(path) as PerkDefinition
		if perk:
			roster.append(perk)
	return roster
