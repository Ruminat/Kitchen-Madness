# GdUnit generated TestSuite
extends GdUnitTestSuite

const PLAYER_SCENE := preload("res://scenes/player/player.tscn")
const CHASER_SCENE := preload("res://scenes/enemy/enemy.tscn")
const TANK_SCENE := preload("res://scenes/enemy/tank_enemy.tscn")
const SPRINTER_SCENE := preload("res://scenes/enemy/sprinter_enemy.tscn")
const ARENA_SCENE := preload("res://scenes/arena/arena.tscn")
const CHASER_DEF := preload("res://resources/enemies/chaser.tres")

const BOBBY_TEXTURE := preload("res://assets/characters/player/bobby.png")
const COCKROACH_TEXTURE := preload("res://assets/characters/enemies/cockroach.png")
const RAT_TEXTURE := preload("res://assets/characters/enemies/rat.png")
const FLY_TEXTURE := preload("res://assets/characters/enemies/fly.png")
const FLOOR_TEXTURE := preload("res://assets/arena/dirty_kitchen_tile.png")


func test_player_uses_bobby_sprite() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	await _wait_ready(player)

	var sprite: Sprite2D = player.get_node("Visual/Sprite") as Sprite2D
	assert_object(sprite).is_not_null()
	assert_object(sprite.texture).is_same(BOBBY_TEXTURE)


func test_player_visual_stays_unrotated_during_physics() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	add_child(player)
	await _wait_ready(player)

	var visual: Node2D = player.get_node("Visual") as Node2D
	player.velocity = Vector2(120.0, -80.0)
	for _i in 3:
		player._physics_process(1.0 / 60.0)

	assert_float(visual.rotation).is_equal(0.0)


func test_chaser_enemy_uses_cockroach_sprite() -> void:
	_assert_enemy_sprite(CHASER_SCENE, COCKROACH_TEXTURE)


func test_tank_enemy_uses_rat_sprite() -> void:
	_assert_enemy_sprite(TANK_SCENE, RAT_TEXTURE)


func test_sprinter_enemy_uses_fly_sprite() -> void:
	_assert_enemy_sprite(SPRINTER_SCENE, FLY_TEXTURE)


func test_enemy_visual_stays_unrotated_while_chasing() -> void:
	var player: CharacterBody2D = auto_free(PLAYER_SCENE.instantiate()) as CharacterBody2D
	var enemy: BaseEnemy = auto_free(CHASER_SCENE.instantiate()) as BaseEnemy
	add_child(player)
	add_child(enemy)
	enemy.configure(CHASER_DEF)
	await _wait_ready(player)
	await _wait_ready(enemy)

	enemy.global_position = Vector2.ZERO
	player.global_position = Vector2(200.0, 0.0)
	for _i in 5:
		await get_tree().physics_frame

	assert_float(enemy.visual.rotation).is_equal(0.0)


func test_arena_uses_dirty_kitchen_floor_tiles() -> void:
	var arena: Node2D = auto_free(ARENA_SCENE.instantiate()) as Node2D
	add_child(arena)
	await _wait_ready(arena)

	var background: TextureRect = arena.get_node("FloorTiles/Background") as TextureRect
	assert_object(background.texture).is_same(FLOOR_TEXTURE)
	assert_int(background.stretch_mode).is_equal(TextureRect.STRETCH_TILE)


func test_arena_floor_tiles_scaled_five_times_smaller() -> void:
	var arena: Node2D = auto_free(ARENA_SCENE.instantiate()) as Node2D
	add_child(arena)
	await _wait_ready(arena)

	var floor_tiles: Node2D = arena.get_node("FloorTiles") as Node2D
	var background: TextureRect = arena.get_node("FloorTiles/Background") as TextureRect
	assert_vector(floor_tiles.scale).is_equal(Vector2(0.2, 0.2))
	assert_float(background.offset_left).is_equal(-2200.0)
	assert_float(background.offset_top).is_equal(-1200.0)
	assert_float(background.offset_right).is_equal(2200.0)
	assert_float(background.offset_bottom).is_equal(1200.0)


func _assert_enemy_sprite(scene: PackedScene, expected_texture: Texture2D) -> void:
	var enemy: BaseEnemy = auto_free(scene.instantiate()) as BaseEnemy
	add_child(enemy)
	await _wait_ready(enemy)

	var sprite: Sprite2D = enemy.get_node("Visual/Sprite") as Sprite2D
	assert_object(sprite).is_not_null()
	assert_object(sprite.texture).is_same(expected_texture)


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
