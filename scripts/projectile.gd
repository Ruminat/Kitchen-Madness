extends Area2D

const SPEED := 480.0
const DAMAGE := 15
const LIFETIME := 2.0

var direction := Vector2.RIGHT
var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)


func _ready() -> void:
	add_to_group("projectiles")
	get_tree().create_timer(LIFETIME).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

	if not arena_bounds.has_point(global_position):
		queue_free()


func setup(fire_direction: Vector2, bounds: Rect2) -> void:
	direction = fire_direction.normalized()
	rotation = direction.angle()
	arena_bounds = bounds


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(DAMAGE)
		queue_free()
