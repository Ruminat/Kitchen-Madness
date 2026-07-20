extends Node2D
## Bean Shooter (structure): a fixed emplacement that snipes the nearest enemy in
## range on cadence, single-target. Cannot move.

const ACCENT := Color(0.75, 0.85, 0.4, 1.0)

var _definition: EntityDefinition
var _player: Node2D
var _cooldown := 0.0


func setup(definition: EntityDefinition, player: Node2D, _bounds := Rect2()) -> void:
	_definition = definition
	_player = player
	_cooldown = definition.rate if definition else 0.5


func _process(delta: float) -> void:
	if _definition == null:
		return
	_cooldown -= delta
	if _cooldown > 0.0:
		return

	var range_px := StatUnits.area_to_pixels(_definition.attack_range)
	var target := EntityCombat.nearest_enemy(get_tree(), global_position, range_px)
	if target == null:
		return

	EventBus.projectile_hit.emit(
		target.global_position, (target.global_position - global_position).normalized(), ACCENT
	)
	EntityCombat.damage_target(target, _damage(), _definition.id)
	_cooldown = _definition.rate


func _damage() -> int:
	var mult := 1.0
	if _player and _player.has_method("get_damage_multiplier"):
		mult = _player.get_damage_multiplier()
	return maxi(roundi(float(_definition.damage) * mult), 1)
