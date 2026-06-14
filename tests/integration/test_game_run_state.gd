# GdUnit generated TestSuite
extends GdUnitTestSuite

const GAME_SCENE := preload("res://scenes/main/game.tscn")


func before() -> void:
	get_tree().paused = false


func after() -> void:
	get_tree().paused = false


func test_game_scene_instantiates() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	add_child(game)
	await _wait_ready(game)
	assert_object(game).is_not_null()
	assert_bool(game.is_run_active()).is_true()
	assert_bool(get_tree().paused).is_false()


func test_game_pauses_on_player_death() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	add_child(game)
	await _wait_ready(game)
	EventBus.player_died.emit()
	assert_bool(game.is_game_over).is_true()
	assert_bool(get_tree().paused).is_true()
	assert_bool(game.is_run_active()).is_false()


func test_game_pauses_on_wave_complete() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	add_child(game)
	await _wait_ready(game)
	EventBus.wave_completed.emit()
	assert_bool(game.is_wave_complete).is_true()
	assert_bool(get_tree().paused).is_true()
	assert_bool(game.is_run_active()).is_false()


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
