class_name XpSystem
extends Node

const BASE_XP_TO_LEVEL := 200

var level := 1
var current_xp := 0
var xp_to_next := BASE_XP_TO_LEVEL


func _ready() -> void:
	EventBus.pickup_collected.connect(_on_pickup_collected)
	_emit_xp_changed()


func add_xp(amount: int) -> void:
	if amount <= 0:
		return

	current_xp += amount
	while current_xp >= xp_to_next:
		current_xp -= xp_to_next
		level += 1
		xp_to_next = _xp_required_for_level(level)
		EventBus.level_up.emit(level)
	_emit_xp_changed()


func _on_pickup_collected(type: StringName, _world_pos: Vector2, value: int) -> void:
	if type == &"health":
		return
	if type.begins_with(&"xp") or value > 0:
		add_xp(_scale_xp(value))


func _scale_xp(amount: int) -> int:
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_xp_multiplier"):
		return maxi(roundi(float(amount) * player.get_xp_multiplier()), 1)
	return amount


func _xp_required_for_level(next_level: int) -> int:
	return BASE_XP_TO_LEVEL + (next_level - 1) * 50


func _emit_xp_changed() -> void:
	EventBus.xp_changed.emit(current_xp, xp_to_next, level)
