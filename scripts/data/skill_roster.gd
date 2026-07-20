class_name SkillRoster
extends RefCounted

const SKILL_PATHS: PackedStringArray = [
	"res://resources/skills/heavy_fridge.tres",
	"res://resources/skills/wraith_of_cooking_god.tres",
	"res://resources/skills/garlic_stench.tres",
]


static func load_roster() -> Array[SkillDefinition]:
	var roster: Array[SkillDefinition] = []
	for path in SKILL_PATHS:
		var skill := load(path) as SkillDefinition
		if skill:
			roster.append(skill)
	return roster
