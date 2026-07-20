# GdUnit generated TestSuite
extends GdUnitTestSuite

const UI_SCENE := preload("res://scenes/ui/game_ui.tscn")
const BARRET_DEF := preload("res://resources/characters/mr_barret.tres")
const NEWBIE_DEF := preload("res://resources/characters/the_newbie.tres")

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


func test_request_character_selection_shows_three_buttons() -> void:
	var ui: CanvasLayer = auto_free(UI_SCENE.instantiate()) as CanvasLayer
	add_child(ui)
	await _wait_ready(ui)

	var roster := CharacterRoster.load_roster()
	# The overlay clears its choices array (shared by reference with `roster`) once a
	# selection is made, so capture the expected character before awaiting.
	var expected_first := roster[0]
	# Godot 4.7 forbids capturing a typed coroutine without awaiting it, so drive
	# the button press from a concurrent Callable while the request awaits.
	Callable(self, "_press_button_when_ready").call(ui, 0, 3)
	var selected: CharacterDefinition = await ui.request_character_selection(roster)

	assert_object(selected).is_same(expected_first)


func test_selecting_character_returns_definition_and_hides_overlay() -> void:
	var ui: CanvasLayer = auto_free(UI_SCENE.instantiate()) as CanvasLayer
	add_child(ui)
	await _wait_ready(ui)

	var roster := CharacterRoster.load_roster()
	Callable(self, "_press_button_when_ready").call(ui, 1, 0)
	var selected: CharacterDefinition = await ui.request_character_selection(roster)

	var overlay: ColorRect = ui.get_node("CharacterSelectOverlay") as ColorRect
	assert_object(selected).is_same(BARRET_DEF)
	assert_bool(overlay.visible).is_false()


func test_character_preview_updates_when_focus_changes() -> void:
	var ui: CanvasLayer = auto_free(UI_SCENE.instantiate()) as CanvasLayer
	add_child(ui)
	await _wait_ready(ui)

	var roster := CharacterRoster.load_roster()
	Callable(self, "_preview_focus_then_select").call(ui)
	await ui.request_character_selection(roster)


func _press_button_when_ready(ui: CanvasLayer, index: int, expected_count: int) -> void:
	await get_tree().process_frame

	var overlay: ColorRect = ui.get_node("CharacterSelectOverlay") as ColorRect
	var grid: GridContainer = ui.get_node(CHARACTER_GRID_PATH) as GridContainer

	if expected_count > 0:
		assert_bool(overlay.visible).is_true()
		assert_int(grid.get_child_count()).is_equal(expected_count)

	(grid.get_child(index) as Button).emit_signal("pressed")


func _preview_focus_then_select(ui: CanvasLayer) -> void:
	await get_tree().process_frame

	var preview: TextureRect = ui.get_node(CHARACTER_PREVIEW_PATH) as TextureRect
	var grid: GridContainer = ui.get_node(CHARACTER_GRID_PATH) as GridContainer

	assert_object(preview.texture).is_same(NEWBIE_DEF.sprite)

	(grid.get_child(1) as Button).emit_signal("mouse_entered")
	assert_object(preview.texture).is_same(BARRET_DEF.sprite)

	(grid.get_child(0) as Button).emit_signal("pressed")


func _wait_ready(node: Node) -> void:
	if not node.is_node_ready():
		await node.ready
