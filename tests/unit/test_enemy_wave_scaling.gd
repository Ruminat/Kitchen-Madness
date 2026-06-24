# GdUnit generated TestSuite
extends GdUnitTestSuite

const CHASER_DEF := preload("res://resources/enemies/chaser.tres")


func test_configure_for_wave_scales_health_and_contact_damage() -> void:
	var enemy: BaseEnemy = auto_free(BaseEnemy.new()) as BaseEnemy
	var health := HealthComponent.new()
	health.name = "HealthComponent"
	enemy.add_child(health)
	enemy.configure_for_wave(CHASER_DEF, 4)

	var expected_health := WaveDefinition.resolve_enemy_health(CHASER_DEF.max_health, 4)
	var expected_damage := WaveDefinition.resolve_contact_damage(CHASER_DEF.contact_damage, 4)
	assert_int(health.max_health).is_equal(expected_health)
	assert_int(enemy.get_contact_damage()).is_equal(expected_damage)
