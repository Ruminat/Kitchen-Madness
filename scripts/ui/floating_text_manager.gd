extends Control

const DAMAGE_COLOR := Color(1.0, 0.88, 0.82, 1.0)
const CRIT_COLOR := Color(1.0, 0.82, 0.2, 1.0)
const XP_COLOR := Color(0.45, 0.88, 1.0, 1.0)
const HEALTH_COLOR := Color(0.4, 1.0, 0.5, 1.0)
const POOL_SIZE := 32
const SPREAD_RADIUS := 40.0

var _damage_font: Font

var _pool: Array[Label] = []
var _active: Array[Label] = []
var _hit_positions: Dictionary = {}
var _hit_counts: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	EventBus.damage_dealt.connect(_on_damage_dealt)
	EventBus.pickup_collected.connect(_on_pickup_collected)
	_load_font()
	_init_pool()


func _load_font() -> void:
	_damage_font = load("res://assets/fonts/bangers.ttf")


func _init_pool() -> void:
	for index in POOL_SIZE:
		var label := _create_pooled_label()
		_pool.append(label)


func _create_pooled_label() -> Label:
	var label := Label.new()
	label.set_script(load("res://scripts/ui/floating_text.gd"))
	label.visible = false
	if _damage_font:
		label.add_theme_font_override("font", _damage_font)
	add_child(label)
	return label


func _get_pooled_label() -> Label:
	if _pool.is_empty():
		return _create_pooled_label()
	var label: Label = _pool.pop_back() as Label
	_active.append(label)
	return label


func _return_to_pool(label: Label) -> void:
	_active.erase(label)
	label.visible = false
	label.modulate.a = 0.0
	_pool.append(label)


func _on_damage_dealt(world_pos: Vector2, amount: int, is_crit: bool) -> void:
	var color := CRIT_COLOR if is_crit else DAMAGE_COLOR
	var spread_pos := _get_spread_position(world_pos)
	_spawn_damage(str(amount), spread_pos, color, is_crit)


func _get_spread_position(base_pos: Vector2) -> Vector2:
	var pos_key := Vector2i(roundi(base_pos.x), roundi(base_pos.y))
	var current_time := Time.get_ticks_msec()

	_cleanup_old_hits(current_time)

	var hit_count := 0
	if _hit_counts.has(pos_key):
		hit_count = _hit_counts[pos_key]

	_hit_counts[pos_key] = hit_count + 1
	_hit_positions[pos_key] = current_time

	if hit_count == 0:
		return base_pos

	var angle := (TAU / 8.0) * hit_count
	var offset := Vector2(cos(angle), sin(angle)) * SPREAD_RADIUS
	return base_pos + offset


func _cleanup_old_hits(current_time: int) -> void:
	var to_remove: Array[Vector2i] = []
	for pos_key in _hit_positions.keys():
		if current_time - _hit_positions[pos_key] > 100:
			to_remove.append(pos_key)
	for pos_key in to_remove:
		_hit_positions.erase(pos_key)
		_hit_counts.erase(pos_key)


func _on_pickup_collected(type: StringName, world_pos: Vector2, value: int) -> void:
	if type == &"health":
		_spawn("+%d HP" % value, world_pos, HEALTH_COLOR)
	elif type.begins_with(&"xp") or value > 0:
		_spawn("+%d XP" % value, world_pos, XP_COLOR)


func _spawn_damage(text_value: String, world_pos: Vector2, color: Color, is_crit: bool) -> void:
	var label := _get_pooled_label()
	label.visible = true
	label.modulate.a = 1.0
	if label.has_method("play_damage"):
		label.play_damage(text_value, _world_to_canvas(world_pos), color, is_crit)
	else:
		label.play(text_value, _world_to_canvas(world_pos), color)
		if is_crit:
			label.scale = Vector2(1.5, 1.5)
		else:
			label.scale = Vector2.ONE
	if label.has_signal("finished"):
		if not label.finished.is_connected(_return_to_pool.bind(label)):
			label.finished.connect(_return_to_pool.bind(label), CONNECT_ONE_SHOT)


func _spawn(text_value: String, world_pos: Vector2, color: Color) -> void:
	var label := _get_pooled_label()
	label.visible = true
	label.modulate.a = 1.0
	label.scale = Vector2.ONE
	if label.has_method("play"):
		label.play(text_value, _world_to_canvas(world_pos), color)
	if label.has_signal("finished"):
		if not label.finished.is_connected(_return_to_pool.bind(label)):
			label.finished.connect(_return_to_pool.bind(label), CONNECT_ONE_SHOT)


func _world_to_canvas(world_pos: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform() * world_pos
