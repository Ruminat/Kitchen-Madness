extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

const MOVE_SPEED := 220.0
const MAX_HEALTH := 100
const CONTACT_DAMAGE := 10
const INVINCIBILITY_TIME := 1.0

var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)
var health := MAX_HEALTH
var _invincible := false
var _damage_cooldown := 0.0

@onready var visual: Node2D = $Visual


func _ready() -> void:
	add_to_group("player")
	health_changed.emit(health, MAX_HEALTH)


func _physics_process(delta: float) -> void:
	if health <= 0:
		return

	if _damage_cooldown > 0.0:
		_damage_cooldown -= delta

	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if input_dir.length_squared() > 1.0:
		input_dir = input_dir.normalized()

	velocity = input_dir * MOVE_SPEED
	move_and_slide()
	_clamp_to_arena()

	if input_dir.length_squared() > 0.01:
		visual.rotation = input_dir.angle()

	if _invincible:
		visual.modulate.a = 0.4 + 0.6 * abs(sin(Time.get_ticks_msec() * 0.02))
	else:
		visual.modulate.a = 1.0


func set_arena_bounds(bounds: Rect2) -> void:
	arena_bounds = bounds
	_clamp_to_arena()


func take_damage(amount: int) -> void:
	if _invincible or health <= 0:
		return

	health = max(health - amount, 0)
	health_changed.emit(health, MAX_HEALTH)
	_start_invincibility()

	if health <= 0:
		died.emit()


func _start_invincibility() -> void:
	_invincible = true
	await get_tree().create_timer(INVINCIBILITY_TIME).timeout
	_invincible = false
	if is_instance_valid(visual):
		visual.modulate.a = 1.0


func _clamp_to_arena() -> void:
	var half_size := 14.0
	global_position.x = clamp(
		global_position.x,
		arena_bounds.position.x + half_size,
		arena_bounds.end.x - half_size
	)
	global_position.y = clamp(
		global_position.y,
		arena_bounds.position.y + half_size,
		arena_bounds.end.y - half_size
	)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies"):
		return
	if _damage_cooldown > 0.0:
		return

	_damage_cooldown = 0.35
	take_damage(CONTACT_DAMAGE)
