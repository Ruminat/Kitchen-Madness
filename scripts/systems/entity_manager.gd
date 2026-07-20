class_name EntityManager
extends Node
## Owns the player's autonomous allies. Pets/structures spawn one persistent world
## node on acquisition and self-manage. Traps run a spawn timer here, dropping fresh
## hazards near the player on cadence. Data-driven via EntityDefinition.

var _player: Node2D
var _container: Node2D
var _arena_bounds := Rect2()
## id -> { "definition": EntityDefinition, "level": int, "cooldown": float, "node"? }
var _active: Dictionary = {}


func configure(player: Node2D, container: Node2D, bounds := Rect2()) -> void:
	_player = player
	_container = container
	_arena_bounds = bounds


func _process(delta: float) -> void:
	if not _can_run():
		return

	for id in _active:
		var state: Dictionary = _active[id]
		var definition: EntityDefinition = state.definition
		if definition.kind != EntityDefinition.Kind.TRAP:
			continue
		state.cooldown -= delta
		if state.cooldown <= 0.0:
			_spawn_trap_hazard(state)
			state.cooldown = definition.scaled_rate(state.level)


## Acquire an entity. Pets/structures spawn immediately; traps start their timer.
func add_entity(definition: EntityDefinition) -> bool:
	if definition == null or _active.has(definition.id):
		return false
	var state := {"definition": definition, "level": 0, "cooldown": definition.scaled_rate(0)}
	if definition.kind != EntityDefinition.Kind.TRAP:
		state["node"] = _spawn_persistent(definition)
	_active[definition.id] = state
	return true


func upgrade_entity(id: String) -> bool:
	if not _active.has(id):
		return false
	var state: Dictionary = _active[id]
	var definition: EntityDefinition = state.definition
	if definition.is_max_level(state.level):
		return false
	state.level += 1
	return true


func has_entity(id: String) -> bool:
	return _active.has(id)


func get_entity_level(id: String) -> int:
	if not _active.has(id):
		return -1
	return int(_active[id].level)


func is_maxed(id: String) -> bool:
	if not _active.has(id):
		return false
	var state: Dictionary = _active[id]
	return (state.definition as EntityDefinition).is_max_level(state.level)


func active_entity_ids() -> Array:
	return _active.keys()


func _spawn_persistent(definition: EntityDefinition) -> Node2D:
	var node := definition.scene.instantiate() as Node2D
	_container.add_child(node)
	node.global_position = _persistent_spawn_position()
	if node.has_method("setup"):
		node.setup(definition, _player, _arena_bounds)
	return node


func _persistent_spawn_position() -> Vector2:
	if _player != null and is_instance_valid(_player):
		var offset := Vector2.from_angle(randf() * TAU) * StatUnits.area_to_pixels(15.0)
		return _player.global_position + offset
	return Vector2.ZERO


func _spawn_trap_hazard(state: Dictionary) -> void:
	var definition: EntityDefinition = state.definition
	var hazard := definition.scene.instantiate() as Node2D
	_container.add_child(hazard)
	hazard.global_position = _random_trap_position(definition)
	if hazard.has_method("setup"):
		hazard.setup(
			_scaled_damage(definition, state.level), _scaled_area_px(definition, state.level)
		)


func _random_trap_position(definition: EntityDefinition) -> Vector2:
	var origin := (
		_player.global_position if (_player and is_instance_valid(_player)) else Vector2.ZERO
	)
	var min_px := StatUnits.area_to_pixels(definition.spawn_min)
	var max_px := StatUnits.area_to_pixels(definition.spawn_max)
	var distance := randf_range(min_px, maxf(max_px, min_px))
	var position := origin + Vector2.from_angle(randf() * TAU) * distance
	if _arena_bounds.size != Vector2.ZERO:
		position = ArenaClamp.clamp_position(position, _arena_bounds, 16.0)
	return position


func _scaled_damage(definition: EntityDefinition, level: int) -> int:
	var base := definition.scaled_damage(level)
	var mult := 1.0
	if _player and _player.has_method("get_damage_multiplier"):
		mult = _player.get_damage_multiplier()
	return maxi(roundi(float(base) * mult), 1)


func _scaled_area_px(definition: EntityDefinition, level: int) -> float:
	var units := definition.scaled_area_units(level)
	var mult := 1.0
	if _player and _player.has_method("get_area_multiplier"):
		mult = _player.get_area_multiplier()
	return StatUnits.area_to_pixels(units) * mult


func _can_run() -> bool:
	if _player != null and _player.has_method("is_alive") and not _player.is_alive():
		return false
	return true
