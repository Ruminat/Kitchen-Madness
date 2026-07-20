extends Node2D
## Nasty Cat (pet): chases the nearest enemy, swipes an area around itself on
## cadence, and is immune to all damage (it has no health and joins no enemy group).

const ACCENT := Color(0.9, 0.65, 0.35, 1.0)
const STOP_DISTANCE := 4.0

var _definition: EntityDefinition
var _player: Node2D
var _arena_bounds := Rect2()
var _cooldown := 0.0


func setup(definition: EntityDefinition, player: Node2D, bounds := Rect2()) -> void:
	_definition = definition
	_player = player
	_arena_bounds = bounds
	_cooldown = definition.rate if definition else 1.0


func _process(delta: float) -> void:
	if _definition == null:
		return
	_move(delta)
	_cooldown -= delta
	if _cooldown <= 0.0:
		_try_attack()


func _move(delta: float) -> void:
	var destination: Variant = _move_destination()
	if destination == null:
		return
	var to_target: Vector2 = (destination as Vector2) - global_position
	if to_target.length() > STOP_DISTANCE:
		global_position += to_target.normalized() * _move_speed_px() * delta
	if _arena_bounds.size != Vector2.ZERO:
		global_position = ArenaClamp.clamp_position(global_position, _arena_bounds, 8.0)


func _move_destination() -> Variant:
	var target := EntityCombat.nearest_enemy(get_tree(), global_position, 0.0)
	if target != null:
		return target.global_position
	if _player != null and is_instance_valid(_player):
		return _player.global_position
	return null


func _try_attack() -> void:
	var range_px := StatUnits.area_to_pixels(_definition.attack_range)
	var target := EntityCombat.nearest_enemy(get_tree(), global_position, range_px)
	if target == null:
		return
	EventBus.projectile_hit.emit(global_position, Vector2.RIGHT, ACCENT)
	EntityCombat.damage_in_radius(
		get_tree(), global_position, _area_px(), _damage(), _definition.id
	)
	_cooldown = _definition.rate


func _damage() -> int:
	var mult := 1.0
	if _player and _player.has_method("get_damage_multiplier"):
		mult = _player.get_damage_multiplier()
	return maxi(roundi(float(_definition.damage) * mult), 1)


func _area_px() -> float:
	var mult := 1.0
	if _player and _player.has_method("get_area_multiplier"):
		mult = _player.get_area_multiplier()
	return StatUnits.area_to_pixels(_definition.area) * mult


func _move_speed_px() -> float:
	return StatUnits.speed_to_pixels(_definition.move_speed)
