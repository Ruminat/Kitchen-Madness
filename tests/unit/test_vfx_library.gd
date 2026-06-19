# GdUnit generated TestSuite
extends GdUnitTestSuite


func test_creates_particle_texture_once() -> void:
	var first := VfxLibrary.get_particle_texture()
	var second := VfxLibrary.get_particle_texture()
	assert_object(second).is_same(first)


func test_death_burst_uses_one_shot_particles() -> void:
	var particles := GPUParticles2D.new()
	VfxLibrary.configure_death_burst(particles, Color.RED)

	assert_int(particles.amount).is_equal(VfxLibrary.DEATH_PARTICLE_AMOUNT)
	assert_bool(particles.one_shot).is_true()
	assert_object(particles.process_material).is_not_null()


func test_impact_spark_aligns_to_direction() -> void:
	var particles := GPUParticles2D.new()
	VfxLibrary.configure_impact_spark(particles, Color.YELLOW, Vector2.RIGHT)

	var material := particles.process_material as ParticleProcessMaterial
	assert_object(material).is_not_null()
	assert_float(material.direction.x).is_equal(1.0)


func test_trail_uses_world_space_coords() -> void:
	var trail := VfxLibrary.create_trail(Color.ORANGE)
	assert_bool(trail.local_coords).is_false()
	assert_bool(trail.emitting).is_true()
