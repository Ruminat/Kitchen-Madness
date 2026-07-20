# gdlint:ignore=max-public-methods
# The player is the central stat hub: it exposes one small mutator/getter per
# stat so upgrades, perks, and systems stay data-driven. That legitimately
# exceeds the default method budget; R4/R8 prune the retired stat surfaces.
extends CharacterBody2D

signal died

const BASE_MOVE_SPEED := 220.0
const CONTACT_DAMAGE := 10
const BODY_RADIUS := 14.0
const COLLISION := preload("res://scripts/data/collision_layers.gd")
## Small buffer so fast enemies still register contact on the frame they touch.
const CONTACT_FORGIVENESS := 2.0
const CONTACT_SLOW_RADIUS := 88.0

## Base crit chance every player starts from; the character adds a modifier on top.
const BASE_CRIT_CHANCE := 0.05

var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)
var move_speed := BASE_MOVE_SPEED
## Luck modifier as a fraction (0.12 = +12%). See docs/stats.md.
var luck := 0.0
var pickup_range_bonus := 0.0

var _xp_gain_multiplier := 1.0
var _area_multiplier := 1.0
var _character: CharacterDefinition
var _crit_chance := BASE_CRIT_CHANCE
var _crit_damage := 1.5

@onready var visual: Node2D = $Visual
@onready var sprite: Sprite2D = $Visual/Sprite
@onready var health_component: HealthComponent = $HealthComponent
@onready var weapon_controller: WeaponController = $WeaponController


func _ready() -> void:
	add_to_group("player")
	collision_layer = COLLISION.PLAYER
	collision_mask = COLLISION.PLAYER_MASK
	motion_mode = MOTION_MODE_FLOATING
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	if visual:
		visual.add_child(IdleSquash.new())
	call_deferred("_emit_initial_health")


func _physics_process(_delta: float) -> void:
	if not is_alive():
		return

	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down")
	)
	if input_dir.length_squared() > 1.0:
		input_dir = input_dir.normalized()

	velocity = input_dir * move_speed
	move_and_slide()
	_clamp_to_arena()
	_check_contact_damage()

	if health_component.is_invincible():
		visual.modulate.a = 0.55 + 0.45 * abs(sin(Time.get_ticks_msec() * 0.04))
	else:
		visual.modulate.a = 1.0


func is_alive() -> bool:
	return health_component.is_alive()


func get_health() -> int:
	return health_component.current_health


func get_max_health() -> int:
	return health_component.max_health


func setup(bounds: Rect2, projectile_container: Node2D) -> void:
	arena_bounds = bounds
	_clamp_to_arena()
	weapon_controller.setup(projectile_container, bounds)


func configure(character: CharacterDefinition) -> void:
	if character == null:
		return

	_character = character
	move_speed = StatUnits.speed_to_pixels(character.move_speed)
	luck = character.luck
	_crit_chance = clampf(BASE_CRIT_CHANCE + character.crit_chance, 0.0, 1.0)
	_crit_damage = character.crit_damage
	health_component.max_health = character.max_health
	health_component.current_health = character.max_health
	health_component.armor = character.armor
	health_component.set_evasion(character.evasion)
	if character.sprite:
		sprite.texture = character.sprite
	weapon_controller.configure_weapons(character.starting_weapon)
	weapon_controller.set_character_modifiers(character.damage_mult, character.attack_speed_mult)
	weapon_controller.sync_all_crit_stats()
	_emit_initial_health()


func get_character() -> CharacterDefinition:
	return _character


func set_arena_bounds(bounds: Rect2) -> void:
	arena_bounds = bounds
	_clamp_to_arena()
	weapon_controller.set_arena_bounds(bounds)


func increase_weapon_damage_percent(percent: float) -> void:
	weapon_controller.increase_damage_percent(percent)


func increase_attack_speed_percent(percent: float) -> void:
	weapon_controller.increase_fire_rate_percent(percent)


func increase_move_speed_percent(percent: float) -> void:
	if is_zero_approx(percent):
		return

	move_speed = maxf(move_speed * (1.0 + percent), 1.0)


