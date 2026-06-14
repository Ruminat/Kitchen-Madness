class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 100
@export var invincibility_time: float = 0.0

var current_health: int = 0

var _invincible := false


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func is_alive() -> bool:
	return current_health > 0


func is_invincible() -> bool:
	return _invincible


func take_damage(amount: int) -> void:
	if _invincible or current_health <= 0:
		return

	current_health = maxi(current_health - amount, 0)
	health_changed.emit(current_health, max_health)

	if invincibility_time > 0.0:
		_start_invincibility()

	if current_health <= 0:
		died.emit()


func heal(amount: int) -> void:
	if current_health <= 0:
		return

	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func _start_invincibility() -> void:
	_invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	_invincible = false
