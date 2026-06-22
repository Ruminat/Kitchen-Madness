# GdUnit generated TestSuite
extends GdUnitTestSuite

const GAME_SCENE := preload("res://scenes/main/game.tscn")
const ARENA_SCENE := preload("res://scenes/arena/arena.tscn")


func test_game_uses_global_arena_bounds() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	game.skip_character_select = true
	add_child(game)
	await await_idle_frame()

	var arena: Arena = game.get_node("Arena") as Arena
	assert_vector(game._arena_bounds.position).is_equal(arena.get_global_bounds().position)
	assert_vector(game._arena_bounds.size).is_equal(arena.get_global_bounds().size)


func test_game_clamps_camera_at_arena_edges() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	game.skip_character_select = true
	add_child(game)
	await await_idle_frame()

	var bounds: Rect2 = game._arena_bounds
	var half_view: Vector2 = game._get_camera_world_view_size() * 0.5
	game.player.global_position = bounds.end - Vector2(8.0, 8.0)
	game._follow_player_camera()

	var camera_pos: Vector2 = game.camera.global_position
	assert_float(camera_pos.x).is_less_equal(bounds.end.x - half_view.x + 0.01)
	assert_float(camera_pos.y).is_less_equal(bounds.end.y - half_view.y + 0.01)
	assert_float(camera_pos.x).is_greater_equal(bounds.position.x + half_view.x - 0.01)
	assert_float(camera_pos.y).is_greater_equal(bounds.position.y + half_view.y - 0.01)


func test_spawner_spawn_focus_matches_clamped_camera() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	game.skip_character_select = true
	add_child(game)
	await await_idle_frame()

	var spawner: EnemySpawner = game.enemy_spawner
	game.player.global_position = game._arena_bounds.end - Vector2(8.0, 8.0)
	game._follow_player_camera()

	assert_vector(spawner.camera_focus).is_equal(game.camera.global_position)