func increase_max_health(amount: int) -> void:
	health_component.increase_max_health(amount, amount)


func increase_max_health_percent(percent: float) -> void:
	if percent <= 0.0:
		return

	var amount := maxi(roundi(float(health_component.max_health) * percent), 1)
	health_component.increase_max_health(amount, amount)


func increase_armor(amount: int) -> void:
	health_component.increase_armor(amount)


func increase_evasion(amount: float) -> void:
	if is_zero_approx(amount):
		return

	health_component.increase_evasion(amount)


func increase_area_percent(percent: float) -> void:
	if is_zero_approx(percent):
		return

	_area_multiplier = maxf(_area_multiplier * (1.0 + percent), 0.1)
	weapon_controller.set_area_multiplier(_area_multiplier)


func increase_luck(amount: float) -> void:
	if is_zero_approx(amount):
		return

	luck += amount


func increase_pickup_range(amount: float) -> void:
	if amount <= 0.0:
		return

	pickup_range_bonus += amount


func increase_xp_gain_percent(percent: float) -> void:
	if percent <= 0.0:
		return

	_xp_gain_multiplier *= 1.0 + percent


func get_luck() -> float:
	return luck


func get_area_multiplier() -> float:
	return _area_multiplier


## Global outgoing-damage multiplier from the character + upgrades. Skills, pets,
## and traps read this so the Damage stat applies to them too (docs/stats.md).
func get_damage_multiplier() -> float:
	return weapon_controller.get_global_damage_multiplier()


func get_evasion() -> float:
	return health_component.evasion


func get_pickup_range_bonus() -> float:
	return pickup_range_bonus


func get_gold_multiplier() -> float:
	return 1.0 + luck


func get_xp_multiplier() -> float:
	return _xp_gain_multiplier * (1.0 + luck)


func get_health_drop_chance_bonus() -> float:
	return luck * 0.15


func get_crit_chance() -> float:
	return _crit_chance


func get_crit_damage() -> float:
	return _crit_damage


func increase_crit_chance(amount: float) -> void:
	if amount <= 0.0:
		return

	_crit_chance = minf(_crit_chance + amount, 1.0)
	weapon_controller.sync_all_crit_stats()


func increase_crit_damage(percent: float) -> void:
	if percent <= 0.0:
		return

	_crit_damage *= 1.0 + percent
	weapon_controller.sync_all_crit_stats()


func _emit_initial_health() -> void:
	EventBus.player_health_changed.emit(
		health_component.current_health, health_component.max_health
	)


func _on_health_changed(current: int, maximum: int) -> void:
	var previous_health := health_component.current_health
	EventBus.player_health_changed.emit(current, maximum)


func _on_health_decreased(amount: int) -> void:
	EventBus.metrics_damage_taken.emit(amount)


func _on_died() -> void:
	EventBus.player_died.emit()
	died.emit()


func _clamp_to_arena() -> void:
	global_position = ArenaClamp.clamp_position(global_position, arena_bounds, BODY_RADIUS)


func _check_contact_damage() -> void:
	if health_component.is_invincible():
		return

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue

		var enemy_radius := 12.0
		if enemy.has_method("get_collision_radius"):
			enemy_radius = enemy.get_collision_radius()

		var touch_distance := BODY_RADIUS + enemy_radius + CONTACT_FORGIVENESS
		if (
			global_position.distance_squared_to(enemy.global_position)
			> touch_distance * touch_distance
		):
			continue

		var damage := CONTACT_DAMAGE
		if enemy.has_method("get_contact_damage"):
			damage = enemy.get_contact_damage()
		health_component.take_damage(damage)
		EventBus.metrics_damage_taken.emit(damage)
		_apply_contact_slow_around_player()
		return


func _apply_contact_slow_around_player() -> void:
	var radius_sq := CONTACT_SLOW_RADIUS * CONTACT_SLOW_RADIUS
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		if global_position.distance_squared_to((enemy as Node2D).global_position) > radius_sq:
			continue
		if enemy.has_method("apply_contact_slow"):
			enemy.apply_contact_slow()
