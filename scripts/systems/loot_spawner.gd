class_name LootSpawner
extends Node

const HEALTH_DROP_CHANCE := 0.05

var pickup_container: Node2D
var health_drop: DropDefinition


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
		_spawn_drop(enemy_definition.xp_drop, spawn_pos)

	if health_drop and randf() < HEALTH_DROP_CHANCE:
		var offset := Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
		_spawn_drop(health_drop, spawn_pos + offset)


func _spawn_drop(drop: DropDefinition, position: Vector2) -> void:
	if drop == null or drop.scene == null:
		return

	var pickup := drop.scene.instantiate()
	pickup_container.add_child(pickup)
	pickup.global_position = position
	if pickup.has_method("setup"):
		pickup.setup(drop)
