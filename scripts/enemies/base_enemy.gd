class_name BaseEnemy
extends CharacterBody2D

signal died(enemy: CharacterBody2D)

const CONTACT_SLOW_DURATION := 2.0
const CONTACT_SLOW_MULTIPLIER := 0.35

var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)
var move_speed := 90.0
var definition: EnemyDefinition
var _base_move_speed := 90.0
var _slow_timer := 0.0

@onready var visual: Node2D = $Visual
@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	add_to_group("enemies")
	if definition:
		_apply_definition()


func configure(enemy_definition: EnemyDefinition) -> void:
	definition = enemy_definition
	if definition == null:
		return

	if is_node_ready():
		_apply_definition()


func _apply_definition() -> void:
	if definition == null:
		return

	move_speed = definition.move_speed
	_base_move_speed = move_speed
	_sync_move_speed()

	var health := _get_health_component()
	if health == null:
		push_error("BaseEnemy: missing HealthComponent on %s" % name)
		return

	health.max_health = definition.max_health
	health.current_health = definition.max_health
	health.health_changed.emit(health.current_health, health.max_health)
	_apply_visual(definition)
	_setup_health_bar(definition)


func _setup_health_bar(enemy_definition: EnemyDefinition) -> void:
	if enemy_definition.max_health < 50:
		return
	if has_node("EnemyHealthBar"):
		return

	var bar := Node2D.new()
	bar.name = "EnemyHealthBar"
	bar.set_script(load("res://scripts/components/enemy_health_bar.gd"))
	add_child(bar)


func _get_health_component() -> HealthComponent:
	if health_component:
		return health_component
	return get_node_or_null("HealthComponent") as HealthComponent


func set_arena_bounds(bounds: Rect2) -> void:
	arena_bounds = bounds


func apply_contact_slow(duration: float = CONTACT_SLOW_DURATION) -> void:
	_slow_timer = maxf(_slow_timer, duration)
	_sync_move_speed()


func take_damage(amount: int) -> void:
	if not health_component.is_alive():
		return

	health_component.take_damage(amount)
	EventBus.damage_dealt.emit(global_position, amount, false)
	EventBus.metrics_damage_dealt.emit(amount, "")
	_flash_hit()

	if not health_component.is_alive():
		visual.visible = false
		died.emit(self)
		EventBus.enemy_killed.emit(self, null)
		queue_free()


func _physics_process(delta: float) -> void:
	if not health_component.is_alive():
		return

	_update_contact_slow(delta)

	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var direction := _get_move_direction(player, delta)
	velocity = direction * move_speed
	move_and_slide()
	global_position = ArenaClamp.clamp_position(global_position, arena_bounds, _get_radius())


func _get_move_direction(player: Node2D, _delta: float) -> Vector2:
	return (player.global_position - global_position).normalized()


func _update_contact_slow(delta: float) -> void:
	if _slow_timer <= 0.0:
		return

	_slow_timer = maxf(_slow_timer - delta, 0.0)
	_sync_move_speed()


func _sync_move_speed() -> void:
	if _slow_timer > 0.0:
		move_speed = _base_move_speed * CONTACT_SLOW_MULTIPLIER
	else:
		move_speed = _base_move_speed


func get_contact_damage() -> int:
	if definition:
		return definition.contact_damage
	return 10


func get_collision_radius() -> float:
	return _get_radius()


func _get_radius() -> float:
	if definition:
		return definition.radius
	return 12.0


func _apply_visual(enemy_definition: EnemyDefinition) -> void:
	var visual_node := _get_visual()
	if visual_node == null:
		return

	if visual_node.has_method("set_color"):
		visual_node.set_color(enemy_definition.color)
	if "color" in visual_node:
		visual_node.color = enemy_definition.color
	if "radius" in visual_node:
		visual_node.radius = enemy_definition.radius
	if visual_node.has_method("queue_redraw"):
		visual_node.queue_redraw()


func _get_visual() -> Node2D:
	if visual:
		return visual
	return get_node_or_null("Visual") as Node2D


func _flash_hit() -> void:
	visual.modulate = Color(1.0, 0.5, 0.5)
	await get_tree().create_timer(0.05).timeout
	if not is_instance_valid(self):
		return
	visual.modulate = Color.WHITE
