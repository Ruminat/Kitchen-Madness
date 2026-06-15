class_name Arena
extends Node2D

const DEFAULT_VIEW_SIZE := Vector2(880.0, 480.0)
const DEFAULT_SIZE := DEFAULT_VIEW_SIZE * 3.0

@export var arena_size: Vector2 = DEFAULT_SIZE


func get_bounds() -> Rect2:
	return Rect2(-arena_size * 0.5, arena_size)
