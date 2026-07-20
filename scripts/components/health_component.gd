class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died
## Emitted when a hit is evaded (no damage taken, but i-frames still granted).
signal evaded

@export var max_health: int = 100
@export var invincibility_time: float = 0.0
## Chance (0-1) to completely negate an incoming hit while still granting i-frames.
@export_range(0.0, 1.0) var evasion: float = 0.0

var current_health: int = 0
## Armor points. Positive reduces damage; negative (perks) increases it. See StatUnits.
var armor := 0

var _invincible := false


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func is_alive() -> bool:
	return current_health > 0


func is_invincible() -> bool:
	return _invincible


## Apply incoming damage. Returns the damage actually dealt (0 if blocked/evaded).
func take_damage(amount: int) -> int:
	if _invincible or current_health <= 0 or amount <= 0:
		return 0

	# Evasion negates the hit entirely but still grants the usual i-frames.
	if evasion > 0.0 and randf() < evasion:
		evaded.emit()
		if invincibility_time > 0.0:
			_start_invincibility()
		return 0

	var final_amount := StatUnits.apply_armor(amount, armor)
	current_health = maxi(current_health - final_amount, 0)
	health_changed.emit(current_health, max_health)

	if invincibility_time > 0.0:
		_start_invincibility()

	if current_health <= 0:
		died.emit()

	return final_amount


func heal(amount: int) -> void:
	if current_health <= 0:
		return

	current_health = mini(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func increase_max_health(amount: int, heal_amount: int = 0) -> void:
	if amount <= 0:
		return

	max_health += amount
	current_health = mini(current_health + maxi(heal_amount, 0), max_health)
	health_changed.emit(current_health, max_health)


## Add (or, with a negative amount, subtract) armor points.
func increase_armor(amount: int) -> void:
	if amount == 0:
		return

	armor += amount


func set_evasion(value: float) -> void:
	evasion = clampf(value, 0.0, 1.0)


func increase_evasion(amount: float) -> void:
	evasion = clampf(evasion + amount, 0.0, 1.0)


func _start_invincibility() -> void:
	_invincible = true
	await get_tree().create_timer(invincibility_time).timeout
	_invincible = false
