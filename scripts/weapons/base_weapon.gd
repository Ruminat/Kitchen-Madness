class_name BaseWeapon
extends Node2D

const ORBIT_RADIUS := 34.0
const ORBIT_FLOAT_SPEED := 1.2
const RECOIL_DISTANCE := 7.0
const RECOIL_TIME := 0.14
## Weapon icons (and their projectiles) render at this fraction of the player's
## on-screen diameter.
const WEAPON_DIAMETER_FRACTION := 0.50
## Fallback scale when the player's render size can't be measured (e.g. tests).
const DEFAULT_WEAPON_SPRITE_SCALE := 0.0875

var definition: WeaponDefinition
var arena_bounds := Rect2()
var _projectile_container: Node2D
var _damage_multiplier := 1.0
var _fire_rate_multiplier := 1.0
var _area_multiplier := 1.0
var _sprite: Sprite2D
var _base_orbit_angle := 0.0
var _orbit_phase := 0.0
var _recoil_timer := 0.0
var _aim_direction := Vector2.RIGHT
var _crit_chance := 0.05
var _crit_damage := 1.5


func setup(def: WeaponDefinition, bounds: Rect2, projectile_container: Node2D) -> void:
	definition = (def.duplicate() as WeaponDefinition) if def else null
	arena_bounds = bounds
	_projectile_container = projectile_container
	_setup_visual()


func _process(delta: float) -> void:
	update_weapon_visual(delta)


func set_arena_bounds(bounds: Rect2) -> void:
	arena_bounds = bounds


func set_projectile_container(container: Node2D) -> void:
	_projectile_container = container


func get_projectile_container() -> Node2D:
	return _projectile_container


func increase_damage_percent(percent: float) -> void:
	if is_zero_approx(percent):
		return

	apply_damage_multiplier(1.0 + percent)


func increase_fire_rate_percent(percent: float) -> void:
	if is_zero_approx(percent):
		return

	apply_fire_rate_multiplier(1.0 + percent)


## Multiply the damage multiplier directly (supports character penalties < 1.0).
func apply_damage_multiplier(factor: float) -> void:
	_damage_multiplier *= factor


## Multiply the fire-rate multiplier directly (supports character penalties < 1.0).
func apply_fire_rate_multiplier(factor: float) -> void:
	_fire_rate_multiplier *= factor


func get_fire_rate_multiplier() -> float:
	return maxf(_fire_rate_multiplier, 0.1)


func set_area_multiplier(value: float) -> void:
	_area_multiplier = maxf(value, 0.1)


func get_area_multiplier() -> float:
	return _area_multiplier


func set_crit_stats(crit_chance: float, crit_damage: float) -> void:
	_crit_chance = clampf(crit_chance, 0.0, 1.0)
	_crit_damage = maxf(crit_damage, 1.0)


func get_crit_chance() -> float:
	return _crit_chance


func get_crit_damage() -> float:
	return _crit_damage


func get_damage() -> int:
	if definition == null:
		return 0

	return maxi(roundi(float(definition.damage) * _damage_multiplier), 1)


func increase_pellet_count(amount: int) -> void:
	if definition == null or amount <= 0:
		return

	definition.pellet_count += amount


func find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist_sq := INF

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not _is_available_enemy(enemy):
			continue
		var enemy_node := enemy as Node2D
		var dist_sq := global_position.distance_squared_to(enemy_node.global_position)
		if dist_sq < nearest_dist_sq:
			nearest_dist_sq = dist_sq
			nearest = enemy_node

	return nearest


func set_orbit_slot(index: int, total: int) -> void:
	if total <= 0:
		return

	_base_orbit_angle = -PI * 0.5 + TAU * float(index) / float(total)


func update_weapon_visual(delta: float) -> void:
	_update_visual(delta, find_nearest_enemy())


func play_fire_feedback() -> void:
	_recoil_timer = RECOIL_TIME


func uses_orbit_slot() -> bool:
	return true


func _setup_visual() -> void:
	if definition == null or not uses_orbit_slot():
		return
	if _sprite != null:
		return

	_sprite = Sprite2D.new()
	_sprite.name = "WeaponSprite"
	_sprite.texture = definition.icon if definition.icon else definition.projectile_texture
	_sprite.scale = _resolve_sprite_scale()
	_sprite.z_index = 2
	add_child(_sprite)


## Scale the weapon icon to WEAPON_DIAMETER_FRACTION of the player's rendered
## diameter so it reads as a small held tool rather than dwarfing the character.
func _resolve_sprite_scale() -> Vector2:
	var texture_width := float(_sprite.texture.get_width()) if _sprite.texture else 0.0
	var player_diameter := _player_render_diameter()
	if texture_width <= 0.0 or player_diameter <= 0.0:
		return Vector2(DEFAULT_WEAPON_SPRITE_SCALE, DEFAULT_WEAPON_SPRITE_SCALE)
	var scale := player_diameter * WEAPON_DIAMETER_FRACTION / texture_width
	return Vector2(scale, scale)


## The player's on-screen diameter in pixels (texture width × sprite scale), or 0
## when the weapon isn't parented under a player (e.g. isolated unit tests).
func _player_render_diameter() -> float:
	var controller := get_parent()
	if controller == null:
		return 0.0
	var player := controller.get_parent()
	if player == null:
		return 0.0
	var sprite := player.get_node_or_null("Visual/Sprite") as Sprite2D
	if sprite == null or sprite.texture == null:
		return 0.0
	return float(sprite.texture.get_width()) * absf(sprite.scale.x)


func _update_visual(delta: float, target: Node2D) -> void:
	if not uses_orbit_slot():
		position = Vector2.ZERO
		return

	_orbit_phase += delta * ORBIT_FLOAT_SPEED
	_recoil_timer = maxf(_recoil_timer - delta, 0.0)

	var float_offset := Vector2(0.0, sin(_orbit_phase + _base_orbit_angle * 1.7) * 2.5)
	var orbit_offset := Vector2(cos(_base_orbit_angle), sin(_base_orbit_angle)) * ORBIT_RADIUS

	if target != null:
		_aim_direction = (target.global_position - global_position).normalized()
		rotation = _aim_direction.angle()

	var recoil_alpha := _recoil_timer / RECOIL_TIME if RECOIL_TIME > 0.0 else 0.0
	position = orbit_offset + float_offset - _aim_direction * RECOIL_DISTANCE * recoil_alpha


func _is_available_enemy(enemy: Node) -> bool:
	if not is_instance_valid(enemy) or not enemy is Node2D:
		return false
	if enemy.has_node("HealthComponent"):
		var health := enemy.get_node("HealthComponent") as HealthComponent
		if health and not health.is_alive():
			return false
	return true
