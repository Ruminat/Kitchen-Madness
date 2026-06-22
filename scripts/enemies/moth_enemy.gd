extends BaseEnemy

## Pantry moth with erratic darting movement.

const DART_INTERVAL := 0.2
const DART_STRENGTH := 0.85

var _dart_timer := 0.0
var _dart_direction := Vector2.ZERO


func _get_move_direction(player: Node2D, delta: float) -> Vector2:
	var to_player := player.global_position - global_position
	if to_player.length_squared() < 0.01:
		return Vector2.ZERO

	_dart_timer -= delta
	if _dart_timer <= 0.0:
		_dart_timer = DART_INTERVAL
		var chase := to_player.normalized()
		var jitter := Vector2.from_angle(randf() * TAU) * DART_STRENGTH
		_dart_direction = (chase + jitter).normalized()

	return _dart_direction
