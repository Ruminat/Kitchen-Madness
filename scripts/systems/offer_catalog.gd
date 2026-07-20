class_name OfferCatalog
extends RefCounted
## Builds the acquire/upgrade offers for autonomous content (skills, entities) so
## the shop and the level-up flow share one source of truth. Callers set gold_cost
## afterwards (the shop scales it with time; level-up leaves it free).


static func skill_offer(
	skill: SkillDefinition, is_upgrade: bool, runner: SkillRunner
) -> SkillShopOffer:
	var offer := SkillShopOffer.new()
	offer.id = skill.id
	offer.skill = skill
	offer.is_upgrade = is_upgrade
	offer.runner = runner
	offer.icon = skill.icon
	if is_upgrade:
		var level := (runner.get_skill_level(skill.id) + 1) if runner else 1
		offer.title = "Upgrade %s" % skill.display_name
		offer.description = "Level %d — +damage/effect." % level
	else:
		offer.title = "Learn %s" % skill.display_name
		offer.description = skill.description
	return offer


static func skill_offers(runner: SkillRunner) -> Array[Resource]:
	var offers: Array[Resource] = []
	if runner == null:
		return offers
	for skill in SkillRoster.load_roster():
		if not runner.has_skill(skill.id):
			offers.append(skill_offer(skill, false, runner))
		elif not runner.is_maxed(skill.id):
			offers.append(skill_offer(skill, true, runner))
	return offers


static func entity_offer(
	entity: EntityDefinition, is_upgrade: bool, manager: EntityManager
) -> EntityShopOffer:
	var offer := EntityShopOffer.new()
	offer.id = entity.id
	offer.entity = entity
	offer.is_upgrade = is_upgrade
	offer.manager = manager
	offer.icon = entity.icon
	if is_upgrade:
		var level := (manager.get_entity_level(entity.id) + 1) if manager else 1
		offer.title = "Upgrade %s" % entity.display_name
		offer.description = "Level %d — stronger and more frequent." % level
	else:
		offer.title = "Deploy %s" % entity.display_name
		offer.description = entity.description
	return offer


static func entity_offers(manager: EntityManager) -> Array[Resource]:
	var offers: Array[Resource] = []
	if manager == null:
		return offers
	for entity in EntityRoster.load_roster():
		if not manager.has_entity(entity.id):
			offers.append(entity_offer(entity, false, manager))
		elif not manager.is_maxed(entity.id):
			offers.append(entity_offer(entity, true, manager))
	return offers
