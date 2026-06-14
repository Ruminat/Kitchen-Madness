class_name BasePickup
extends Node2D

const MAGNET_SPEED := 320.0
const COLLECT_DISTANCE := 18.0

var definition: DropDefinition
var _collected := false


func setup(drop: DropDefinition) -> void:
	definition = drop
	_apply_visual()


func _physics_process(delta: float) -> void:
	if _collected:
		return

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var distance := global_position.distance_to(player.global_position)
	var magnet_radius := definition.magnet_radius if definition else 48.0

	if distance < COLLECT_DISTANCE:
		_collect(player)
	elif distance < magnet_radius:
		var direction := (player.global_position - global_position).normalized()
		global_position += direction * MAGNET_SPEED * delta


func collect(_player: Node) -> void:
	var pickup_type := StringName(definition.id if definition else "")
	var value := definition.value if definition else 0
	EventBus.pickup_collected.emit(pickup_type, global_position, value)


func _collect(player: Node) -> void:
	_collected = true
	collect(player)
	queue_free()


func _apply_visual() -> void:
	if definition == null:
		return

	var visual := get_node_or_null("Visual")
	if visual == null:
		return

	if visual.has_method("set_color"):
		visual.set_color(definition.color)
	if "color" in visual:
		visual.color = definition.color
	if visual.has_method("queue_redraw"):
		visual.queue_redraw()
