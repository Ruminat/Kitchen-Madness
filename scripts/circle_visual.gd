extends Node2D
## Simple placeholder circle drawn in code.

@export var radius: float = 16.0
@export var color: Color = Color.WHITE


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)


func set_color(new_color: Color) -> void:
	color = new_color
	queue_redraw()
