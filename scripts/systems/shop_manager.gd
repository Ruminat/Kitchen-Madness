class_name ShopManager
extends Node

const STAT_UPGRADE_PATHS: Array[String] = [
	"res://resources/upgrades/max_health.tres",
	"res://resources/upgrades/armor.tres",
	"res://resources/upgrades/damage_boost.tres",
	"res://resources/upgrades/attack_speed.tres",
	"res://resources/upgrades/speed_boost.tres",
	"res://resources/upgrades/luck.tres",
	"res://resources/upgrades/pickup_range.tres",
	"res://resources/upgrades/xp_gain.tres",
]

const ADD_WEAPON_BASE_COST := 12
const DAMAGE_UPGRADE_COST := 8
const ATTACK_SPEED_UPGRADE_COST := 8
const PELLET_UPGRADE_COST := 12
const DAMAGE_UPGRADE_PERCENT := 0.1
const ATTACK_SPEED_UPGRADE_PERCENT := 0.1
const PELLET_UPGRADE_AMOUNT := 1
const MAX_PELLET_COUNT := 8
const REROLL_BASE_COST := 6
const REROLL_COST_STEP := 4

@export var offer_count := 5

var _player: Node
var _ui: Node
var _gold_system: GoldSystem
var _on_continue := Callable()
var _shop_open := false
var _current_wave := 1
var _current_offers: Array[Resource] = []
var _sold_slots: Array[bool] = []
var _reroll_count := 0


func _ready() -> void:
	EventBus.wave_completed.connect(_on_wave_completed)
	EventBus.wave_index_changed.connect(_on_wave_index_changed)


func configure(
	player: Node, ui: Node, gold_system: GoldSystem, on_continue: Callable = Callable()
) -> void:
	_player = player
	_ui = ui
	_gold_system = gold_system
	_on_continue = on_continue

	if _ui and _ui.has_signal("shop_purchase_requested"):
		_ui.shop_purchase_requested.connect(_on_shop_purchase)
	if _ui and _ui.has_signal("shop_reroll_requested"):
		_ui.shop_reroll_requested.connect(_on_shop_reroll)
	if _ui and _ui.has_signal("shop_continue_requested"):
		_ui.shop_continue_requested.connect(_on_shop_continue)


func _on_wave_index_changed(wave: int) -> void:
	_current_wave = wave


func _on_wave_completed() -> void:
	_shop_open = true
	_reroll_count = 0
	_current_offers = generate_offers()
	_reset_sold_slots()
	get_tree().paused = true
	_start_shop_transition()


func _start_shop_transition() -> void:
	if _ui == null:
		return

	if _ui.has_method("show_shop_transition"):
		await _ui.show_shop_transition(
			_current_offers, _current_gold(), _sold_slots, _current_reroll_cost()
		)
	elif _ui.has_method("show_shop"):
		_ui.show_shop(_current_offers, _current_gold(), _sold_slots, _current_reroll_cost())


func _on_shop_purchase(offer: Resource) -> void:
	if not _shop_open or offer == null or _gold_system == null:
		return

	var slot_index := _current_offers.find(offer)
	if slot_index < 0 or _is_slot_sold(slot_index):
		return
	_ensure_sold_slots()

	var cost := int(offer.get("gold_cost"))
	if not _gold_system.spend_gold(cost):
		return

	if offer.has_method("apply") and offer.apply(_player):
		_sold_slots[slot_index] = true
	elif offer.has_method("apply"):
		_gold_system.add_gold(cost)

	_refresh_ui()


func _on_shop_reroll() -> void:
	if not _shop_open or _gold_system == null:
		return

	var cost := _current_reroll_cost()
	if not _gold_system.spend_gold(cost):
		_refresh_ui()
		return

	_reroll_count += 1
	_current_offers = generate_offers()
	_reset_sold_slots()
	_refresh_ui()


func _on_shop_continue() -> void:
	if not _shop_open:
		return

	_shop_open = false
	_current_offers.clear()
	_sold_slots.clear()
	if _ui and _ui.has_method("hide_shop"):
		_ui.hide_shop()

	if _on_continue.is_valid():
		_on_continue.call()


func generate_offers() -> Array[Resource]:
	var candidates := _build_offer_candidates()
	candidates.shuffle()

	var selected: Array[Resource] = []
	var used_keys: Dictionary = {}

	for candidate in candidates:
		if selected.size() >= offer_count:
			break

		var key := (candidate as WeaponShopOffer).get_offer_key()
		if used_keys.has(key):
			continue

		used_keys[key] = true
		selected.append(candidate)

	return selected


func _reset_sold_slots() -> void:
	_sold_slots.clear()
	for _index in offer_count:
		_sold_slots.append(false)


func _ensure_sold_slots() -> void:
	while _sold_slots.size() < offer_count:
		_sold_slots.append(false)


func _is_slot_sold(slot_index: int) -> bool:
	return slot_index >= 0 and slot_index < _sold_slots.size() and _sold_slots[slot_index]


