extends BaseEnemy

## Fast enemy with slight zigzag movement.

const ZIGZAG_INTERVAL := 0.35
const ZIGZAG_STRENGTH := 0.55

var _zigzag_timer := 0.0
var _zigzag_sign := 1.0


func _get_move_direction(player: Node2D, delta: float) -> Vector2:
	var to_player := player.global_position - global_position
	if to_player.length_squared() < 0.01:
		return Vector2.ZERO

	var forward := to_player.normalized()
	_zigzag_timer -= delta
	if _zigzag_timer <= 0.0:
		_zigzag_timer = ZIGZAG_INTERVAL
		_zigzag_sign = -_zigzag_sign

	var sideways := forward.orthogonal() * _zigzag_sign * ZIGZAG_STRENGTH
	return (forward + sideways).normalized()
