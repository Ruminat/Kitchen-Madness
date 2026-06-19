extends Area2D

const DEFAULT_SPEED := 400.0
const DEFAULT_LIFETIME := 2.5

var direction := Vector2.RIGHT
var damage := 14
var speed := DEFAULT_SPEED
var lifetime := DEFAULT_LIFETIME
var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)
var _owner: Node2D
var _elapsed := 0.0
var _returning := false
var _hit_enemies: Dictionary = {}
var _accent_color := Color(0.85, 0.6, 0.3, 1.0)


func _ready() -> void:
	add_to_group("projectiles")
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= lifetime:
		queue_free()
		return

	if _owner == null or not is_instance_valid(_owner):
		queue_free()
		return

	if not _returning:
		position += direction * speed * delta
		if _elapsed >= lifetime * 0.45:
			_returning = true
	else:
		var to_owner := _owner.global_position - global_position
		if to_owner.length_squared() <= 16.0:
			queue_free()
			return
		position += to_owner.normalized() * speed * delta

	if not arena_bounds.has_point(global_position):
		queue_free()


func setup(
	fire_direction: Vector2,
	bounds: Rect2,
	projectile_damage: int = 14,
	projectile_speed: float = DEFAULT_SPEED,
	projectile_lifetime: float = DEFAULT_LIFETIME,
	texture: Texture2D = null,
	owner: Node2D = null,
	accent_color: Color = Color(0.85, 0.6, 0.3, 1.0)
) -> void:
	direction = fire_direction.normalized()
	damage = projectile_damage
	speed = projectile_speed
	lifetime = projectile_lifetime
	rotation = direction.angle()
	arena_bounds = bounds
	_owner = owner
	_accent_color = accent_color
	_apply_texture(texture)
	_apply_accent(accent_color)
	_setup_trail(accent_color)


func _apply_texture(texture: Texture2D) -> void:
	if texture == null:
		return

	var sprite := get_node_or_null("Visual/Sprite") as Sprite2D
	if sprite:
		sprite.texture = texture


func _apply_accent(accent: Color) -> void:
	var sprite := get_node_or_null("Visual/Sprite") as Sprite2D
	if sprite:
		sprite.modulate = accent.lerp(Color.WHITE, 0.35)


func _setup_trail(accent: Color) -> void:
	if has_node("Trail"):
		return

	var trail := VfxLibrary.create_trail(accent)
	add_child(trail)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("enemies") or not body.has_method("take_damage"):
		return

	var enemy_id: int = body.get_instance_id()
	if _hit_enemies.has(enemy_id):
		return

	body.take_damage(damage)
	_hit_enemies[enemy_id] = true
	EventBus.projectile_hit.emit(global_position, direction, _accent_color)
