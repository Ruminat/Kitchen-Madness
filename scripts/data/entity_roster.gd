class_name EntityRoster
extends RefCounted

const ENTITY_PATHS: PackedStringArray = [
	"res://resources/entities/nasty_cat.tres",
	"res://resources/entities/bean_shooter.tres",
	"res://resources/entities/banana_mine.tres",
]


static func load_roster() -> Array[EntityDefinition]:
	var roster: Array[EntityDefinition] = []
	for path in ENTITY_PATHS:
		var entity := load(path) as EntityDefinition
		if entity:
			roster.append(entity)
	return roster
