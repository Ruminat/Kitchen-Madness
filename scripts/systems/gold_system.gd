class_name GoldSystem
extends Node

var gold := 0


func _ready() -> void:
	EventBus.enemy_killed.connect(_on_enemy_killed)
	_emit_gold_changed()


func add_gold(amount: int) -> void:
	if amount <= 0:
		return

	gold += amount
	_emit_gold_changed()


func can_afford(cost: int) -> bool:
	return gold >= cost


func spend_gold(amount: int) -> bool:
	if amount <= 0:
		return true
	if gold < amount:
		return false

	gold -= amount
	_emit_gold_changed()
	return true


func _on_enemy_killed(enemy: Node, _killer: Node) -> void:
	if not is_instance_valid(enemy):
		return

	var enemy_definition: EnemyDefinition = null
	if "definition" in enemy:
		enemy_definition = enemy.definition as EnemyDefinition

	if enemy_definition and enemy_definition.gold_reward > 0:
		var reward := enemy_definition.gold_reward
		var player := get_tree().get_first_node_in_group("player")
		if player and player.has_method("get_gold_multiplier"):
			reward = maxi(roundi(float(reward) * player.get_gold_multiplier()), 1)
		add_gold(reward)


func _emit_gold_changed() -> void:
	EventBus.gold_changed.emit(gold)
