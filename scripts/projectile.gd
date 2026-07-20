extends Area2D

const DEFAULT_SPEED := 480.0
const DEFAULT_LIFETIME := 2.0

var direction := Vector2.RIGHT
var damage := 15
var speed := DEFAULT_SPEED
var lifetime := DEFAULT_LIFETIME
var arena_bounds := Rect2(-440.0, -240.0, 880.0, 480.0)
var _accent_color := Color(0.95, 0.82, 0.45, 1.0)
var _crit_chance := 0.05
var _crit_damage := 1.5
## Splash radius in pixels; 0 = single-target hit only.
var _splash_radius := 0.0


func _ready() -> void:
	add_to_group("projectiles")
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	if not arena_bounds.has_point(global_position):
		queue_free()


func setup(
	fire_direction: Vector2,
	bounds: Rect2,
	projectile_damage: int = 15,
	projectile_speed: float = DEFAULT_SPEED,
	projectile_lifetime: float = DEFAULT_LIFETIME,
	texture: Texture2D = null,
	accent_color: Color = Color(0.95, 0.82, 0.45, 1.0)
) -> void:
	direction = fire_direction.normalized()
	damage = projectile_damage
	speed = projectile_speed
	lifetime = projectile_lifetime
	rotation = direction.angle()
	arena_bounds = bounds
	_accent_color = accent_color
	_apply_texture(texture)
	_apply_accent(accent_color)
	_setup_trail(accent_color)


func _apply_texture(texture: Texture2D) -> void:
	if texture == null:
		return

	var sprite := get_node_or_null("Visual/Sprite") as Sprite2D
	if sprite:
		sprite.texture = texture


func _apply_accent(accent: Color) -> void:
	var sprite := get_node_or_null("Visual/Sprite") as Sprite2D
	if sprite:
		sprite.modulate = accent.lerp(Color.WHITE, 0.35)


func _setup_trail(accent: Color) -> void:
	if has_node("Trail"):
		return

	var trail := VfxLibrary.create_trail(accent)
	add_child(trail)


func set_crit_stats(crit_chance: float, crit_damage: float) -> void:
	_crit_chance = clampf(crit_chance, 0.0, 1.0)
	_crit_damage = maxf(crit_damage, 1.0)


func set_splash_radius(radius: float) -> void:
	_splash_radius = maxf(radius, 0.0)


## Scale the sprite so the projectile renders at `diameter_px` wide (matching the
## weapon that fired it).
func set_visual_size(diameter_px: float) -> void:
	var sprite := get_node_or_null("Visual/Sprite") as Sprite2D
	if sprite == null or sprite.texture == null or diameter_px <= 0.0:
		return
	var width := float(sprite.texture.get_width())
	if width <= 0.0:
		return
	var scale := diameter_px / width
	sprite.scale = Vector2(scale, scale)


func _roll_crit() -> bool:
	return randf() < _crit_chance


func _on_body_entered(body: Node2D) -> void:
	if not (body.is_in_group("enemies") and body.has_method("take_damage")):
		return

	var is_crit := _roll_crit()
	var final_damage := damage
	if is_crit:
		final_damage = maxi(roundi(float(damage) * _crit_damage), 1)

	EventBus.projectile_hit.emit(global_position, direction, _accent_color)
	if _splash_radius > 0.0:
		_apply_splash(body, final_damage, is_crit)
	else:
		_apply_hit(body, final_damage, is_crit)
	queue_free()


## Single-target hit: damage the struck enemy and report it.
func _apply_hit(body: Node2D, final_damage: int, is_crit: bool) -> void:
	body.take_damage(final_damage)
	EventBus.damage_dealt.emit(body.global_position, final_damage, is_crit)
	EventBus.metrics_damage_dealt.emit(final_damage, "")


## Splash hit: every live enemy within the splash radius of impact takes the damage.
func _apply_splash(struck: Node2D, final_damage: int, is_crit: bool) -> void:
	var impact := global_position
	var radius_sq := _splash_radius * _splash_radius
	var hit_any := false
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(enemy) or not enemy is Node2D:
			continue
		if not enemy.has_method("take_damage"):
			continue
		if impact.distance_squared_to((enemy as Node2D).global_position) > radius_sq:
			continue
		enemy.take_damage(final_damage)
		EventBus.damage_dealt.emit((enemy as Node2D).global_position, final_damage, is_crit)
		EventBus.metrics_damage_dealt.emit(final_damage, "")
		hit_any = true
	# Guarantee the directly-struck enemy is always damaged even if it left the group.
	if not hit_any:
		_apply_hit(struck, final_damage, is_crit)
