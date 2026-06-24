class_name BaseEnemy
extends CharacterBody2D

signal died(enemy: CharacterBody2D)

const CONTACT_SLOW_DURATION := 2.0
const CONTACT_SLOW_MULTIPLIER := 0.35
const COLLISION := preload("res://scripts/data/collision_layers.gd")

var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)
var move_speed := 90.0
var target: Node2D
var definition: EnemyDefinition
var _base_move_speed := 90.0
var _slow_timer := 0.0
var _hit_flash_timer := 0.0
var _is_high_detail_active := true
var _is_render_active := true

@onready var visual: Node2D = $Visual
@onready var health_component: HealthComponent = $HealthComponent


func _ready() -> void:
	add_to_group("enemies")
	_setup_collision()
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
	_sync_collision_shape()


func _setup_collision() -> void:
	collision_layer = COLLISION.ENEMY
	collision_mask = COLLISION.ENEMY_MASK
	motion_mode = MOTION_MODE_FLOATING
	_apply_collision_detail()


func _apply_collision_detail() -> void:
	if _is_high_detail_active:
		collision_layer = COLLISION.ENEMY
		collision_mask = COLLISION.ENEMY_MASK
	else:
		collision_layer = 0
		collision_mask = 0


func _sync_collision_shape() -> void:
	var shape_node := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape_node == null or not shape_node.shape is CircleShape2D:
		return

	(shape_node.shape as CircleShape2D).radius = _get_radius()


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


func set_target(target_node: Node2D) -> void:
	target = target_node


func set_screen_detail(render_active: bool, high_detail_active: bool) -> void:
	if render_active != _is_render_active:
		_is_render_active = render_active
		_set_visuals_visible(render_active)

	if high_detail_active != _is_high_detail_active:
		_is_high_detail_active = high_detail_active
		_apply_collision_detail()


func apply_contact_slow(duration: float = CONTACT_SLOW_DURATION) -> void:
	_slow_timer = maxf(_slow_timer, duration)
	_sync_move_speed()


func apply_knockback(direction: Vector2, force: float) -> void:
	if direction.length_squared() <= 0.0001 or force <= 0.0:
		return

	global_position += direction.normalized() * force
	global_position = ArenaClamp.clamp_position(global_position, arena_bounds, _get_radius())


func take_damage(amount: int) -> void:
	if not health_component.is_alive():
		return

	health_component.take_damage(amount)
	_flash_hit()

	if not health_component.is_alive():
		visual.visible = false
		died.emit(self)
		EventBus.enemy_killed.emit(self, null)
		queue_free()


func _physics_process(delta: float) -> void:
	if not health_component.is_alive():
		return

	_update_hit_flash(delta)
	_update_contact_slow(delta)

	var player := _get_target()
	if player == null:
		return

	var direction := _get_move_direction(player, delta)
	if _is_high_detail_active:
		velocity = direction * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		global_position += direction * move_speed * delta
	global_position = ArenaClamp.clamp_position(global_position, arena_bounds, _get_radius())


func _get_target() -> Node2D:
	if is_instance_valid(target):
		return target

	target = get_tree().get_first_node_in_group("player") as Node2D
	return target


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


func _set_visuals_visible(is_visible: bool) -> void:
	var visual_node := _get_visual()
	if visual_node:
		visual_node.visible = is_visible

	var health_bar := get_node_or_null("EnemyHealthBar") as CanvasItem
	if health_bar:
		health_bar.visible = is_visible


func _flash_hit() -> void:
	var visual_node := _get_visual()
	if visual_node == null:
		return
	visual_node.modulate = Color(1.0, 0.5, 0.5)
	_hit_flash_timer = 0.05


func _update_hit_flash(delta: float) -> void:
	if _hit_flash_timer <= 0.0:
		return

	_hit_flash_timer = maxf(_hit_flash_timer - delta, 0.0)
	if _hit_flash_timer <= 0.0:
		var visual_node := _get_visual()
		if visual_node:
			visual_node.modulate = Color.WHITE