func _refresh_ui(opening: bool = false) -> void:
	if _ui == null:
		return

	if opening and _ui.has_method("show_shop"):
		_ui.show_shop(_current_offers, _current_gold(), _sold_slots, _current_reroll_cost())
	elif _ui.has_method("refresh_shop"):
		_ui.refresh_shop(_current_offers, _current_gold(), _sold_slots, _current_reroll_cost())
	elif _ui.has_method("update_shop_gold"):
		_ui.update_shop_gold(_current_gold())


func _build_offer_candidates() -> Array[WeaponShopOffer]:
	var candidates: Array[WeaponShopOffer] = []
	var controller := _get_weapon_controller()
	var owned_ids: Array[String] = controller.get_owned_weapon_ids() if controller else []

	if controller == null or controller.can_add_weapon():
		for weapon in WeaponRoster.load_roster():
			if weapon.id in owned_ids:
				continue
			candidates.append(_create_add_weapon_offer(weapon))

	for weapon_id in owned_ids:
		var weapon_name := (
			controller.get_weapon_display_name(weapon_id) if controller else weapon_id
		)
		candidates.append(_create_damage_offer(weapon_id, weapon_name))
		candidates.append(_create_attack_speed_offer(weapon_id, weapon_name))

		var definition: WeaponDefinition = (
			controller.get_weapon_definition(weapon_id) if controller else null
		)
		if (
			definition
			and definition.projectile_scene
			and definition.pellet_count < MAX_PELLET_COUNT
		):
			candidates.append(_create_pellet_offer(weapon_id, weapon_name))

	return candidates


func _get_weapon_controller() -> WeaponController:
	if _player == null:
		return null
	return _player.get_node_or_null("WeaponController") as WeaponController


func _create_add_weapon_offer(weapon: WeaponDefinition) -> WeaponShopOffer:
	var offer := WeaponShopOffer.new()
	offer.id = "add_%s" % weapon.id
	offer.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	offer.weapon = weapon
	offer.title = "Add %s" % _weapon_label(weapon)
	offer.description = (
		weapon.description if not weapon.description.is_empty() else "New kitchen weapon."
	)
	offer.gold_cost = _scaled_cost(ADD_WEAPON_BASE_COST)
	return offer


func _create_damage_offer(weapon_id: String, weapon_name: String) -> WeaponShopOffer:
	var offer := WeaponShopOffer.new()
	offer.id = "damage_%s" % weapon_id
	offer.offer_type = WeaponShopOffer.OfferType.WEAPON_DAMAGE
	offer.weapon_id = weapon_id
	offer.amount = DAMAGE_UPGRADE_PERCENT
	offer.title = "Sharpen %s" % weapon_name
	offer.description = "+%d%% damage for this weapon." % int(DAMAGE_UPGRADE_PERCENT * 100.0)
	offer.gold_cost = _scaled_cost(DAMAGE_UPGRADE_COST)
	return offer


func _create_attack_speed_offer(weapon_id: String, weapon_name: String) -> WeaponShopOffer:
	var offer := WeaponShopOffer.new()
	offer.id = "speed_%s" % weapon_id
	offer.offer_type = WeaponShopOffer.OfferType.WEAPON_ATTACK_SPEED
	offer.weapon_id = weapon_id
	offer.amount = ATTACK_SPEED_UPGRADE_PERCENT
	offer.title = "Speed Up %s" % weapon_name
	offer.description = (
		"+%d%% attack speed for this weapon." % int(ATTACK_SPEED_UPGRADE_PERCENT * 100.0)
	)
	offer.gold_cost = _scaled_cost(ATTACK_SPEED_UPGRADE_COST)
	return offer


func _create_pellet_offer(weapon_id: String, weapon_name: String) -> WeaponShopOffer:
	var offer := WeaponShopOffer.new()
	offer.id = "pellet_%s" % weapon_id
	offer.offer_type = WeaponShopOffer.OfferType.WEAPON_PELLET
	offer.weapon_id = weapon_id
	offer.amount = float(PELLET_UPGRADE_AMOUNT)
	offer.title = "Extra %s" % weapon_name
	offer.description = "+%d projectile for this weapon." % PELLET_UPGRADE_AMOUNT
	offer.gold_cost = _scaled_cost(PELLET_UPGRADE_COST)
	return offer


func _weapon_label(weapon: WeaponDefinition) -> String:
	if not weapon.display_name.is_empty():
		return weapon.display_name
	return weapon.id


func _scaled_cost(base_cost: int) -> int:
	if _current_wave <= 2:
		return maxi(roundi(float(base_cost) * 0.75), 5)
	return base_cost


func _current_gold() -> int:
	if _gold_system:
		return _gold_system.gold
	return 0


func _current_reroll_cost() -> int:
	return REROLL_BASE_COST + REROLL_COST_STEP * _reroll_count


static func is_stat_upgrade(resource: Resource) -> bool:
	if resource == null:
		return false

	if resource is UpgradeDefinition:
		return true

	var path := resource.resource_path
	return path in STAT_UPGRADE_PATHS
