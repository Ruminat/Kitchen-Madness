# GdUnit generated TestSuite
extends GdUnitTestSuite

const GAME_SCENE := preload("res://scenes/main/game.tscn")
const GAME_SCRIPT := preload("res://scripts/game.gd")
const WAVE_01 := preload("res://resources/waves/wave_01.tres")
const WAVE_02 := preload("res://resources/waves/wave_02.tres")
const WAVE_03 := preload("res://resources/waves/wave_03.tres")


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


func test_game_includes_xp_and_floating_text_ui() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	add_child(game)
	await _wait_ready(game)
	assert_object(game.get_node_or_null("XpSystem")).is_not_null()
	assert_object(game.get_node_or_null("GoldSystem")).is_not_null()
	assert_object(game.get_node_or_null("ShopManager")).is_not_null()
	var ui: CanvasLayer = game.get_node("UI") as CanvasLayer
	assert_object(ui.get_node_or_null("FloatingTextManager")).is_not_null()
	assert_object(ui.get_node_or_null("XpPanel")).is_not_null()
	assert_object(ui.get_node_or_null("ShopOverlay")).is_not_null()


func test_game_scene_has_authored_wave_sequence() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	add_child(game)
	await _wait_ready(game)

	assert_int(game.wave_definitions.size()).is_equal(3)
	assert_object(game.wave_definitions[0]).is_same(WAVE_01)
	assert_object(game.wave_definitions[1]).is_same(WAVE_02)
	assert_object(game.wave_definitions[2]).is_same(WAVE_03)


func test_game_wave_selection_uses_last_authored_wave_after_sequence() -> void:
	var game: Node2D = auto_free(GAME_SCRIPT.new())
	var waves: Array[WaveDefinition] = [WAVE_01, WAVE_02, WAVE_03]
	game.wave_definitions = waves

	game.current_wave = 1
	assert_object(game.get_current_wave_definition()).is_same(WAVE_01)
	game.current_wave = 2
	assert_object(game.get_current_wave_definition()).is_same(WAVE_02)
	game.current_wave = 3
	assert_object(game.get_current_wave_definition()).is_same(WAVE_03)
	game.current_wave = 8
	assert_object(game.get_current_wave_definition()).is_same(WAVE_03)


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
