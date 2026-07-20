class_name SkillShopOffer
extends Resource
## A shop offer that acquires or upgrades an autonomous skill. Exposes the same
## surface (title/description/gold_cost/icon/apply/get_offer_key) the shop reads
## from every offer, so skills mix into the shop with no special cases.

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var gold_cost: int = 0
@export var icon: Texture2D
@export var skill: SkillDefinition
@export var is_upgrade: bool = false

## The live runner is injected at generation time (transient, never serialized).
var runner: SkillRunner


func apply(_player: Node) -> bool:
	if runner == null or skill == null:
		return false
	if is_upgrade:
		return runner.upgrade_skill(skill.id)
	return runner.add_skill(skill)


func get_offer_key() -> String:
	var skill_id := skill.id if skill else id
	return ("skill_up:%s" if is_upgrade else "skill_add:%s") % skill_id
