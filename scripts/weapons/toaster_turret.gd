extends Node2D

var _definition: WeaponDefinition
var _arena_bounds := Rect2()
var _projectile_container: Node2D
var _damage := 10
var _fire_rate_multiplier := 1.0
var _lifetime := 5.0
var _fire_cooldown := 0.0
var _sprite: Sprite2D
var _recoil_timer := 0.0
var _crit_chance := 0.05
var _crit_damage := 1.5


func setup(
	definition: WeaponDefinition,
	bounds: Rect2,
	projectile_container: Node2D,
	damage: int,
	fire_rate_multiplier: float,
	crit_chance: float = 0.05,
	crit_damage: float = 1.5
) -> void:
	_definition = definition
	_arena_bounds = bounds
	_projectile_container = projectile_container
	_damage = damage
	_fire_rate_multiplier = fire_rate_multiplier
	_crit_chance = crit_chance
	_crit_damage = crit_damage
	_lifetime = definition.turret_duration if definition else 5.0
	_fire_cooldown = 0.0
	_setup_visual()
	get_tree().create_timer(_lifetime).timeout.connect(queue_free)


func _process(delta: float) -> void:
	_recoil_timer = maxf(_recoil_timer - delta, 0.0)
	_fire_cooldown -= delta
	var target := _find_nearest_enemy()
	_aim_visual(target)

	if _fire_cooldown > 0.0:
		return

	if target == null:
		return

	_fire_at(target)
	var fire_rate := _definition.turret_fire_rate if _definition else 0.5
	_fire_cooldown = fire_rate / maxf(_fire_rate_multiplier, 0.1)


func _find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var nearest_dist_sq := INF

	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not _is_available_enemy(enemy):
			continue
		var enemy_node := enemy as Node2D
		var dist_sq := global_position.distance_squared_to(enemy_node.global_position)
		if dist_sq < nearest_dist_sq:
			nearest_dist_sq = dist_sq
			nearest = enemy_node

	return nearest


func _fire_at(target: Node2D) -> void:
	if _definition == null or _definition.projectile_scene == null or _projectile_container == null:
		return

	AudioManager.play_shoot_sound("turret")
	var direction := (target.global_position - global_position).normalized()
	var projectile := _definition.projectile_scene.instantiate()
	_recoil_timer = 0.12
	if projectile.has_method("setup"):
		projectile.setup(
			direction,
			_arena_bounds,
			_damage,
			_definition.projectile_speed,
			_definition.projectile_lifetime,
			_definition.projectile_texture,
			_definition.vfx_accent
		)
	if projectile.has_method("set_crit_stats"):
		projectile.set_crit_stats(_crit_chance, _crit_damage)
	_projectile_container.add_child(projectile)
	projectile.global_position = global_position


func _setup_visual() -> void:
	if _definition == null or _definition.icon == null:
		return
	_sprite = Sprite2D.new()
	_sprite.name = "TurretSprite"
	_sprite.texture = _definition.icon
	_sprite.scale = Vector2(0.24, 0.24)
	add_child(_sprite)


func _aim_visual(target: Node2D) -> void:
	if _sprite == null or target == null:
		return

	var direction := (target.global_position - global_position).normalized()
	rotation = direction.angle()
	var recoil_alpha := _recoil_timer / 0.12 if _recoil_timer > 0.0 else 0.0
	_sprite.position = -direction * 5.0 * recoil_alpha


func _is_available_enemy(enemy: Node) -> bool:
	if not is_instance_valid(enemy) or not enemy is Node2D:
		return false
	if enemy.has_node("HealthComponent"):
		var health := enemy.get_node("HealthComponent") as HealthComponent
		if health and not health.is_alive():
			return false
	return true
