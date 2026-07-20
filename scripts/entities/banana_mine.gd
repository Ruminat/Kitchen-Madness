extends Node2D
## A single Banana Mine hazard: sits until an enemy enters its blast radius, then
## detonates for area damage. Despawns after a lifetime so mines can't pile up.
## Spawned with fully-resolved stats by EntityManager.

const ACCENT := Color(0.95, 0.85, 0.25, 1.0)
const LIFETIME := 12.0

var _damage := 50
var _radius := 0.0
var _life := LIFETIME
var _armed := false


func setup(damage: int, radius_px: float) -> void:
	_damage = damage
	_radius = maxf(radius_px, 1.0)
	# Brief arming delay so a mine dropped onto an enemy doesn't detonate instantly.
	_armed = false


func _process(delta: float) -> void:
	_life -= delta
	if _life <= 0.0:
		queue_free()
		return

	if not _armed:
		if _life <= LIFETIME - 0.25:
			_armed = true
		return

	if EntityCombat.nearest_enemy(get_tree(), global_position, _radius) != null:
		_detonate()


func _detonate() -> void:
	EventBus.projectile_hit.emit(global_position, Vector2.UP, ACCENT)
	EntityCombat.damage_in_radius(get_tree(), global_position, _radius, _damage, "banana_mine")
	queue_free()
