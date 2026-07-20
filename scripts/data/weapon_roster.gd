class_name WeaponRoster
extends RefCounted

const WEAPON_PATHS: PackedStringArray = [
	"res://resources/weapons/kitchen_knife.tres",
	"res://resources/weapons/frying_pan.tres",
	"res://resources/weapons/rotten_tomato.tres",
]


static func load_roster() -> Array[WeaponDefinition]:
	var roster: Array[WeaponDefinition] = []
	for path in WEAPON_PATHS:
		var weapon := load(path) as WeaponDefinition
		if weapon:
			roster.append(weapon)
	return roster


static func get_by_id(weapon_id: String) -> WeaponDefinition:
	for weapon in load_roster():
		if weapon.id == weapon_id:
			return weapon
	return null
