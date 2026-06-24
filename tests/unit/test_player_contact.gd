# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const ENEMY_SCENE := preload("res://scenes/enemy/enemy.tscn")
const CHASER_DEF := preload("res://resources/enemies/chaser.tres")
const COLLISION := preload("res://scripts/data/collision_layers.gd")


func test_player_collision_mask_excludes_enemies() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	await await_idle_frame()

	assert_int(player.collision_mask).is_equal(COLLISION.WALL)
	assert_int(player.collision_mask & COLLISION.ENEMY).is_equal(0)


func test_contact_damage_slows_enemies_within_radius() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	player.global_position = Vector2(200.0, 200.0)
	await await_idle_frame()

	var touching: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	var nearby: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(touching)
	add_child(nearby)
	touching.configure(CHASER_DEF)
	nearby.configure(CHASER_DEF)
	await _wait_ready(touching)
	await _wait_ready(nearby)

	var touch_distance := 14.0 + CHASER_DEF.radius + 2.0
	touching.global_position = player.global_position + Vector2(touch_distance - 1.0, 0.0)
	nearby.global_position = player.global_position + Vector2(70.0, 0.0)

	var health_before: int = player.get_health()
	player._check_contact_damage()

	assert_int(player.get_health()).is_less(health_before)
	var expected_slow := CHASER_DEF.move_speed * BaseEnemy.CONTACT_SLOW_MULTIPLIER
	assert_float(touching.move_speed).is_equal(expected_slow)
	assert_float(nearby.move_speed).is_equal(expected_slow)


func test_contact_damage_skips_while_invincible() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	player.global_position = Vector2(100.0, 100.0)
	await await_idle_frame()

	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	enemy.configure(CHASER_DEF)
	await _wait_ready(enemy)

	var touch_distance := 14.0 + CHASER_DEF.radius + 2.0
	enemy.global_position = player.global_position + Vector2(touch_distance - 1.0, 0.0)

	player._check_contact_damage()
	var health_after_first_hit: int = player.get_health()

	player._check_contact_damage()

	assert_int(player.get_health()).is_equal(health_after_first_hit)


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
