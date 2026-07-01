class_name IdleSquash
extends Node
## Reusable Brotato-style idle squash-and-stretch bob.
##
## Animates only its parent Node2D visual transform (a volume-preserving scale
## wobble plus a small vertical bob), never the owning body or its collision
## shape. Add it as a child of a dedicated visual/transform node (e.g. "Visual")
## so gameplay physics stay untouched.

@export var cycle_seconds := 1.1
@export var squash_amount := 0.06
@export var bob_pixels := 2.0

var _target: Node2D
var _base_scale := Vector2.ONE
var _base_position := Vector2.ZERO
var _time := 0.0
var _active := true


func _ready() -> void:
	_target = get_parent() as Node2D
	if _target == null:
		set_process(false)
		return

	_base_scale = _target.scale
	_base_position = _target.position
	# Desync instances deterministically so swarms do not pulse in unison.
	_time = float(get_instance_id() % 1009) / 1009.0 * cycle_seconds


func _process(delta: float) -> void:
	if not _active or _target == null or not _target.visible:
		return

	_time += delta
	var wave := sin(_time / maxf(cycle_seconds, 0.01) * TAU)
	_target.scale = Vector2(
		_base_scale.x * (1.0 + squash_amount * wave),
		_base_scale.y * (1.0 - squash_amount * wave),
	)
	# Bob down on the squash half of the cycle so it reads as grounded weight.
	_target.position = _base_position + Vector2(0.0, bob_pixels * maxf(wave, 0.0))


## Enables/disables the bob; restores the rest pose when disabled (e.g. off-screen).
func set_active(active: bool) -> void:
	_active = active
	if not active and _target != null:
		_target.scale = _base_scale
		_target.position = _base_position
