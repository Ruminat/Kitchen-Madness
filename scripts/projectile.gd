extends Area2D

const DEFAULT_SPEED := 480.0
const DEFAULT_LIFETIME := 2.0

var direction := Vector2.RIGHT
var damage := 15
var speed := DEFAULT_SPEED
var lifetime := DEFAULT_LIFETIME
var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)


func _ready() -> void:
	add_to_group("projectiles")
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	if not arena_bounds.has_point(global_position):
		queue_free()


func setup(
	fire_direction: Vector2,
	bounds: Rect2,
	projectile_damage: int = 15,
	projectile_speed: float = DEFAULT_SPEED,
	projectile_lifetime: float = DEFAULT_LIFETIME,
	texture: Texture2D = null
) -> void:
	direction = fire_direction.normalized()
	damage = projectile_damage
	speed = projectile_speed
	lifetime = projectile_lifetime
	rotation = direction.angle()
	arena_bounds = bounds
	_apply_texture(texture)


func _apply_texture(texture: Texture2D) -> void:
	if texture == null:
		return

	var sprite := get_node_or_null("Visual/Sprite") as Sprite2D
	if sprite:
		sprite.texture = texture


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
