extends BaseWeapon

var _cooldown := 0.0


func _process(delta: float) -> void:
	if not _player_is_alive():
		return

	_cooldown -= delta
	if _cooldown > 0.0:
		return

	_deploy_turret()
	var fire_rate := definition.fire_rate if definition else 2.5
	_cooldown = fire_rate / get_fire_rate_multiplier()


func _player_is_alive() -> bool:
	var player := get_parent().get_parent() as CharacterBody2D
	if player == null:
		return false

	var health_component := player.get_node_or_null("HealthComponent") as HealthComponent
	return health_component == null or health_component.is_alive()


func _deploy_turret() -> void:
	if definition == null or definition.projectile_scene == null:
		return

	var container := get_projectile_container()
	var player := get_parent().get_parent() as Node2D
	if container == null or player == null:
		return

	play_fire_feedback()
	var turret := Node2D.new()
	turret.set_script(load("res://scripts/weapons/toaster_turret.gd"))
	container.add_child(turret)
	turret.global_position = player.global_position
	if turret.has_method("setup"):
		turret.setup(
			definition,
			arena_bounds,
			container,
			get_damage(),
			get_fire_rate_multiplier(),
			_crit_chance,
			_crit_damage
		)
