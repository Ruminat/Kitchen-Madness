# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const NEWBIE_DEF := preload("res://resources/characters/the_newbie.tres")
const KNIFE_DEF := preload("res://resources/weapons/kitchen_knife.tres")
# The Newbie starts with the kitchen knife, so "add a new weapon" tests use the pan.
const PAN_DEF := preload("res://resources/weapons/frying_pan.tres")


func test_apply_add_weapon_equips_new_weapon() -> void:
	var player := await _create_player()
	var offer := _create_add_offer(PAN_DEF)

	assert_bool(offer.apply(player)).is_true()
	assert_bool(_controller(player).has_weapon("frying_pan")).is_true()


func test_apply_add_weapon_fails_when_weapon_already_owned() -> void:
	var player := await _create_player()
	var offer := _create_add_offer(NEWBIE_DEF.starting_weapon)

	assert_bool(offer.apply(player)).is_false()
	assert_int(_controller(player).get_owned_weapon_ids().size()).is_equal(1)


func test_apply_add_weapon_fails_without_weapon_controller() -> void:
	var player := Node.new()
	add_child(player)
	var offer := _create_add_offer(KNIFE_DEF)

	assert_bool(offer.apply(player)).is_false()


func test_apply_damage_upgrade_increases_weapon_damage() -> void:
	var player := await _create_player()
	_controller(player).add_weapon(PAN_DEF)
	var weapon: BaseWeapon = _controller(player).get_child(1) as BaseWeapon
	var before := weapon.get_damage()

	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.WEAPON_DAMAGE
	offer.weapon_id = "frying_pan"
	offer.amount = 0.25

	assert_bool(offer.apply(player)).is_true()
	assert_int(weapon.get_damage()).is_greater(before)


func test_apply_damage_upgrade_fails_for_unowned_weapon() -> void:
	var player := await _create_player()
	# Player does not own a frying pan.
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.WEAPON_DAMAGE
	offer.weapon_id = "frying_pan"
	offer.amount = 0.25

	assert_bool(offer.apply(player)).is_false()


func test_apply_attack_speed_upgrade_fails_for_unowned_weapon() -> void:
	var player := await _create_player()
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.WEAPON_ATTACK_SPEED
	offer.weapon_id = "frying_pan"
	offer.amount = 0.25

	assert_bool(offer.apply(player)).is_false()


func test_apply_pellet_upgrade_fails_for_unowned_weapon() -> void:
	var player := await _create_player()
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.WEAPON_PELLET
	offer.weapon_id = "frying_pan"
	offer.amount = 1.0

	assert_bool(offer.apply(player)).is_false()


func test_apply_sell_offer_is_not_applied_directly() -> void:
	# Sells are processed by ShopManager, never through apply().
	var player := await _create_player()
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.SELL_WEAPON
	offer.weapon_id = NEWBIE_DEF.starting_weapon.id

	assert_bool(offer.apply(player)).is_false()
	assert_int(_controller(player).weapon_count()).is_equal(1)


func test_get_offer_key_distinguishes_add_and_upgrade_offers() -> void:
	var add_offer := _create_add_offer(KNIFE_DEF)
	var damage_offer := WeaponShopOffer.new()
	damage_offer.offer_type = WeaponShopOffer.OfferType.WEAPON_DAMAGE
	damage_offer.weapon_id = "kitchen_knife"

	assert_str(add_offer.get_offer_key()).is_equal("add:kitchen_knife")
	assert_str(damage_offer.get_offer_key()).contains("kitchen_knife")
	assert_str(add_offer.get_offer_key()).is_not_equal(damage_offer.get_offer_key())


func _create_add_offer(weapon: WeaponDefinition) -> WeaponShopOffer:
	var offer := WeaponShopOffer.new()
	offer.offer_type = WeaponShopOffer.OfferType.ADD_WEAPON
	offer.weapon = weapon
	return offer


func _create_player() -> CharacterBody2D:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	var projectile_container := Node2D.new()
	add_child(player)
	add_child(projectile_container)
	if not player.is_node_ready():
		await player.ready
	player.configure(NEWBIE_DEF)
	player.setup(Rect2(-100.0, -100.0, 200.0, 200.0), projectile_container)
	return player


func _controller(player: CharacterBody2D) -> WeaponController:
	return player.get_node("WeaponController") as WeaponController
