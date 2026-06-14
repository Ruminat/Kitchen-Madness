extends Control

const DAMAGE_COLOR := Color(1.0, 0.88, 0.82, 1.0)
const CRIT_COLOR := Color(1.0, 0.82, 0.2, 1.0)
const XP_COLOR := Color(0.45, 0.88, 1.0, 1.0)
const HEALTH_COLOR := Color(0.4, 1.0, 0.5, 1.0)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.pickup_collected.connect(_on_pickup_collected)


func _on_damage_dealt(world_pos: Vector2, amount: int, is_crit: bool) -> void:
	var color := CRIT_COLOR if is_crit else DAMAGE_COLOR
	_spawn(str(amount), world_pos, color)


func _on_pickup_collected(type: StringName, world_pos: Vector2, value: int) -> void:
	if type == &"health":
		_spawn("+%d HP" % value, world_pos, HEALTH_COLOR)
	elif type.begins_with(&"xp") or value > 0:
		_spawn("+%d XP" % value, world_pos, XP_COLOR)


func _spawn(text_value: String, world_pos: Vector2, color: Color) -> void:
	var label := Label.new()
	label.set_script(load("res://scripts/ui/floating_text.gd"))
	add_child(label)
	label.play(text_value, _world_to_canvas(world_pos), color)


func _world_to_canvas(world_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * world_pos
