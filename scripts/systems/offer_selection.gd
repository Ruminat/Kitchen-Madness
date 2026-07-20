class_name OfferSelection
extends RefCounted
## Shared, luck-biased selection of unique offers. Used by both the shop and the
## level-up flow so every acquisition path applies Luck's "offer a duplicate you
## already own" rule the same way (docs/stats.md).


## True when the offer reinforces something the player already owns — a weapon,
## skill, or entity upgrade. Luck biases selection toward these "double-down" offers.
static func favors_duplicate(offer: Resource) -> bool:
	if offer is WeaponShopOffer:
		return _is_weapon_upgrade((offer as WeaponShopOffer).offer_type)
	if offer is SkillShopOffer:
		return (offer as SkillShopOffer).is_upgrade
	if offer is EntityShopOffer:
		return (offer as EntityShopOffer).is_upgrade
	return false


static func _is_weapon_upgrade(offer_type: int) -> bool:
	return (
		offer_type
		in [
			WeaponShopOffer.OfferType.WEAPON_DAMAGE,
			WeaponShopOffer.OfferType.WEAPON_ATTACK_SPEED,
			WeaponShopOffer.OfferType.WEAPON_PELLET,
		]
	)


## Pick up to `count` offers with unique keys, biasing duplicate offers toward the
## front by `luck` (a fraction; 0 = pure random). Returns an untyped Array.
static func select(candidates: Array, count: int, luck: float) -> Array:
	var bias := clampf(luck, 0.0, 0.9)
	var scored: Array = []
	for candidate in candidates:
		var score := randf()
		if favors_duplicate(candidate):
			score -= bias
		scored.append({"offer": candidate, "score": score})

	scored.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.score < b.score)

	var selected: Array = []
	var used_keys: Dictionary = {}
	for entry in scored:
		if selected.size() >= count:
			break
		var key := offer_key(entry.offer)
		if used_keys.has(key):
			continue
		used_keys[key] = true
		selected.append(entry.offer)
	return selected


## Stable dedupe key for any offer type (offers expose get_offer_key; plain
## upgrades fall back to their id).
static func offer_key(offer: Resource) -> String:
	if offer.has_method("get_offer_key"):
		return String(offer.call("get_offer_key"))
	var id: Variant = offer.get("id")
	if id != null and String(id) != "":
		return "upgrade:%s" % String(id)
	return "upgrade:%d" % offer.get_instance_id()
