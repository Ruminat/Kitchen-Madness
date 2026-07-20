class_name PerkShopOffer
extends Resource
## A shop offer that grants a perk. Mirrors the surface ShopManager/ShopCard read
## from WeaponShopOffer (title/description/gold_cost/icon/apply/get_offer_key) so the
## shop can mix perks with weapons without special cases.

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var gold_cost: int = 0
@export var icon: Texture2D
@export var perk: PerkDefinition


func apply(player: Node) -> bool:
	if perk == null:
		return false
	return perk.apply(player)


func get_offer_key() -> String:
	return "perk:%s" % (perk.id if perk else id)
