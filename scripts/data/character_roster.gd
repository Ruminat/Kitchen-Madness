class_name CharacterRoster
extends RefCounted

const CHARACTER_PATHS: PackedStringArray = [
	"res://resources/characters/the_newbie.tres",
	"res://resources/characters/mr_barret.tres",
	"res://resources/characters/natsumi.tres",
]

const DEFAULT_CHARACTER_PATH := "res://resources/characters/the_newbie.tres"


static func load_roster() -> Array[CharacterDefinition]:
	var roster: Array[CharacterDefinition] = []
	for path in CHARACTER_PATHS:
		var character := load(path) as CharacterDefinition
		if character:
			roster.append(character)
	return roster


static func get_default() -> CharacterDefinition:
	return load(DEFAULT_CHARACTER_PATH) as CharacterDefinition
