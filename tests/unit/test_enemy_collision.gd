# GdUnit generated TestSuite
extends GdUnitTestSuite

const ENEMY_SCENE := preload("res://scenes/enemy/enemy.tscn")
const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const CHASER_DEF := preload("res://resources/enemies/chaser.tres")
const COLLISION := preload("res://scripts/data/collision_layers.gd")


func test_enemy_collides_with_walls_player_and_other_enemies() -> void:
	var enemy: CharacterBody2D = auto_free(ENEMY_SCENE.instantiate()) as CharacterBody2D
	add_child(enemy)
	await await_idle_frame()

	assert_int(enemy.collision_layer).is_equal(COLLISION.ENEMY)
	assert_int(enemy.collision_mask).is_equal(COLLISION.ENEMY_MASK)
	assert_int(enemy.motion_mode).is_equal(CharacterBody2D.MOTION_MODE_FLOATING)


func test_player_collides_with_walls_and_enemies() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	await await_idle_frame()

	assert_int(player.collision_layer).is_equal(COLLISION.PLAYER)
	assert_int(player.collision_mask).is_equal(COLLISION.PLAYER_MASK)
	assert_int(player.motion_mode).is_equal(CharacterBody2D.MOTION_MODE_FLOATING)


func test_enemy_collision_shape_matches_definition_radius() -> void:
	var enemy: CharacterBody2D = auto_free(ENEMY_SCENE.instantiate()) as CharacterBody2D
	add_child(enemy)
	enemy.configure(CHASER_DEF)
	await await_idle_frame()

	var shape := enemy.get_node("CollisionShape2D").shape as CircleShape2D
	assert_float(shape.radius).is_equal(CHASER_DEF.radius)


func test_enemy_screen_detail_can_disable_render_and_collision() -> void:
	var enemy: BaseEnemy = auto_free(ENEMY_SCENE.instantiate()) as BaseEnemy
	add_child(enemy)
	await await_idle_frame()

	enemy.set_screen_detail(false, false)

	assert_bool(enemy.get_node("Visual").visible).is_false()
	assert_int(enemy.collision_layer).is_equal(0)
	assert_int(enemy.collision_mask).is_equal(0)

	enemy.set_screen_detail(true, true)

	assert_bool(enemy.get_node("Visual").visible).is_true()
	assert_int(enemy.collision_layer).is_equal(COLLISION.ENEMY)
	assert_int(enemy.collision_mask).is_equal(COLLISION.ENEMY_MASK)


func test_enemies_block_each_other() -> void:
	var enemy_a: CharacterBody2D = auto_free(ENEMY_SCENE.instantiate()) as CharacterBody2D
	var enemy_b: CharacterBody2D = auto_free(ENEMY_SCENE.instantiate()) as CharacterBody2D
	add_child(enemy_a)
	add_child(enemy_b)
	await get_tree().physics_frame

	enemy_a.global_position = Vector2(100.0, 100.0)
	enemy_b.global_position = Vector2(124.0, 100.0)
	var min_distance := CHASER_DEF.radius * 2.0

	for _step in 8:
		enemy_a.velocity = Vector2(200.0, 0.0)
		enemy_a.move_and_slide()
		await get_tree().physics_frame

	assert_float(enemy_a.global_position.distance_to(enemy_b.global_position)).is_greater_equal(
		min_distance - 1.0
	)
