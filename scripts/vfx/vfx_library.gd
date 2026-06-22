class_name VfxLibrary
extends RefCounted

const DEATH_PARTICLE_AMOUNT := 7
const IMPACT_PARTICLE_AMOUNT := 4
const TRAIL_PARTICLE_AMOUNT := 5

static var _particle_texture: Texture2D
static var _glow_texture: Texture2D
static var _spark_texture: Texture2D
static var _additive_material: CanvasItemMaterial


static func get_particle_texture() -> Texture2D:
	if _particle_texture == null:
		var image := _make_soft_circle_image(18, 0.58, 2.4)
		_particle_texture = ImageTexture.create_from_image(image)
	return _particle_texture


static func get_glow_texture() -> Texture2D:
	if _glow_texture == null:
		_glow_texture = ImageTexture.create_from_image(_make_soft_circle_image(32, 0.42, 2.0))
	return _glow_texture


static func get_spark_texture() -> Texture2D:
	if _spark_texture == null:
		var image := Image.create(36, 10, false, Image.FORMAT_RGBA8)
		var center := Vector2(6.0, 5.0)
		for y in image.get_height():
			for x in image.get_width():
				var point := Vector2(float(x), float(y))
				var length_fade: float = 1.0 - clampf((point.x - center.x) / 30.0, 0.0, 1.0)
				var width_fade: float = 1.0 - clampf(absf(point.y - center.y) / 5.0, 0.0, 1.0)
				var alpha := pow(length_fade, 1.35) * pow(width_fade, 2.1)
				image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
		_spark_texture = ImageTexture.create_from_image(image)
	return _spark_texture


static func get_additive_material() -> CanvasItemMaterial:
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	return _additive_material


static func configure_death_burst(particles: GPUParticles2D, accent: Color) -> void:
	particles.texture = get_particle_texture()
	particles.amount = DEATH_PARTICLE_AMOUNT
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.32
	particles.fixed_fps = 60
	particles.emitting = false
	particles.visibility_rect = Rect2(-72.0, -72.0, 144.0, 144.0)
	particles.material = null

	var material := ParticleProcessMaterial.new()
	material.particle_flag_disable_z = true
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 4.0
	material.direction = Vector3(0.0, -1.0, 0.0)
	material.spread = 180.0
	material.initial_velocity_min = 35.0
	material.initial_velocity_max = 95.0
	material.gravity = Vector3.ZERO
	material.scale_min = 1.1
	material.scale_max = 2.5
	material.angular_velocity_min = -120.0
	material.angular_velocity_max = 120.0
	material.color_ramp = _make_combat_ramp(accent, accent.lightened(0.18))
	material.scale_curve = _make_curve_texture(
		[
			Vector2(0.0, 0.2),
			Vector2(0.18, 1.0),
			Vector2(1.0, 0.25),
		]
	)
	particles.process_material = material


static func configure_impact_spark(
	particles: GPUParticles2D, accent: Color, direction: Vector2
) -> void:
	particles.texture = get_spark_texture()
	particles.amount = IMPACT_PARTICLE_AMOUNT
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.13
	particles.fixed_fps = 60
	particles.emitting = false
	particles.visibility_rect = Rect2(-48.0, -48.0, 96.0, 96.0)
	particles.material = get_additive_material()

	var hit_direction := direction
	if hit_direction.length_squared() <= 0.001:
		hit_direction = Vector2.UP

	var material := ParticleProcessMaterial.new()
	material.particle_flag_disable_z = true
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 2.0
	material.direction = Vector3(hit_direction.x, hit_direction.y, 0.0)
	material.spread = 28.0
	material.initial_velocity_min = 75.0
	material.initial_velocity_max = 130.0
	material.gravity = Vector3.ZERO
	material.scale_min = 0.42
	material.scale_max = 0.95
	material.angle_min = rad_to_deg(hit_direction.angle()) - 8.0
	material.angle_max = rad_to_deg(hit_direction.angle()) + 8.0
	material.color_ramp = _make_combat_ramp(accent.lightened(0.24), Color.WHITE)
	material.scale_curve = _make_curve_texture(
		[
			Vector2(0.0, 1.0),
			Vector2(0.7, 0.55),
			Vector2(1.0, 0.05),
		]
	)
	particles.process_material = material


static func create_trail(accent: Color) -> GPUParticles2D:
	var particles := GPUParticles2D.new()
	particles.name = "Trail"
	particles.texture = get_particle_texture()
	particles.local_coords = false
	particles.amount = TRAIL_PARTICLE_AMOUNT
	particles.lifetime = 0.16
	particles.preprocess = 0.06
	particles.fixed_fps = 60
	particles.emitting = true
	particles.visibility_rect = Rect2(-40.0, -40.0, 80.0, 80.0)
	particles.material = null

	var material := ParticleProcessMaterial.new()
	material.particle_flag_disable_z = true
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	material.direction = Vector3.ZERO
	material.spread = 0.0
	material.initial_velocity_min = 0.0
	material.initial_velocity_max = 8.0
	material.gravity = Vector3.ZERO
	material.scale_min = 0.45
	material.scale_max = 1.0
	material.color_ramp = _make_combat_ramp(accent, accent.lightened(0.18))
	material.scale_curve = _make_curve_texture(
		[
			Vector2(0.0, 0.35),
			Vector2(0.2, 1.0),
			Vector2(1.0, 0.0),
		]
	)
	particles.process_material = material
	return particles


static func add_projectile_glow(projectile: Node2D, accent: Color) -> void:
	if projectile.has_node("Visual/Glow"):
		return

	var visual := projectile.get_node_or_null("Visual") as Node2D
	if visual == null:
		return

	var glow := Sprite2D.new()
	glow.name = "Glow"
	glow.texture = get_glow_texture()
	glow.material = get_additive_material()
	glow.modulate = Color(accent.r, accent.g, accent.b, 0.38)
	glow.scale = Vector2(0.46, 0.32)
	glow.z_index = -1
	visual.add_child(glow)
	visual.move_child(glow, 0)


static func _make_combat_ramp(accent: Color, hot_color: Color) -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.set_color(0, Color(hot_color.r, hot_color.g, hot_color.b, 0.95))
	gradient.set_color(1, Color(accent.r, accent.g, accent.b, 0.0))
	gradient.add_point(0.28, Color(accent.r, accent.g, accent.b, 0.82))
	gradient.add_point(0.72, Color(accent.r, accent.g, accent.b, 0.22))
	var ramp := GradientTexture1D.new()
	ramp.gradient = gradient
	return ramp


static func _make_curve_texture(points: Array[Vector2]) -> CurveTexture:
	var curve := Curve.new()
	curve.min_value = 0.0
	curve.max_value = 1.0
	for point in points:
		curve.add_point(point)

	var texture := CurveTexture.new()
	texture.curve = curve
	return texture


static func _make_soft_circle_image(size: int, hard_radius: float, softness: float) -> Image:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(float(size - 1) * 0.5, float(size - 1) * 0.5)
	var max_radius := float(size) * 0.5
	for y in size:
		for x in size:
			var distance := Vector2(float(x), float(y)).distance_to(center) / max_radius
			var inner_alpha := 1.0 - smoothstep(hard_radius, 1.0, distance)
			var alpha := pow(clampf(inner_alpha, 0.0, 1.0), softness)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha))
	return image
