class_name SkillRunner
extends Node
## Ticks autonomous skills independently of the weapon system. Each active skill
## tracks its applied-upgrade level and its own cooldown; on cadence it executes
## its kind-specific effect. Data-driven — behavior comes from SkillDefinition.

## Impact accent for skill VFX bursts (reuses the projectile-hit VFX path).
const SKILL_ACCENT := Color(0.95, 0.86, 0.4, 1.0)

var _player: Node2D
## id -> { "definition": SkillDefinition, "level": int, "cooldown": float }
var _active: Dictionary = {}


func configure(player: Node2D) -> void:
	_player = player


func _process(delta: float) -> void:
	if not _can_run():
		return

	for id in _active:
		var state: Dictionary = _active[id]
		state.cooldown -= delta
		if state.cooldown <= 0.0:
			var definition: SkillDefinition = state.definition
			_execute(definition, state.level)
			state.cooldown = definition.scaled_cadence(state.level)


## Acquire a skill at base level. Returns false if already owned.
func add_skill(definition: SkillDefinition) -> bool:
	if definition == null or _active.has(definition.id):
		return false
	_active[definition.id] = {
		"definition": definition,
		"level": 0,
		"cooldown": definition.scaled_cadence(0),
	}
	return true


## Apply one upgrade to an owned skill. Returns false if unowned or already maxed.
func upgrade_skill(id: String) -> bool:
	if not _active.has(id):
		return false
	var state: Dictionary = _active[id]
	var definition: SkillDefinition = state.definition
	if definition.is_max_level(state.level):
		return false
	state.level += 1
	return true


func has_skill(id: String) -> bool:
	return _active.has(id)


func get_skill_level(id: String) -> int:
	if not _active.has(id):
		return -1
	return int(_active[id].level)


func is_maxed(id: String) -> bool:
	if not _active.has(id):
		return false
	var state: Dictionary = _active[id]
	return (state.definition as SkillDefinition).is_max_level(state.level)


func active_skill_ids() -> Array:
	return _active.keys()


func _execute(definition: SkillDefinition, level: int) -> void:
	match definition.kind:
		SkillDefinition.Kind.FALLING:
			_execute_falling(definition, level)
		SkillDefinition.Kind.LIGHTNING:
			_execute_lightning(definition, level)
		SkillDefinition.Kind.AURA:
			_execute_aura(definition, level)


func _execute_falling(definition: SkillDefinition, level: int) -> void:
	var target := _random_enemy()
	if target == null:
		return
	var impact := target.global_position
	EventBus.projectile_hit.emit(impact, Vector2.DOWN, SKILL_ACCENT)
	_damage_area(
		impact, _area_px(definition, level), _damage(definition, level), definition.id, true
	)


func _execute_lightning(definition: SkillDefinition, level: int) -> void:
	var targets := _pick_enemies(definition.scaled_hits(level))
	var damage := _damage(definition, level)
	var radius := _area_px(definition, level)
	for target in targets:
		var impact: Vector2 = (target as Node2D).global_position
		EventBus.projectile_hit.emit(impact, Vector2.DOWN, SKILL_ACCENT)
		_damage_area(impact, radius, damage, definition.id, true)


func _execute_aura(definition: SkillDefinition, level: int) -> void:
	if _player == null:
		return
	# Aura is a constant DoT; damage numbers are suppressed to avoid label spam.
	_damage_area(
		_player.global_position,
		_area_px(definition, level),
		_damage(definition, level),
		definition.id,
		false
	)


## Damage every live enemy within `radius` of `center`. Returns the number hit.
func _damage_area(
	center: Vector2, radius: float, damage: int, skill_id: String, show_numbers: bool
) -> int:
	var radius_sq := radius * radius
	var hits := 0
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not _is_available_enemy(enemy):
			continue
		var enemy_node := enemy as Node2D
		if center.distance_squared_to(enemy_node.global_position) > radius_sq:
			continue
		enemy.take_damage(damage)
		EventBus.metrics_damage_dealt.emit(damage, skill_id)
		if show_numbers:
			EventBus.damage_dealt.emit(enemy_node.global_position, damage, false)
		hits += 1
	return hits


func _damage(definition: SkillDefinition, level: int) -> int:
	var base := definition.scaled_damage(level)
	var mult := 1.0
	if _player and _player.has_method("get_damage_multiplier"):
		mult = _player.get_damage_multiplier()
	return maxi(roundi(float(base) * mult), 1)


func _area_px(definition: SkillDefinition, level: int) -> float:
	var units := definition.scaled_area_units(level)
	var mult := 1.0
	if _player and _player.has_method("get_area_multiplier"):
		mult = _player.get_area_multiplier()
	return StatUnits.area_to_pixels(units) * mult


func _random_enemy() -> Node2D:
	var enemies := _alive_enemies()
	if enemies.is_empty():
		return null
	return enemies[randi() % enemies.size()] as Node2D


func _pick_enemies(count: int) -> Array:
	var enemies := _alive_enemies()
	enemies.shuffle()
	return enemies.slice(0, mini(count, enemies.size()))


func _alive_enemies() -> Array:
	var result: Array = []
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if _is_available_enemy(enemy):
			result.append(enemy)
	return result


func _is_available_enemy(enemy: Node) -> bool:
	if not is_instance_valid(enemy) or not enemy is Node2D:
		return false
	if not enemy.has_method("take_damage"):
		return false
	if enemy.has_node("HealthComponent"):
		var health := enemy.get_node("HealthComponent") as HealthComponent
		if health and not health.is_alive():
			return false
	return true


func _can_run() -> bool:
	if _player != null and _player.has_method("is_alive") and not _player.is_alive():
		return false
	return true
