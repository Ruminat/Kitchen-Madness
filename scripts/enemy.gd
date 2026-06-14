extends CharacterBody2D

signal died(enemy: CharacterBody2D)

const CHASE_SPEED := 90.0

var health := 30
var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)

@onready var visual: Node2D = $Visual


func _ready() -> void:
	add_to_group("enemies")


func _physics_process(_delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	var direction := (player.global_position - global_position).normalized()
	velocity = direction * CHASE_SPEED
	move_and_slide()
	_clamp_to_arena()

	if direction.length_squared() > 0.01:
		visual.rotation = direction.angle()


func set_arena_bounds(bounds: Rect2) -> void:
	arena_bounds = bounds


func take_damage(amount: int) -> void:
	health -= amount
	visual.modulate = Color(1.0, 0.5, 0.5)
	await get_tree().create_timer(0.05).timeout
	if not is_instance_valid(self):
		return
	visual.modulate = Color.WHITE

	if health <= 0:
		died.emit(self)
		queue_free()


func _clamp_to_arena() -> void:
	var half_size := 12.0
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
