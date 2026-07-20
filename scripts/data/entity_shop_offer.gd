class_name EntityShopOffer
extends Resource
## A shop offer that acquires or upgrades an autonomous entity (pet/structure/trap).
## Same surface as the other offers so it mixes into the shop with no special cases.

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var gold_cost: int = 0
@export var icon: Texture2D
@export var entity: EntityDefinition
@export var is_upgrade: bool = false

## The live manager is injected at generation time (transient, never serialized).
var manager: EntityManager


func apply(_player: Node) -> bool:
	if manager == null or entity == null:
		return false
	if is_upgrade:
		return manager.upgrade_entity(entity.id)
	return manager.add_entity(entity)


func get_offer_key() -> String:
	var entity_id := entity.id if entity else id
	return ("entity_up:%s" if is_upgrade else "entity_add:%s") % entity_id
