extends CharacterBody2D

signal died

const MOVE_SPEED := 220.0
const CONTACT_DAMAGE := 10

var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)
var _damage_cooldown := 0.0

@onready var visual: Node2D = $Visual
@onready var health_component: HealthComponent = $HealthComponent
@onready var weapon_controller: WeaponController = $WeaponController


func _ready() -> void:
	add_to_group("player")
	health_component.health_changed.connect(_on_health_changed)
	health_component.died.connect(_on_died)
	call_deferred("_emit_initial_health")


func _physics_process(delta: float) -> void:
	if not is_alive():
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

	if health_component.is_invincible():
		visual.modulate.a = 0.4 + 0.6 * abs(sin(Time.get_ticks_msec() * 0.02))
	else:
		visual.modulate.a = 1.0


func is_alive() -> bool:
	return health_component.is_alive()


func get_health() -> int:
	return health_component.current_health


func get_max_health() -> int:
	return health_component.max_health


func setup(bounds: Rect2, projectile_container: Node2D) -> void:
	arena_bounds = bounds
	_clamp_to_arena()
	weapon_controller.setup(projectile_container, bounds)


func set_arena_bounds(bounds: Rect2) -> void:
	arena_bounds = bounds
	_clamp_to_arena()
	weapon_controller.set_arena_bounds(bounds)


func _emit_initial_health() -> void:
	EventBus.player_health_changed.emit(health_component.current_health, health_component.max_health)


func _on_health_changed(current: int, maximum: int) -> void:
	EventBus.player_health_changed.emit(current, maximum)


func _on_died() -> void:
	EventBus.player_died.emit()
	died.emit()


func _clamp_to_arena() -> void:
	global_position = ArenaClamp.clamp_position(global_position, arena_bounds, 14.0)


func _on_hurtbox_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies"):
		return
	if _damage_cooldown > 0.0:
		return

	_damage_cooldown = 0.35
	var damage := CONTACT_DAMAGE
	if body.has_method("get_contact_damage"):
		damage = body.get_contact_damage()
	health_component.take_damage(damage)
