# GdUnit generated TestSuite
extends GdUnitTestSuite

const UI_SCENE := preload("res://scenes/ui/game_ui.tscn")
const GOBLIN_DEF := preload("res://resources/characters/goblin.tres")
const CHEF_DEF := preload("res://resources/characters/chef.tres")

const CHARACTER_GRID_PATH := (
	"CharacterSelectOverlay/CenterContainer/PanelContainer/" + "MarginContainer/VBox/CharacterGrid"
)
const CHARACTER_PREVIEW_PATH := (
	"CharacterSelectOverlay/CenterContainer/PanelContainer/"
	+ "MarginContainer/VBox/PreviewRow/PreviewPanel/PreviewMargin/CharacterPreview"
)


func before() -> void:
	get_tree().paused = false


func after() -> void:
	get_tree().paused = false


func test_request_character_selection_shows_nine_buttons() -> void:
	var ui: CanvasLayer = auto_free(UI_SCENE.instantiate()) as CanvasLayer
	add_child(ui)
	await _wait_ready(ui)

	var roster := CharacterRoster.load_roster()
	var selection_task: Variant = ui.request_character_selection(roster)
	await get_tree().process_frame

	var overlay: ColorRect = ui.get_node("CharacterSelectOverlay") as ColorRect
	var grid: GridContainer = ui.get_node(CHARACTER_GRID_PATH) as GridContainer

	assert_bool(overlay.visible).is_true()
	assert_int(grid.get_child_count()).is_equal(9)

	(grid.get_child(0) as Button).emit_signal("pressed")
	var selected: CharacterDefinition = await selection_task
	assert_object(selected).is_same(roster[0])


func test_selecting_character_returns_definition_and_hides_overlay() -> void:
	var ui: CanvasLayer = auto_free(UI_SCENE.instantiate()) as CanvasLayer
	add_child(ui)
	await _wait_ready(ui)

	var roster := CharacterRoster.load_roster()
	var selection_task: Variant = ui.request_character_selection(roster)
	await get_tree().process_frame

	var grid: GridContainer = ui.get_node(CHARACTER_GRID_PATH) as GridContainer
	(grid.get_child(1) as Button).emit_signal("pressed")

	var selected: CharacterDefinition = await selection_task
	var overlay: ColorRect = ui.get_node("CharacterSelectOverlay") as ColorRect

	assert_object(selected).is_same(GOBLIN_DEF)
	assert_bool(overlay.visible).is_false()


func test_character_preview_updates_when_focus_changes() -> void:
	var ui: CanvasLayer = auto_free(UI_SCENE.instantiate()) as CanvasLayer
	add_child(ui)
	await _wait_ready(ui)

	var roster := CharacterRoster.load_roster()
	var selection_task: Variant = ui.request_character_selection(roster)
	await get_tree().process_frame

	var preview: TextureRect = ui.get_node(CHARACTER_PREVIEW_PATH) as TextureRect
	var grid: GridContainer = ui.get_node(CHARACTER_GRID_PATH) as GridContainer

	assert_object(preview.texture).is_same(CHEF_DEF.sprite)

	(grid.get_child(1) as Button).emit_signal("mouse_entered")
	assert_object(preview.texture).is_same(GOBLIN_DEF.sprite)

	(grid.get_child(0) as Button).emit_signal("pressed")
	await selection_task


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
