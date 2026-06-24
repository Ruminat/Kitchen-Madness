class_name LootSpawner
extends Node

const DropRates = preload("res://scripts/data/drop_rates.gd")

var pickup_container: Node2D
var health_drop: DropDefinition
var xp_drop_chance: float = DropRates.XP_DROP_CHANCE
var health_drop_chance: float = DropRates.HEALTH_DROP_CHANCE
var max_health_drop_chance: float = DropRates.MAX_HEALTH_DROP_CHANCE


func configure(container: Node2D, health_drop_definition: DropDefinition) -> void:
	pickup_container = container
	health_drop = health_drop_definition
	EventBus.enemy_killed.connect(_on_enemy_killed)


func _on_enemy_killed(enemy: Node, _killer: Node) -> void:
	if pickup_container == null or not is_instance_valid(enemy):
		return

	var spawn_pos := (enemy as Node2D).global_position
	var enemy_definition: EnemyDefinition = null
	if "definition" in enemy:
		enemy_definition = enemy.definition as EnemyDefinition

	if enemy_definition and enemy_definition.xp_drop:
		if DropRates.roll_enemy_drop(xp_drop_chance, enemy_definition):
			_spawn_drop(enemy_definition.xp_drop, spawn_pos)

	if health_drop and enemy_definition:
		if randf() < _health_drop_chance(enemy_definition):
			var offset := Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
			_spawn_drop(health_drop, spawn_pos + offset)


func _health_drop_chance(enemy_definition: EnemyDefinition) -> float:
	var chance: float = DropRates.scaled_drop_chance(health_drop_chance, enemy_definition)
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_health_drop_chance_bonus"):
		chance += player.get_health_drop_chance_bonus()
	return minf(chance, max_health_drop_chance)


func _spawn_drop(drop: DropDefinition, position: Vector2) -> void:
	if drop == null or drop.scene == null:
		return

	var pickup := drop.scene.instantiate()
	pickup_container.add_child(pickup)
	pickup.global_position = position
	if pickup.has_method("setup"):
		pickup.setup(drop)
