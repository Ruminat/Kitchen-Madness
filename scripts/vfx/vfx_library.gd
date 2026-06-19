class_name VfxLibrary
extends RefCounted

const DEATH_PARTICLE_AMOUNT := 10
const IMPACT_PARTICLE_AMOUNT := 6
const TRAIL_PARTICLE_AMOUNT := 8

static var _particle_texture: Texture2D


static func get_particle_texture() -> Texture2D:
	if _particle_texture == null:
		var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
		image.fill(Color.WHITE)
		_particle_texture = ImageTexture.create_from_image(image)
	return _particle_texture


static func configure_death_burst(particles: GPUParticles2D, accent: Color) -> void:
	particles.texture = get_particle_texture()
	particles.amount = DEATH_PARTICLE_AMOUNT
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.4
	particles.emitting = false
	particles.visibility_rect = Rect2(-72.0, -72.0, 144.0, 144.0)

	var material := ParticleProcessMaterial.new()
	material.particle_flag_disable_z = true
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 5.0
	material.direction = Vector3(0.0, -1.0, 0.0)
	material.spread = 180.0
	material.initial_velocity_min = 55.0
	material.initial_velocity_max = 130.0
	material.gravity = Vector3.ZERO
	material.scale_min = 1.5
	material.scale_max = 3.5
	material.color_ramp = _make_fade_ramp(accent)
	particles.process_material = material


static func configure_impact_spark(
	particles: GPUParticles2D, accent: Color, direction: Vector2
) -> void:
	particles.texture = get_particle_texture()
	particles.amount = IMPACT_PARTICLE_AMOUNT
	particles.one_shot = true
	particles.explosiveness = 1.0
	particles.lifetime = 0.2
	particles.emitting = false
	particles.visibility_rect = Rect2(-48.0, -48.0, 96.0, 96.0)

	var hit_direction := direction
	if hit_direction.length_squared() <= 0.001:
		hit_direction = Vector2.UP

	var material := ParticleProcessMaterial.new()
	material.particle_flag_disable_z = true
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	material.emission_sphere_radius = 2.0
	material.direction = Vector3(hit_direction.x, hit_direction.y, 0.0)
	material.spread = 40.0
	material.initial_velocity_min = 70.0
	material.initial_velocity_max = 140.0
	material.gravity = Vector3.ZERO
	material.scale_min = 1.0
	material.scale_max = 2.5
	material.color_ramp = _make_fade_ramp(accent.lightened(0.2))
	particles.process_material = material


static func create_trail(accent: Color) -> GPUParticles2D:
	var particles := GPUParticles2D.new()
	particles.name = "Trail"
	particles.texture = get_particle_texture()
	particles.local_coords = false
	particles.amount = TRAIL_PARTICLE_AMOUNT
	particles.lifetime = 0.22
	particles.preprocess = 0.08
	particles.emitting = true
	particles.visibility_rect = Rect2(-40.0, -40.0, 80.0, 80.0)

	var material := ParticleProcessMaterial.new()
	material.particle_flag_disable_z = true
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	material.direction = Vector3.ZERO
	material.spread = 0.0
	material.initial_velocity_min = 0.0
	material.initial_velocity_max = 8.0
	material.gravity = Vector3.ZERO
	material.scale_min = 0.8
	material.scale_max = 1.6
	material.color_ramp = _make_fade_ramp(accent)
	particles.process_material = material
	return particles


static func _make_fade_ramp(accent: Color) -> GradientTexture1D:
	var gradient := Gradient.new()
	gradient.set_color(0, accent)
	gradient.set_color(1, Color(accent.r, accent.g, accent.b, 0.0))
	var ramp := GradientTexture1D.new()
	ramp.gradient = gradient
	return ramp
