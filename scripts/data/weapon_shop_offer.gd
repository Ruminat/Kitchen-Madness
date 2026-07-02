class_name WeaponShopOffer
extends Resource

enum OfferType { ADD_WEAPON, WEAPON_DAMAGE, WEAPON_ATTACK_SPEED, WEAPON_PELLET, SELL_WEAPON }

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var gold_cost: int = 0
@export var offer_type: OfferType = OfferType.ADD_WEAPON
@export var weapon: WeaponDefinition
@export var weapon_id: String = ""
@export var amount: float = 0.0


func apply(player: Node) -> bool:
	var controller := _get_weapon_controller(player)
	if controller == null:
		return false

	match offer_type:
		OfferType.ADD_WEAPON:
			if (
				weapon == null
				or controller.has_weapon(weapon.id)
				or not controller.can_add_weapon()
			):
				return false
			controller.add_weapon(weapon)
		OfferType.WEAPON_DAMAGE:
			controller.upgrade_weapon_damage(weapon_id, amount)
		OfferType.WEAPON_ATTACK_SPEED:
			controller.upgrade_weapon_fire_rate(weapon_id, amount)
		OfferType.WEAPON_PELLET:
			controller.upgrade_weapon_pellets(weapon_id, int(amount))
		_:
			return false

	return true


func _get_weapon_controller(player: Node) -> WeaponController:
	if player == null:
		return null
	return player.get_node_or_null("WeaponController") as WeaponController


func get_offer_key() -> String:
	if offer_type == OfferType.ADD_WEAPON and weapon:
		return "add:%s" % weapon.id
	return "%d:%s" % [offer_type, weapon_id]
