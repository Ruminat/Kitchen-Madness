class_name ArenaClamp
extends RefCounted


static func clamp_position(position: Vector2, bounds: Rect2, half_size: float) -> Vector2:
	return Vector2(
		clampf(position.x, bounds.position.x + half_size, bounds.end.x - half_size),
		clampf(position.y, bounds.position.y + half_size, bounds.end.y - half_size)
	)
