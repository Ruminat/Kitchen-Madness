# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_favors_duplicate_detects_upgrade_offers() -> void:
	assert_bool(OfferSelection.favors_duplicate(_skill_offer("a", true))).is_true()
	assert_bool(OfferSelection.favors_duplicate(_skill_offer("b", false))).is_false()

	var weapon_upgrade := WeaponShopOffer.new()
	weapon_upgrade.offer_type = WeaponShopOffer.OfferType.WEAPON_DAMAGE
	weapon_upgrade.weapon_id = "kitchen_knife"
	assert_bool(OfferSelection.favors_duplicate(weapon_upgrade)).is_true()

	var weapon_add := WeaponShopOffer.new()
	weapon_add.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	assert_bool(OfferSelection.favors_duplicate(weapon_add)).is_false()


func test_select_returns_unique_keyed_offers_up_to_count() -> void:
	var pool: Array = [
		_skill_offer("a", false),
		_skill_offer("b", false),
		_skill_offer("c", false),
		_skill_offer("a", false),  # duplicate key -> collapsed
	]
	var selected := OfferSelection.select(pool, 5, 0.0)
	assert_int(selected.size()).is_equal(3)


func test_high_luck_prefers_duplicate_offers() -> void:
	var duplicate := _skill_offer("dup", true)
	var pool: Array = [duplicate]
	for index in 5:
		pool.append(_skill_offer("new_%d" % index, false))

	var lucky_hits := 0
	var plain_hits := 0
	for _iteration in 60:
		if OfferSelection.select(pool, 1, 0.9).has(duplicate):
			lucky_hits += 1
		if OfferSelection.select(pool, 1, 0.0).has(duplicate):
			plain_hits += 1

	assert_int(lucky_hits).is_greater(plain_hits)


func _skill_offer(id: String, is_upgrade: bool) -> SkillShopOffer:
	var skill := SkillDefinition.new()
	skill.id = id
	var offer := SkillShopOffer.new()
	offer.skill = skill
	offer.is_upgrade = is_upgrade
	return offer
