# GdUnit generated TestSuite
extends GdUnitTestSuite

const GAME_SCENE := preload("res://scenes/main/game.tscn")
const GAME_SCRIPT := preload("res://scripts/game.gd")
const LEVEL_01 := preload("res://resources/levels/level_01.tres")
const CHEF_DEF := preload("res://resources/characters/chef.tres")
const GOBLIN_DEF := preload("res://resources/characters/goblin.tres")


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


func test_game_auto_applies_default_character_in_headless() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate()) as Node2D
	add_child(game)
	await _wait_ready(game)

	var player: CharacterBody2D = game.get_node("Player") as CharacterBody2D
	assert_object(player.get_character()).is_same(CHEF_DEF)
	assert_int(player.get_max_health()).is_equal(CHEF_DEF.max_health)


func test_game_applies_exported_starting_character() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate()) as Node2D
	game.starting_character = GOBLIN_DEF
	add_child(game)
	await _wait_ready(game)

	var player: CharacterBody2D = game.get_node("Player") as CharacterBody2D
	assert_object(player.get_character()).is_same(GOBLIN_DEF)
	assert_float(player.move_speed).is_equal(GOBLIN_DEF.move_speed)
	assert_int(player.get_luck()).is_equal(GOBLIN_DEF.luck)


func test_game_pauses_on_player_death() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	add_child(game)
	await _wait_ready(game)
	EventBus.player_died.emit()
	assert_bool(game.is_game_over).is_true()
	assert_bool(get_tree().paused).is_true()
	assert_bool(game.is_run_active()).is_false()


func test_game_wins_on_level_completed() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	add_child(game)
	await _wait_ready(game)
	EventBus.level_completed.emit()
	assert_bool(game.is_victory).is_true()
	assert_bool(get_tree().paused).is_true()
	assert_bool(game.is_run_active()).is_false()

	var ui: CanvasLayer = game.get_node("UI") as CanvasLayer
	assert_bool((ui.get_node("Overlay") as CanvasItem).visible).is_true()


func test_level_completed_does_not_open_shop() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	add_child(game)
	await _wait_ready(game)
	EventBus.level_completed.emit()

	var ui: CanvasLayer = game.get_node("UI") as CanvasLayer
	assert_bool((ui.get_node("ShopOverlay") as CanvasItem).visible).is_false()


func test_game_includes_xp_and_floating_text_ui() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	add_child(game)
	await _wait_ready(game)
	assert_object(game.get_node_or_null("XpSystem")).is_not_null()
	assert_object(game.get_node_or_null("GoldSystem")).is_not_null()
	assert_object(game.get_node_or_null("ShopManager")).is_not_null()
	assert_object(game.get_node_or_null("VfxManager")).is_not_null()
	assert_object(game.get_node_or_null("VFXContainer")).is_not_null()
	assert_object(game.get_node_or_null("LevelManager")).is_not_null()
	var ui: CanvasLayer = game.get_node("UI") as CanvasLayer
	assert_object(ui.get_node_or_null("FloatingTextManager")).is_not_null()
	assert_object(ui.get_node_or_null("XpPanel")).is_not_null()
	assert_object(ui.get_node_or_null("ShopOverlay")).is_not_null()


func test_game_scene_has_authored_level() -> void:
	var game: Node2D = auto_free(GAME_SCENE.instantiate())
	add_child(game)
	await _wait_ready(game)

	assert_object(game.level_definition).is_same(LEVEL_01)
	assert_float(game.level_definition.duration).is_equal(600.0)

	var level_manager: LevelManager = game.get_node("LevelManager") as LevelManager
	assert_float(level_manager.get_duration()).is_equal(600.0)


func test_get_level_definition_falls_back_to_default() -> void:
	var game: Node2D = auto_free(GAME_SCRIPT.new())
	game.level_definition = null
	assert_object(game.get_level_definition()).is_not_null()

	game.level_definition = LEVEL_01
	assert_object(game.get_level_definition()).is_same(LEVEL_01)


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
